//
//  ASKingfisherImageDownloader.swift
//  Social
//
//  Created by 李响 on 2019/6/20.
//  Copyright © 2019 shengsheng. All rights reserved.
//

import AsyncDisplayKit
import Kingfisher

enum ASKingfisherImage {
    
    public struct ImageProgressive {
        
        /// A default `ImageProgressive` could be used across.
        public static let `default` = ImageProgressive(
            isBlur: true,
            isFastestScan: true,
            scanInterval: 0,
            processingQueue: .dispatch(.global())
        )
        
        /// Whether to enable blur effect processing
        let isBlur: Bool
        /// Whether to enable the fastest scan
        let isFastestScan: Bool
        /// Minimum time interval for each scan
        let scanInterval: TimeInterval
        
        let processingQueue: CallbackQueue
        
        public init(isBlur: Bool,
                    isFastestScan: Bool,
                    scanInterval: TimeInterval,
                    processingQueue: CallbackQueue) {
            self.isBlur = isBlur
            self.isFastestScan = isFastestScan
            self.scanInterval = scanInterval
            self.processingQueue = processingQueue
        }
    }
    
    fileprivate class Context {
        private let task: DownloadTask
        var progress: ((CGFloat) -> Void)?
        var isCancelled: Bool = false
        var isFinished: Bool = false
        var mutableData: Data {
            return task.sessionTask.mutableData
        }
        var priority: Float {
            get { return task.sessionTask.task.priority }
            set { task.sessionTask.task.priority = newValue }
        }
        
        init?(_ task: DownloadTask?) {
            guard let task = task else { return nil }
            self.task = task
        }
        
        func cancel() {
            task.cancel()
            isCancelled = true
        }
    }
}

fileprivate typealias Context = ASKingfisherImage.Context

final class ASKingfisherImageCache: NSObject, ASImageCacheProtocol {
    
    static let shared = ASKingfisherImageCache()
    
    var isMemoryRemoval: Bool = false
    
    func cachedImage(with url: URL, callbackQueue: DispatchQueue, completion: @escaping ASImageCacherCompletion) {
        KingfisherManager.shared.cache.retrieveImage(
            forKey: url.cacheKey,
            callbackQueue: .dispatch(callbackQueue)
        ) { (result) in
            guard let value = try? result.get() else { return }
            completion(value.image)
        }
    }
    
    func synchronouslyFetchedCachedImage(with url: URL) -> ASImageContainerProtocol? {
        var cache: Image?
        let semaphore = DispatchSemaphore(value: 0)
        KingfisherManager.shared.cache.retrieveImage(forKey: url.cacheKey) { (result) in
            defer { semaphore.signal() }
            let value = try? result.get()
            cache = value?.image
        }
        semaphore.wait()
        return cache
    }
    
    func clearFetchedImageFromCache(with url: URL) {
        guard isMemoryRemoval else { return }
        
        KingfisherManager.shared.cache.removeImage(forKey: url.cacheKey)
    }
}

final class ASKingfisherImageDownloader: NSObject {
    
    typealias ImageProgressive = ASKingfisherImage.ImageProgressive
    
    static let shared = ASKingfisherImageDownloader()
    
    private let progressive: ImageProgressive
    
    init(_ progressive: ImageProgressive = .default) {
        self.progressive = progressive
    }
}

extension ASKingfisherImageDownloader: ASImageDownloaderProtocol {
    
    func downloadImage(with url: URL, callbackQueue: DispatchQueue, downloadProgress: ASImageDownloaderProgress?, completion: @escaping ASImageDownloaderCompletion) -> Any? {
        
        var context: Context?
        
        let task = KingfisherManager.shared.retrieveImage(
            with: url,
            options: [
                .cacheMemoryOnly,
                .callbackQueue(.dispatch(callbackQueue))
            ],
            progressBlock: {
                let result = CGFloat($0) / CGFloat($1)
                downloadProgress?(result)
                context?.progress?(result)
            },
            completionHandler: { (result) in
                context?.isFinished = true
                switch result {
                case .success(let value):
                    completion(value.image, nil, context, value)
                    
                case .failure(let error):
                    completion(nil, error, context, nil)
                }
            }
        )
        context = Context(task)
        return context
    }
    
    func cancelImageDownload(forIdentifier downloadIdentifier: Any) {
        guard let context = downloadIdentifier as? Context else { return }
        context.cancel()
    }
    
    func setProgressImageBlock(_ progressBlock: ASImageDownloaderProgressImage?, callbackQueue: DispatchQueue, withDownloadIdentifier downloadIdentifier: Any) {
        guard let context = downloadIdentifier as? Context else { return }
        guard let callback = progressBlock else { return }
        
        var progress: CGFloat = 0.0
        let provider = ImageProgressiveProvider(progressive) { [progress] (image) in
            callbackQueue.async { callback(image, progress, context) }
        }
        provider.cancellable = { context.isCancelled || context.isFinished }
        context.progress = { value in
            progress = value
            provider.update(data: context.mutableData)
        }
    }
    
    func setPriority(_ priority: ASImageDownloaderPriority, withDownloadIdentifier downloadIdentifier: Any) {
        guard let context = downloadIdentifier as? Context else { return }
       
        switch priority {
        case .preload:
            context.priority = URLSessionTask.lowPriority
        
        case .imminent:
            context.priority = URLSessionTask.defaultPriority
            
        case .visible:
            context.priority = URLSessionTask.highPriority
            
        @unknown default:
            context.priority = URLSessionTask.defaultPriority
        }
    }
}

fileprivate final class ImageProgressiveProvider {
    
    typealias ImageProgressive = ASKingfisherImage.ImageProgressive
    
    var cancellable: () -> Bool = { return false }
    
    private let option: ImageProgressive
    private let refresh: (Image) -> Void
    
    private let decoder: ImageProgressiveDecoder
    private let queue = ImageProgressiveSerialQueue()
    
    init(_ option: ImageProgressive, refresh: @escaping (Image) -> Void) {
        self.option = option
        self.refresh = refresh
        self.decoder = ImageProgressiveDecoder(option, with: option.processingQueue)
    }
    
    func update(data: Data) {
        guard !data.isEmpty else { return }
        
        queue.add(minimum: option.scanInterval) { [weak self] completion in
            guard let self = self else { return }
            guard !self.cancellable() else {
                self.queue.clean()
                completion()
                return
            }
            
            func decode(_ data: Data) {
                self.decoder.decode(data) { [weak self] image in
                    defer { completion() }
                    guard let self = self else { return }
                    guard !self.cancellable() else { return }
                    guard let image = image else { return }
                    self.refresh(image)
                }
            }
            
            if self.option.isFastestScan {
                decode(self.decoder.scanning(data) ?? Data())
                
            } else {
                self.decoder.scanning(data).forEach { decode($0) }
            }
        }
    }
}

fileprivate final class ImageProgressiveDecoder {
    
    typealias ImageProgressive = ASKingfisherImage.ImageProgressive
    
    private let option: ImageProgressive
    private let processingQueue: CallbackQueue
    private(set) var scannedCount = 0
    private(set) var scannedIndex = -1
    
    init(_ option: ImageProgressive, with processingQueue: CallbackQueue) {
        self.option = option
        self.processingQueue = processingQueue
    }
    
    func scanning(_ data: Data) -> [Data] {
        guard data.kf.contains(jpeg: .SOF2) else {
            return []
        }
        guard scannedIndex + 1 < data.count else {
            return []
        }
        
        var datas: [Data] = []
        var index = scannedIndex + 1
        var count = scannedCount
        
        while index < data.count - 1 {
            scannedIndex = index
            // 0xFF, 0xDA - Start Of Scan
            let SOS = [0xFF, 0xDA]
            if data[index] == SOS[0], data[index + 1] == SOS[1] {
                if count > 0 {
                    datas.append(data[0 ..< index])
                }
                count += 1
            }
            index += 1
        }
        
        // Found more scans this the previous time
        guard count > scannedCount else { return [] }
        scannedCount = count
        
        // `> 1` checks that we've received a first scan (SOS) and then received
        // and also received a second scan (SOS). This way we know that we have
        // at least one full scan available.
        guard count > 1 else { return [] }
        return datas
    }
    
    func scanning(_ data: Data) -> Data? {
        guard data.kf.contains(jpeg: .SOF2) else {
            return nil
        }
        guard scannedIndex + 1 < data.count else {
            return nil
        }
        
        var index = scannedIndex + 1
        var count = scannedCount
        var lastSOSIndex = 0
        
        while index < data.count - 1 {
            scannedIndex = index
            // 0xFF, 0xDA - Start Of Scan
            let SOS = [0xFF, 0xDA]
            if data[index] == SOS[0], data[index + 1] == SOS[1] {
                lastSOSIndex = index
                count += 1
            }
            index += 1
        }
        
        // Found more scans this the previous time
        guard count > scannedCount else { return nil }
        scannedCount = count
        
        // `> 1` checks that we've received a first scan (SOS) and then received
        // and also received a second scan (SOS). This way we know that we have
        // at least one full scan available.
        guard count > 1 && lastSOSIndex > 0 else { return nil }
        return data[0 ..< lastSOSIndex]
    }
    
    func decode(_ data: Data,
                completion: @escaping (Image?) -> Void) {
        guard data.kf.contains(jpeg: .SOF2) else {
            CallbackQueue.mainCurrentOrAsync.execute { completion(nil) }
            return
        }
        
        // Blur partial images.
        let count = scannedCount
        
        if option.isBlur, count < 6 {
            processingQueue.execute {
                // Progressively reduce blur as we load more scans.
                let image = KingfisherWrapper<Image>.image(
                    data: data,
                    options: .init()
                )
                let radius = max(2, 14 - count * 4)
                let temp = image?.kf.blurred(withRadius: CGFloat(radius))
                CallbackQueue.mainCurrentOrAsync.execute { completion(temp) }
            }
            
        } else {
            processingQueue.execute {
                let image = KingfisherWrapper<Image>.image(
                    data: data,
                    options: .init()
                )
                CallbackQueue.mainCurrentOrAsync.execute { completion(image) }
            }
        }
    }
}

fileprivate final class ImageProgressiveSerialQueue {
    typealias ClosureCallback = ((@escaping () -> Void)) -> Void
    
    private let queue: DispatchQueue = .init(label: "ImageProgressiveSerialQueue")
    private var items: [DispatchWorkItem] = []
    private var notify: (() -> Void)?
    private var lastTime: TimeInterval?
    var count: Int { return items.count }
    
    func add(minimum interval: TimeInterval, closure: @escaping ClosureCallback) {
        let completion = { [weak self] in
            guard let self = self else { return }
            
            self.queue.async { [weak self] in
                guard let self = self else { return }
                guard !self.items.isEmpty else { return }
                
                self.items.removeFirst()
                
                if let next = self.items.first {
                    self.queue.asyncAfter(
                        deadline: .now() + interval,
                        execute: next
                    )
                    
                } else {
                    self.lastTime = Date().timeIntervalSince1970
                    self.notify?()
                    self.notify = nil
                }
            }
        }
        
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let item = DispatchWorkItem {
                closure(completion)
            }
            if self.items.isEmpty {
                let difference = Date().timeIntervalSince1970 - (self.lastTime ?? 0)
                let delay = difference < interval ? interval - difference : 0
                self.queue.asyncAfter(deadline: .now() + delay, execute: item)
            }
            self.items.append(item)
        }
    }
    
    func notify(_ closure: @escaping () -> Void) {
        self.notify = closure
    }
    
    func clean() {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.items.forEach { $0.cancel() }
            self.items.removeAll()
        }
    }
}

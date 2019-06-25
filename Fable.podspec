Pod::Spec.new do |s|

s.name         = "Fable"
s.version      = "0.0.6"
s.summary      = "An elegant highlight focus guide written in swift"

s.homepage     = "https://github.com/fanglinwei/Fable"

s.license      = { :type => "MIT", :file => "LICENSE" }

s.author       = { "calm" => "calm1993@163.com" }

s.platform     = :ios, "10.0"

s.source       = { :git => "https://github.com/fanglinwei/Fable.git", :tag => s.version }

s.source_files  = "Sources/**/*.swift"

s.requires_arc = true

s.frameworks = "UIKit", "Foundation"

s.swift_version = "5.0"

end

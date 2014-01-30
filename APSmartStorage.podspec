Pod::Spec.new do |s|
  s.name         = "APSmartStorage"
  s.version      = "0.0.4"
  s.summary      = "Smart Storage (network -> file -> memory)"
  s.homepage     = "https://github.com/Alterplay/APSmartStorage"
  s.license      = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.author       = { "Alexey Belkevich" => "alexey.belkevich@alterplay.com" }
  s.source       = { :git => "https://github.com/Alterplay/APSmartStorage.git",
		                 :tag => s.version.to_s }
  s.source_files = 'Classes/**/*.{h,m}'
  s.ios.deployment_target = "5.0"
  s.requires_arc = true
  s.dependency 'APAsyncDictionary', '0.0.2'
  s.dependency 'MD5Digest', '0.1.0'
end

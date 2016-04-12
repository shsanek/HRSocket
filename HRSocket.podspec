Pod::Spec.new do |s|
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.name         = "HRSocket"
  s.version      = "0.0.1"
  s.summary      = "HRSocket pod for create server client programm"
  s.description  = "HRSocket pod for create server client programm,socket. Force send NSData "
  s.license      = "MIT"
  s.author             = { "shsanek" => "shipin@sibers.com" }
  s.source       = { :git => "https://github.com/shsanek/HRSocket.git", :tag => "0.0.1" }
  s.source_files  = "HRSocket", "HRSocket/**/*.{h,m}"
  s.public_header_files = "HRSocket/**/*.h"
  s.homepage = "https://github.com/shsanek/HRSocket";
end
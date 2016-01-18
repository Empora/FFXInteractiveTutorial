Pod::Spec.new do |spec|
spec.name         = 'FFXInteractiveTutorial'
spec.version      = '1.0'
spec.license      = { :type => 'MIT' }
spec.homepage     = 'https://github.com/Empora/FFXInteractiveTutorial'
spec.authors      = { 'Robert Biehl' => 'robert.biehl@empora.com' }
spec.summary      = 'iOS Interactive tutorial framework'
spec.platform     = :ios, "7.0"
spec.source       = { :git => 'https://github.com/Empora/FFXInteractiveTutorial.git', :commit => 'b6de7ca' }
spec.source_files = 'FFXinteractiveTutorial/*.{h,m}'
spec.dependency 'Mixpanel'
end
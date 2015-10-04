Pod::Spec.new do |spec|
spec.name         = 'FFXInteractiveTutorial'
spec.version      = '0.1pre'
spec.license      = { :type => 'MIT' }
spec.homepage     = 'https://github.com/Empora/FFXInteractiveTutorial'
spec.authors      = { 'Robert BIehl' => 'robert.biehl@empora.com' }
spec.summary      = 'iOS Interactive tutorial framework'
spec.platform     = :ios, "7.0"
spec.source       = { :git => 'https://github.com/Empora/FFXInteractiveTutorial.git', :commit => 'aa5043d' }
spec.source_files = 'FFXinteractiveTutorial/*.{h,m}'
spec.dependency 'Mixpanel'
end
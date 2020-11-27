Pod::Spec.new do |s|
  s.name          = "MBRealmKit"
  s.version       = "3.0.0"
  s.summary       = "MBRealmKit is a public Pod of MBition GmbH" 
  s.description   = "This module handles the offline storage of the MBSDK-Modules. It caches the required data and returns it. It is possible to observe the cached data and to respond to the changes."
  s.homepage      = "https://mbition.io"
  s.license       = 'MIT'
  s.author        = { "MBition GmbH" => "info_mbition@daimler.com" }
  s.source        = { :git => "https://github.com/Daimler/MBSDK-RealmKit-iOS.git", :tag => String(s.version) }
  s.platform      = :ios, '12.0'
  s.swift_version = ['5.0', '5.1', '5.2', '5.3']

  s.source_files =  'MBRealmKit/MBRealmKit/**/*.{swift,xib}',
                    'MBRealmKit/MBRealmKitUI/**/*.{swift,xib}'


  # internal dependencies
  s.dependency 'MBCommonKit/Logger', '~> 3.0'

  # external dependencies
  s.dependency 'Realm', '~> 10.1'
  s.dependency 'RealmSwift', '~> 10.1'
end

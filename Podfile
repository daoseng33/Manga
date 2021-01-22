
platform :ios, '14.2'

# ignore all warnings from all pods
inhibit_all_warnings!

post_install do |installer|
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.2'
			if config.name == 'Debug'
        config.build_settings['OTHER_SWIFT_FLAGS'] = ['$(inherited)', '-Onone']
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
      end
		end
	end
end

target 'Manga' do
  # Pods for Manga
  pod 'Moya/RxSwift', '~> 14.0'
  pod 'RxSwift', '5.1.1'
  pod 'RxCocoa', '5.1.1'
  pod 'Kingfisher', '~> 6'
  pod "RxGesture", '3.0.2'
  pod 'MBProgressHUD', '~> 1.2.0'
  pod 'RealmSwift', '10.1.4' 
  pod 'Realm', '10.1.4', :modular_headers => true

  target 'MangaTests' do
    inherit! :search_paths
		pod 'RxBlocking', '5.1.1'
		pod 'SwiftyMocky'
  end

  target 'MangaUITests' do
  end

end

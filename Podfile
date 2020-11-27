source 'https://github.com/CocoaPods/Specs.git'

platform :ios,'12.0'
use_frameworks!
inhibit_all_warnings!
workspace 'MBRealmKit'


def pods
	# code analyser
	pod 'SwiftLint', '~> 0.30'

	# public libs
	pod 'RealmSwift', '~> 10.1'

	# module
	pod 'MBCommonKit/Logger', '~> 3.0'
end


target 'Example' do
	project 'Example/Example'
	
	pods
end

target 'MBRealmKit' do
	project 'MBRealmKit/MBRealmKit'
	
	pods

	target 'MBRealmKitTests' do
	end
end

target 'MBRealmKitUI' do
	project 'MBRealmKit/MBRealmKit'
	
	pods

	target 'MBRealmKitUITests' do
	end
end

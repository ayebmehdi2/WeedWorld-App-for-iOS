# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'weedworld' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'SideMenu'
  pod ‘FirebaseFirestoreSwift’
  pod 'FirebaseStorage'
  pod 'Kingfisher'
  pod 'GoogleMaps', '7.4.0'
  pod 'GooglePlaces', '7.4.0'
  pod 'GeoFire/Utils'
  pod 'IQKeyboardManagerSwift'
end

post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
  end
 end
end

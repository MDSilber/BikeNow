# Uncomment this line to define a global platform for your project
platform :ios, '7.0'

target 'BikeNow' do
pod 'AFNetworking'
pod 'Reachability'
end

post_install do |installer_representation|
    installer_representation.project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
        end
    end
end

inhibit_all_warnings!

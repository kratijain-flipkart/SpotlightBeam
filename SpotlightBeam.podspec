#
# Be sure to run `pod lib lint SpotlightBeam.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SpotlightBeam"
  s.version          = "0.1.0"
  s.summary          = "Pod for providing Spotlight Support with validation wrapper API for ios 9+"
  s.description      = <<-DESC
                       Provides API For Batch/Singular Creation/Deletion of Spotlight Indices with a layer of validation

  s.homepage         = "https://github.com/kratijain-flipkart/SpotlightBeam"
  s.license          = 'MIT'
  s.author           = { "Krati Jain" => "krati.jain@flipkart.com" }
  s.source           = { :git => "https://github.com/kratijain-flipkart/SpotlightBeam.git", :branch=>"master" }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'SpotlightBeam' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

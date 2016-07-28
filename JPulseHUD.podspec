#
# Be sure to run `pod lib lint JPulseHUD.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JPulseHUD'
  s.version          = '0.1.0'
  s.summary          = "Drop-in progress HUD that generates a unique loading pulsing animation each time it's shown."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
JPulseHUD is a drop in class for displaying a translucent view over a controller when work is being done on a background thread or you're awaiting the result of a network request. This HUD was inspired by Acorns similar pulse animation within their iOS app.
                       DESC

  s.homepage         = 'https://github.com/jacks205/JPulseHUD'
  s.screenshots     = 'https://raw.githubusercontent.com/jacks205/JPulseHUD/master/image/jpulsehud1.png', 'https://raw.githubusercontent.com/jacks205/JPulseHUD/master/image/jpulsehud2.gif', 'https://raw.githubusercontent.com/jacks205/JPulseHUD/master/image/jpulsehud1.gif'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mark Jackson' => 'markjacks205@gmail.com' }
  s.source           = { :git => 'https://github.com/jacks205/JPulseHUD.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/mjacks205'

  s.ios.deployment_target = '8.0'

  s.source_files = 'JPulseHUD/Classes/**/*'
  
  # s.resource_bundles = {
  #   'JPulseHUD' => ['JPulseHUD/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

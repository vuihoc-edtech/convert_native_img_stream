#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint convert_native_img_stream.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'convert_native_img_stream'
  s.version          = '0.0.1'
  s.summary          = 'Converter utility for converting ImageFormatGroup.nv21 or ImageFormatGroup.bgra8888 to jpeg file (coming from camera stream)'
  s.description      = <<-DESC
Converter utility for converting ImageFormatGroup.nv21 or ImageFormatGroup.bgra8888 to jpeg file (coming from camera stream)
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '10.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end

#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_typed_navigation'
  s.version          = '0.1.0'
  s.summary          = 'A typed navigation framework for Flutter with hierarchical routing and state management support.'
  s.description      = <<-DESC
A typed navigation framework for Flutter with hierarchical routing and state management support.
                       DESC
  s.homepage         = 'https://github.com/your-username/flutter_typed_navigation'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }

  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
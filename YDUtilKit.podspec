#
#  Be sure to run `pod spec lint YDUtilKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "YDUtilKit"
  spec.version      = "0.1.5"
  spec.summary      = "常用工具库"

  spec.homepage     = "https://github.com/chong2vv/YDUtilKit"
  

  spec.license      = "MIT"
  spec.author             = { "王远东" => "chong2vv@gmail.com" }

  spec.platform     = :ios, "9.0"
  
  spec.source       = { :git => "https://github.com/chong2vv/YDUtilKit.git", :tag => "#{spec.version}" }
  spec.source_files = "YDUtilKit/*"

  spec.subspec 'YDFoundation' do |fd_ss|
      fd_ss.source_files = "YDUtilKit/YDFoundation/**/*"
  end

  spec.subspec 'YDUIKit' do |uk_ss|
      uk_ss.source_files = "YDUtilKit/YDUIKit/**/*"
      uk_ss.dependency 'YDUtilKit/YDBaseUI'
      uk_ss.dependency 'YDUtilKit/YDFoundation'
      uk_ss.dependency 'YDUtilKit/YDTools'
  end
  
  spec.subspec 'YDBaseUI' do |bu_ss|
      bu_ss.source_files = "YDUtilKit/YDBaseUI/**/*"
  end
  
  spec.subspec 'YDTools' do |tl_ss|
      tl_ss.source_files = "YDUtilKit/YDTools/**/*"
      tl_ss.dependency 'YDUtilKit/YDFoundation'
  end

  spec.requires_arc = true
  spec.frameworks = "Foundation", "UIKit"

end

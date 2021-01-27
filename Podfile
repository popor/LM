# Uncomment the next line to define a global platform for your project
#platform :ios, '9.0'

post_install do |pi|
  pi.pods_project.targets.each do |t|
    t.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
    end
  end
end

# 推荐继续使用 传统的 pod
#source 'https://github.com/CocoaPods/Specs.git'
source 'https://cdn.cocoapods.org/'

target 'LM' do
  # Comment the next line if you don't want to use dynamic frameworks
  # use_frameworks!
  inhibit_all_warnings!
  
  # Pods for LM
  pod 'PoporUI'#, '~>1.22'
  pod 'PoporFoundation' #, '1.24'
  pod 'PoporPopNormalNC'
  pod 'PoporAlertBubbleView'
  #pod 'PoporImageBrower'
  pod 'PoporAFN', '~>1.07'
  #pod 'PoporNetRecord'
  pod 'PoporSegmentView'
  pod 'PoporJsonModel'
  
  #  pod 'PoporRotate', '1.2'
  #  pod 'PoporRotate', :path => '/Users/popor/Documents/wkq/GitHubSDK/PoporRotate'
  pod 'PoporRotate', :git=>'https://github.com/popor/PoporRotate.git' , :branch => 'main', :tag => '1.5'
  
  pod 'Masonry'
  #  pod 'YYModel'
  #  pod 'YYCache'
  pod 'GCDWebServer'
  #  pod 'KVOController'
  pod 'ReactiveObjC'
  
  pod 'StepSlider'
  
  # GCDWebServer 关于wifi上传到APP文件夹介绍http://www.jianshu.com/p/534632485234
  pod 'GCDWebServer'
  pod 'GCDWebServer/WebUploader'
  pod 'GCDWebServer/WebDAV'

  #pod 'YLGIFImage'

  # pod 'StreamingKit'
  # pod 'TheAmazingAudioEngine'
  
  pod 'MGJRouter' # 感觉MGJRouter命名规则更符合要求
  pod 'DMProgressHUD'
  
  pod 'Base64'
  
end

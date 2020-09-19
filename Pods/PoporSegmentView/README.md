# PoporSegmentView

[![CI Status](https://img.shields.io/travis/popor/PoporSegmentView.svg?style=flat)](https://travis-ci.org/popor/PoporSegmentView)
[![Version](https://img.shields.io/cocoapods/v/PoporSegmentView.svg?style=flat)](https://cocoapods.org/pods/PoporSegmentView)
[![License](https://img.shields.io/cocoapods/l/PoporSegmentView.svg?style=flat)](https://cocoapods.org/pods/PoporSegmentView)
[![Platform](https://img.shields.io/cocoapods/p/PoporSegmentView.svg?style=flat)](https://cocoapods.org/pods/PoporSegmentView)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

PoporSegmentView is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'PoporSegmentView'
```

<p>
<img src="https://github.com/popor/PoporSegmentView/blob/master/Example/screen/scrren1.png" width="30%" height="30%">

</p>

v1.04
开放接口:- (void)updateLineViewToBT:(UIButton *)bt 

1.07
增加: btTitleSFont
设置btTitleSFont的话, titleArray最好不要太多, 否则滑动的时候UI.frame变化尺寸比较大影响效果

1.08
移除了 PoporUI 的依赖  

1.10
修改 拖拽 和 代码控制 scrollview frame 逻辑

1.11
PoporSegmentViewTypeScrollView 的 bt masonry 增加top bottom =0

1.12
滑动的时候 增加了 标题颜色渐变功能

## Author

popor, 908891024@qq.com

## License

PoporSegmentView is available under the MIT license. See the LICENSE file for more info.

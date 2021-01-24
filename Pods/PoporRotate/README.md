# PoporRotate

[![CI Status](https://img.shields.io/travis/popor/PoporRotate.svg?style=flat)](https://travis-ci.org/popor/PoporRotate)
[![Version](https://img.shields.io/cocoapods/v/PoporRotate.svg?style=flat)](https://cocoapods.org/pods/PoporRotate)
[![License](https://img.shields.io/cocoapods/l/PoporRotate.svg?style=flat)](https://cocoapods.org/pods/PoporRotate)
[![Platform](https://img.shields.io/cocoapods/p/PoporRotate.svg?style=flat)](https://cocoapods.org/pods/PoporRotate)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

PoporRotate is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'PoporRotate'
```

推荐用法

```objc
#import <PoporRotate/PoporRotate.h>
```
```objc
// XxxxAppDelegate
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
#if TARGET_OS_MACCATALYST
    return UIInterfaceOrientationMaskPortrait;
#else
    PoporRotate * pr = [PoporRotate share];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return pr.supportedInterfaceOrientations;
    } else {
        if (pr.appLoaded) {
            return pr.supportedInterfaceOrientations;
        } else {
            return UIInterfaceOrientationMaskPortrait;
        }
    }
#endif
}

// XxxxVC
self.pr = [PoporRotate share];
self.pr.appLoaded = YES;
```

```objc
- (void)vcAction:(NSInteger)tag {
    switch (tag) {
        case 0: {
            [self.pr orientationAll];
            break;
        }
        case 1: {
            [self.pr orientationLeft];
            break;
        }
        case 2: {
            [self.pr orientationRitht];
            break;
        }
        case 3: {
            //[self.pr orientationLandscape_priorityLeft:YES]; // 等同于下面
            [self.pr orientationAll_priority:UIInterfaceOrientationMaskLandscapeLeft|UIInterfaceOrientationMaskLandscapeRight high:UIInterfaceOrientationMaskLandscapeRight];
            break;
        }
        case 4: {
            //[self.pr orientationLandscape_priorityLeft:NO]; // 等同于下面
            [self.pr orientationAll_priority:UIInterfaceOrientationMaskLandscapeLeft|UIInterfaceOrientationMaskLandscapeRight high:UIInterfaceOrientationMaskLandscapeLeft];
            break;
        }
        case 5: {
            [self.pr orientationUp];
            break;
        }
        case 6: { // 手边没iPad没有测试
            [self.pr orientationVertical_priorityUp:YES];
            break;
        }
        case 7: { // 手边没iPad没有测试
            [self.pr orientationVertical_priorityUp:NO];
            break;
        }
        default:
            break;
    }
}
```

## Author

popor, 908891024@qq.com

## License

PoporRotate is available under the MIT license. See the LICENSE file for more info.

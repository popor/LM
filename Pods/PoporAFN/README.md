<a href='https://github.com/popor/mybox'> MyBox </a>

# PoporAFN

[![CI Status](https://img.shields.io/travis/wangkq/PoporAFN.svg?style=flat)](https://travis-ci.org/wangkq/PoporAFN)
[![Version](https://img.shields.io/cocoapods/v/PoporAFN.svg?style=flat)](https://cocoapods.org/pods/PoporAFN)
[![License](https://img.shields.io/cocoapods/l/PoporAFN.svg?style=flat)](https://cocoapods.org/pods/PoporAFN)
[![Platform](https://img.shields.io/cocoapods/p/PoporAFN.svg?style=flat)](https://cocoapods.org/pods/PoporAFN)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.
### 包装了AFN方法,支持网络监测功能(通过PoporNetRecord控制).
### [PoporAFNTool getUrl:@"https://api.androidhive.info/volley/person_object.json" parameters:@{@"test":@"test1"} success:nil failure:nil monitor:YES];

## Requirements

## Installation

PoporAFN is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'PoporAFN'
```

```
// 可以 设置head
PoporAFNConfig * config = [PoporAFNConfig share];
config.afnSMBlock = ^AFHTTPSessionManager *{
	AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

	manager.requestSerializer  = [AFJSONRequestSerializer serializer];
	manager.responseSerializer = [AFHTTPResponseSerializer serializer];
	manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil]; // 不然不支持www.baidu.com.

	[manager.requestSerializer setValue:@"iOS" forHTTPHeaderField:@"system"];
	[manager.requestSerializer setValue:@"popor" forHTTPHeaderField:@"name"];

	manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

	manager.requestSerializer.timeoutInterval = 10.0f;

	return manager;
};

```

```
// 用法示例
[PoporAFNTool url:@"https://www.baidu.com" method:PoporMethodGet parameters:nil success:^(NSString * _Nonnull url, NSData * _Nonnull data, NSDictionary * _Nonnull dic) {

} failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

}];

```

```
0.0.14: 不再默认持有网络监测功能,假如需要网络监测需要 pod 'PoporNetRecord'
并且设置监测回调block.

PoporAFNConfig * config = [PoporAFNConfig share];
config.recordBlock = ^(NSString *url, NSString *title, NSString *method, id head, id parameters, id response) {
    [PoporNetRecord addUrl:url title:title method:method head:head parameter:parameters response:response];
};

```
```
1.02: 应对AFN 4.0 最低iOS9.0

```

## Author

wangkq, 908891024@qq.com

## License

PoporAFN is available under the MIT license. See the LICENSE file for more info.

//
//  FYFJSBridgeManager.h
//  FYFWebComponent
//
//  Created by 范云飞 on 2021/8/19.
//

#import <Foundation/Foundation.h>

#import "FYFWebViewJSBridge.h"

@class FYFWebViewController;

NS_ASSUME_NONNULL_BEGIN

/// jsBridge 管理类
@interface FYFJSBridgeManager : NSObject

+ (FYFJSBridgeManager *)shareInstance;

/// 创建一个JSBridge对象
/// @param webview 绑定的webView
- (FYFWebViewJSBridge *)createBridgeForWebView:(FYFWebView *)webview;

/// 获取当前正在运行浏览器对象
- (FYFWebViewJSBridge *)currentJsBridge;

/// 获取当前正在运行浏览器对象 的控制器
- (FYFWebViewController *)currentWebViewController;

/// 注册浏览器对象
/// @param jsBridge
- (void)registor:(FYFWebViewJSBridge * __nullable)jsBridge;

/// 卸载浏览器对象
/// @param jsBridge
- (void)unregistor:(FYFWebViewJSBridge * __nullable)jsBridge;

/// 清除浏览器对象
/// @param jsBridge
- (void)clear:(FYFWebViewJSBridge * __nullable)jsBridge;

/// 原生主动调用js
/// @param functionNo 功能号
/// @param param 参数
- (void)iosTriggerJSFunctionNo:(NSString * __nonnull)functionNo param:(NSObject * __nullable)param;

@end

NS_ASSUME_NONNULL_END

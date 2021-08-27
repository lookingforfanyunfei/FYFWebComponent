//
//  FYFWebViewJSBridge.h
//  FYFWebComponent
//
//  Created by 范云飞 on 2021/8/18.
//

#import <Foundation/Foundation.h>

#import "FYFWebView.h"

UIKIT_EXTERN NSString *const kJSCallOCMethod; //JS主动调用OC的方法名
UIKIT_EXTERN NSString *const kOCCallBackJSMethod; //JS主动调用OC后，OC回调JS的方法名
UIKIT_EXTERN NSString *const kOCTriggerJSMethod; //OC主动调用JS的方法名

NS_ASSUME_NONNULL_BEGIN

@interface FYFWebViewJSBridge : NSObject

/// jsBridge持有的webview对象
@property (nonatomic, weak, readonly) FYFWebView *webView;
/// jsBridge持有的webview对象的id
@property (nonatomic, copy, readonly) NSString *webViewID;

- (instancetype)initWithWebView:(FYFWebView *)webView;

- (void)clear;

#pragma mark - public

/// 预加载，默认NSURLRequestReloadIgnoringCacheData，即没缓存
/// @param urlString
- (void)prepareLoadUrl:(NSString *)urlString;
- (void)prepareLoadUrl:(NSString *)urlString cachePolicy:(NSURLRequestCachePolicy)cachePolicy;

/// 原生回调js
/// @param flowNo 流水号
/// @param param 参数
- (void)iosCallbackJSFlowNo:(NSString *)flowNo param:(NSObject *)param;

/// 原生主动调用js
/// @param functionNo 方法名
/// @param param 参数
- (void)iosTriggerJSFunctionNo:(NSString *)functionNo param:(NSObject *)param;

@end

NS_ASSUME_NONNULL_END

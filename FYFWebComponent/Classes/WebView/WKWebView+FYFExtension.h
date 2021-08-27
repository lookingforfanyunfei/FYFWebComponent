//
//  WKWebView+FYFExtension.h
//  FYFWebComponent
//
//  Created by 范云飞 on 2021/8/19.
//

#import <WebKit/WebKit.h>

typedef void (^FYFWebViewJSCompletionBlock)(NSObject *result);

NS_ASSUME_NONNULL_BEGIN

@interface WKWebView (FYFExtension)

/// webView关联的 FYFWebViewController
@property (nonatomic, weak, readwrite) NSObject *holderObject;

/// 安全执行js
/// @param script 要执行的js代码
- (void)fyf_safeAsyncEvaluateJavaScriptString:(NSString *)script;

/// 安全执行js
/// @param script 要执行的js代码
/// @param block js执行完成的回调
- (void)fyf_safeAsyncEvaluateJavaScriptString:(NSString *)script completionBlock:(FYFWebViewJSCompletionBlock)block;

@end

NS_ASSUME_NONNULL_END

//
//  FYFWebViewJSBridge.m
//  FYFWebComponent
//
//  Created by 范云飞 on 2021/8/18.
//

#import "FYFWebViewJSBridge.h"

#import <YYModel/YYModel.h>
#import <FYFCategory/NSString+FYFExtension.h>

#import "WKWebView+FYFExtension.h"
#import "FYFJSInvokeCenter.h"

NSString *const kJSCallOCMethod = @"jsCallNative";//JS调用OC
NSString *const kOCCallBackJSMethod = @"nativeCallback";//回调
NSString *const kOCTriggerJSMethod = @"triggerMessage";//OC主动调用

#define KS_REQUEST_TIMEOUT_INTERVAL 10

@interface FYFWebViewJSBridge ()<WKScriptMessageHandler>

@property (nonatomic, weak, readwrite) FYFWebView *webView;

@property (nonatomic, copy, readwrite) NSString *webViewID;

@end

@implementation FYFWebViewJSBridge

- (instancetype)initWithWebView:(FYFWebView *)webView {
    self = [self init];
    if (self) {
        _webViewID = [[NSUUID UUID] UUIDString];
        _webView = webView;
        [_webView.configuration.userContentController addScriptMessageHandler:self name:kJSCallOCMethod];
    }
    return self;
}

- (void)clear {
    if (_webView) {
        [_webView.configuration.userContentController removeScriptMessageHandlerForName:kJSCallOCMethod];
        _webView = nil;
    }
}

- (void)dealloc {
    [self clear];
}

- (void)prepareLoadUrl:(NSString * __nonnull)urlString {
    [self prepareLoadUrl:urlString cachePolicy:NSURLRequestReloadIgnoringCacheData];
}

- (void)prepareLoadUrl:(NSString * __nonnull)urlString cachePolicy:(NSURLRequestCachePolicy)cachePolicy {
    if (!urlString || !urlString.length) {
        return;
    }
    // 暂不支持加载本地文件
    NSURL *webUrl = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:webUrl cachePolicy:cachePolicy timeoutInterval:KS_REQUEST_TIMEOUT_INTERVAL];
    [_webView loadRequest:request];
}

/// 原生回调js
/// @param flowNo 流水号
/// @param param 参数
- (void)iosCallbackJSFlowNo:(NSString * __nonnull)flowNo param:(NSObject * __nullable)param {
    if (!_webView || !flowNo.length) {
        return;
    }

    NSString *paramStr = [param yy_modelToJSONString];
    NSString *methodStr = kOCCallBackJSMethod;
    NSString *javaScriptStr = [NSString stringWithFormat:@"%@('%@',%@)",methodStr, flowNo, paramStr];
    [self.webView fyf_safeAsyncEvaluateJavaScriptString:javaScriptStr completionBlock:^(NSObject *result) {
        NSLog(@"result:%@",[result yy_modelToJSONString]);
    }];
}

/// 原生主动调用js
/// @param functionNo 功能号
/// @param param 参数
- (void)iosTriggerJSFunctionNo:(NSString * __nonnull)functionNo param:(NSObject * __nullable)param {
    if (!_webView || !functionNo.length) {
        return;
    }

    NSString *paramStr = [param yy_modelToJSONString];
    NSString *methodStr = kOCTriggerJSMethod;
    NSString *javaScriptStr = [NSString stringWithFormat:@"%@('%@',%@)",methodStr, functionNo, paramStr];
    [self.webView fyf_safeAsyncEvaluateJavaScriptString:javaScriptStr completionBlock:^(NSObject *result) {
        if (result && [result isKindOfClass:[NSDictionary class]]) {
            [[FYFJSInvokeCenter shareInstance] jsCallBackNativeWithParam:result functionNo:functionNo];
        }
    }];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:kJSCallOCMethod]) {
        id arguments = message.body;
        NSDictionary *userInfo;
        if ([arguments isKindOfClass:[NSDictionary class]]) {
            userInfo =(NSDictionary *)arguments;
        } else if ([arguments isKindOfClass:[NSString class]]) {
            userInfo = [arguments fyf_jsonToDictionary];
        } else {
            
        }
        NSString *funcNo = [userInfo objectForKey:@"funcNo"];
        [[FYFJSInvokeCenter shareInstance] invokePluginWithFunctionNo:funcNo param:userInfo];
    }
}

@end

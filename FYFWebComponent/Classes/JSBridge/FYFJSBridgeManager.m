//
//  FYFJSBridgeManager.m
//  FYFWebComponent
//
//  Created by 范云飞 on 2021/8/19.
//

#import "FYFJSBridgeManager.h"

#import "WKWebView+FYFExtension.h"
#import "FYFWebViewController.h"

@interface FYFJSBridgeManager()

/// webViewID到jsBridge映射的map
@property (atomic,strong)  NSMutableDictionary *webViewIDToJsBridgeMap;
/// 当前运行的webView的id (nsuuid)
@property (nonatomic, copy) NSString *currentWebViewID;

@end

@implementation FYFJSBridgeManager

+ (FYFJSBridgeManager *)shareInstance {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {        
        _webViewIDToJsBridgeMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (FYFWebViewJSBridge *)createBridgeForWebView:(FYFWebView *)webview {
    FYFWebViewJSBridge *jsBridge = [[FYFWebViewJSBridge alloc] initWithWebView:webview];
    [[FYFJSBridgeManager shareInstance] registor:jsBridge];
    return jsBridge;
}

- (FYFWebViewJSBridge *)currentJsBridge {
    FYFWebViewJSBridge *jsBridge = [self.webViewIDToJsBridgeMap objectForKey:self.currentWebViewID];
    return jsBridge;
}

- (FYFWebViewController *)currentWebViewController {
    FYFWebViewJSBridge *currentJsBridge = [self currentJsBridge];
    NSObject *holder = currentJsBridge.webView.holderObject;
    if ([holder isKindOfClass:[UIViewController class]]) {
        return (FYFWebViewController *)holder;
    }
    return nil;
}

- (void)registor:(FYFWebViewJSBridge *)jsBridge {
    if (!jsBridge) {
        return;
    }
    [self.webViewIDToJsBridgeMap setObject:jsBridge forKey:jsBridge.webViewID];
    self.currentWebViewID = jsBridge.webViewID;
}

- (void)unregistor:(FYFWebViewJSBridge *)jsBridge {
    if (jsBridge) {
        [self.webViewIDToJsBridgeMap removeObjectForKey:jsBridge.webViewID];
    }
}

- (void)clear:(FYFWebViewJSBridge *)jsBridge {
    if (jsBridge) {
        [self.webViewIDToJsBridgeMap removeObjectForKey:jsBridge.webViewID];
        [jsBridge clear];
    }
}

- (void)iosTriggerJSFunctionNo:(NSString *)functionNo param:(NSObject *)param {
    FYFWebViewJSBridge *jsBridge = [[FYFJSBridgeManager shareInstance] currentJsBridge];
    if (jsBridge) {
        [jsBridge iosTriggerJSFunctionNo:functionNo param:param];
    }
}

@end

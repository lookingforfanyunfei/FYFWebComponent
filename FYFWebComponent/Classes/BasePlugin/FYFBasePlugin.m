//
//  FYFBasePlugin.m
//  FYFWebComponent
//
//  Created by 范云飞 on 2021/8/23.
//

#import "FYFBasePlugin.h"

#import <FYFDefines/FYFObjectDefine.h>

#import "FYFJSBridgeManager.h"
#import "FYFWebViewJSBridge.h"

@implementation FYFBasePlugin

- (id)init {
    self = [super init];
    if (self) {
        _isCache = YES;
    }
    return self;
}

#pragma mark - FYFJSInvokeNativeDelegate
- (void)serverInvoke:(id)param {
    
}

- (void)iosCallbackJSFlowNo:(NSString *)flowNo param:(NSObject *)param {
    dispatch_main_async_safe( ^{
        FYFWebViewJSBridge *jsBridge = [[FYFJSBridgeManager shareInstance] currentJsBridge];
        if (jsBridge) {
            [jsBridge iosCallbackJSFlowNo:flowNo param:param];
        }
    });
}


@end

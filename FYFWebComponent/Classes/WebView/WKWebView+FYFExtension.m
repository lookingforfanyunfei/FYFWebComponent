//
//  WKWebView+FYFExtension.m
//  FYFWebComponent
//
//  Created by 范云飞 on 2021/8/19.
//

#import "WKWebView+FYFExtension.h"
#import <objc/runtime.h>

/// 解决强引用的中间类
@interface GFWeakWrapper : NSObject

@property(nonatomic, weak, readwrite)NSObject *weakObj;

@end

@implementation GFWeakWrapper

@end

@implementation WKWebView (FYFExtension)

- (void)setHolderObject:(NSObject *)holderObject {
    GFWeakWrapper *wrapObj = objc_getAssociatedObject(self, @selector(setHolderObject:));
    if (wrapObj) {
        wrapObj.weakObj = holderObject;
    } else {
        wrapObj = [[GFWeakWrapper alloc] init];
        wrapObj.weakObj = holderObject;
        objc_setAssociatedObject(self, @selector(setHolderObject:), wrapObj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (NSObject *)holderObject {
    GFWeakWrapper *wrapObj = objc_getAssociatedObject(self, @selector(setHolderObject:));
    return wrapObj.weakObj;
}

- (void)fyf_safeAsyncEvaluateJavaScriptString:(NSString *)script {
    [self fyf_safeAsyncEvaluateJavaScriptString:script completionBlock:nil];
}

- (void)fyf_safeAsyncEvaluateJavaScriptString:(NSString *)script completionBlock:(FYFWebViewJSCompletionBlock)block {
    if(![[NSThread currentThread] isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            //retain self
            __unused __attribute__((objc_ownership(strong))) __typeof__(self) self_retain_ = self;
            [self fyf_safeAsyncEvaluateJavaScriptString:script completionBlock:block];
        });
        return;
    }
    
    if (!script || script.length <= 0) {
        NSLog(@"invalid script");
        if (block) {
            block(@"");
        }
        return;
    }

    [self evaluateJavaScript:script completionHandler:^(id result, NSError *_Nullable error) {
        //retain self
        __unused __attribute__((objc_ownership(strong))) __typeof__(self) self_retain_ = self;
               
        if (!error) {
            if (block) {
                NSObject *resultObj = @"";
                if (!result || [result isKindOfClass:[NSNull class]]) {
                    resultObj = @"";
                } else if ([result isKindOfClass:[NSNumber class]]) {
                    resultObj = ((NSNumber *)result).stringValue;
                } else if ([result isKindOfClass:[NSObject class]]){
                    resultObj = (NSObject *)result;
                } else {
                    NSLog(@"evaluate js return type:%@, js:%@",
                             NSStringFromClass([result class]),
                             script);
                }
                if (block) {
                    block(resultObj);
                }
            }
        } else {
            NSLog(@"evaluate js Error : %@ %@", error.description, script);
            if (block) {
                block(@"");
            }
        }
    }];
}

@end

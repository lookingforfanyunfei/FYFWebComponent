//
//  FYFBasePlugin.h
//  FYFWebComponent
//
//  Created by 范云飞 on 2021/8/23.
//

#import <Foundation/Foundation.h>

#import "FYFJSInvokeNativeDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface FYFBasePlugin : NSObject <FYFJSInvokeNativeDelegate>

/// 是否需要缓存插件, 默认为YES
@property (nonatomic, assign, readonly) BOOL isCache;

/// 请求流水号
@property (nonatomic, copy) NSString *flowNo;

/// 原生回调js
/// @param flowNo 流水号
/// @param param 参数
- (void)iosCallbackJSFlowNo:(NSString *)flowNo param:(NSObject *)param;

@end

NS_ASSUME_NONNULL_END

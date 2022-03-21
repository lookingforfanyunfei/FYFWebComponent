//
//  FYFJSInvokeCenter.h
//  FYFWebComponent
//
//  Created by 范云飞 on 2021/8/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// js调用原生的触发类型
@interface FYFJSInvokeCenter : NSObject

+ (instancetype)shareInstance;

/// js调用native方法入口
/// @param params 方法参数

/// js调用native方法入口
/// @param funcNo 功能号
/// @param param 参数
- (void)invokePluginWithFunctionNo:(NSString * __nonnull)functionNo param:(id __nullable)param;

/// js回调原生
/// @param param 参数
/// @param functionNo functionNo
- (void)jsCallBackNativeWithParam:(NSDictionary * __nullable)param functionNo:(NSString * __nonnull)functionNo;

@end

NS_ASSUME_NONNULL_END

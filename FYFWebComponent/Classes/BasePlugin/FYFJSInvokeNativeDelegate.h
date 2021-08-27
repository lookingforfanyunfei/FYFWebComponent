//
//  FYFJSInvokeNativeDelegate.h
//  FYFWebComponent
//
//  Created by 范云飞 on 2021/8/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// js调用原生的协议
@protocol FYFJSInvokeNativeDelegate <NSObject>

@required
/// js调用原生的协议方法
/// @param param 参数
- (void)serverInvoke:(id)param;

@end

NS_ASSUME_NONNULL_END

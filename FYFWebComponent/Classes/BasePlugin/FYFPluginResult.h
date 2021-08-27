//
//  FYFPluginResult.h
//  FYFWebComponent
//
//  Created by 范云飞 on 2021/8/23.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FYFPLUGIN_ERROR_NO) {
    FYFPLUGIN_ERROR_NO_SUCCESS                 =   0,    //成功
    FYFPLUGIN_ERROR_NO_NOT_EXIST               =   -1,   //不存在对应的插件
    FYFPLUGIN_ERROR_NO_ILLEGAL_INPUT_PARAMS    =   -2,   //不合法的入参
    FYFPLUGIN_ERROR_NO_ILLEGAL_REQUEST_FAILURE =   -3,   //网络请求失败
    FYFPLUGIN_ERROR_NO_ILLEGAL_SERVER_RESPONSE =   -4,   //服务器返回的信息解析失败
    FYFPLUGIN_ERROR_NO_FAILED                  =   -5,   //消息号处理失败
    FYFPLUGIN_ERROR_NO_PERMISSIONS             =   -6,   //域名权限不足
    FYFPLUGIN_ERROR_NO_USER_PERMISSIONS        =   -7,   //系统权限不足
    FYFPLUGIN_ERROR_NO_DEFAULT                 =   -999  //消息号处理失败
};


NS_ASSUME_NONNULL_BEGIN

@interface FYFPluginResult : NSObject

/// 错误号
@property (nonatomic, assign) FYFPLUGIN_ERROR_NO errorNo;

/// 错误信息
@property (nonatomic, copy) NSString *errorInfo;

/// 结果集
@property (nonatomic, strong) NSObject *results;

@end

NS_ASSUME_NONNULL_END

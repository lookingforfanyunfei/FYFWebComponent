//
//  FYFPluginResult.m
//  FYFWebComponent
//
//  Created by 范云飞 on 2021/8/23.
//

#import "FYFPluginResult.h"

@implementation FYFPluginResult

- (instancetype)init {
    if (self = [super init]) {
        _errorNo = FYFPLUGIN_ERROR_NO_DEFAULT;
        _errorInfo = @"消息号处理失败";
        _results = nil;
    }
    return self;
}


@end

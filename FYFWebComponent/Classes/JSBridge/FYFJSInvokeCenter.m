//
//  FYFJSInvokeCenter.m
//  FYFWebComponent
//
//  Created by 范云飞 on 2021/8/19.
//

#import "FYFJSInvokeCenter.h"

#import "FYFJSBridgeManager.h"
#import "FYFWebViewController.h"
#import "FYFBasePlugin.h"
#import "FYFJSInvokeNativeDelegate.h"

static NSString *const FYFPluginPrefix = @"FYFPlugin";

@interface FYFJSInvokeCenter ()

/// 功能号到插件名的映射
@property (nonatomic, strong) NSMutableDictionary *functionNoToPluginNameMap;
/// 功能号到插件对象的映射
@property (nonatomic, strong) NSMutableDictionary *functionNoToPluginObjectMap;

@end

@implementation FYFJSInvokeCenter

+ (instancetype)shareInstance {
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
        self = [super init];
        if (self) {
            _functionNoToPluginNameMap = [NSMutableDictionary dictionary];
            _functionNoToPluginObjectMap = [NSMutableDictionary dictionary];
        }
    }
    return self;
}

- (void)invokePluginWithFunctionNo:(NSString *)functionNo param:(id)param {
    [self _invokeNativeWithParam:param functionNo:functionNo];
}

- (void)jsCallBackNativeWithParam:(NSDictionary *)param functionNo:(NSString *)functionNo {
    [self _invokeNativeWithParam:param functionNo:functionNo];
}

- (void)_invokeNativeWithParam:(NSDictionary *)param functionNo:(NSString *)functionNo {
    if (!functionNo.length) {
        return;
    }
    
    if (!param) {
        param = [NSMutableDictionary dictionary];
    }
    
    NSString *pluginName = [_functionNoToPluginNameMap objectForKey:functionNo];
    if (!pluginName.length) {
        //根据功能号和前缀拼接pluginName规则，例如：FYFPlugin100000
        pluginName = [NSString stringWithFormat:@"%@%@",FYFPluginPrefix,functionNo];
        [_functionNoToPluginNameMap setObject:pluginName forKey:functionNo];
    }
    
    Class class = NSClassFromString(pluginName);
    //判断是否存在实例插件
    if (class) {
        id<FYFJSInvokeNativeDelegate> plugin = (id<FYFJSInvokeNativeDelegate>)[_functionNoToPluginObjectMap objectForKey:functionNo];
        if (!plugin) {
            plugin = [[class alloc] init];
            if ([plugin isKindOfClass:[FYFBasePlugin class]] && ((FYFBasePlugin *)plugin).isCache) {
                [_functionNoToPluginObjectMap setObject:plugin forKey:functionNo];
            }
        }
        if ([plugin isKindOfClass:[FYFBasePlugin class]]) {
            if ([param isKindOfClass:[NSDictionary class]]) {
                ((FYFBasePlugin *)plugin).flowNo = [((NSDictionary *)param)objectForKey:@"flowNo"];
            }
        }
        [plugin serverInvoke:param];
    } else {
        NSString *error = [NSString stringWithFormat:@"插件[%@]对应的类不存在!",pluginName];
        NSLog(error);
    }
}

@end

//
//  FYFWebViewController.h
//  FYFWebComponent
//
//  Created by 范云飞 on 2021/8/18.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, FYFWebNativeNavBarStyle) {
    FYFWebNativeNavBarStyleDefault, //默认
    FYFWebNativeNavBarStyleWhite //白底
};

NS_ASSUME_NONNULL_BEGIN

/// 导航栏封装完善的Web容器类
@interface FYFWebViewController : UIViewController

/// 是否使用native导航栏，默认为NO，即webview自带导航栏
@property (nonatomic, assign) BOOL isUseNativeNavBar;

/// native导航栏的 标题
@property (nonatomic, strong) NSString *navTitle;

/// 展示导航栏分享按钮 YES是 NO不是
@property (nonatomic, assign) BOOL showShareItem;

/// 默认 FYFWebNativeNavBarStyleDefault
@property (nonatomic, assign) FYFWebNativeNavBarStyle navBarStyle;

/// webView url 地址
@property (nonatomic, copy) NSString *webViewUrl;

- (instancetype)initWebViewUrl:(NSString *)webViewUrl;

/// 设置动态显示隐藏导航栏
/// @param show YES:显示， NO:隐藏
- (void)setNativeNavigationBarShow:(BOOL)show;

/// 关闭当前H5页面
- (void)closeCurrentWebView;

/// 返回上一级
- (void)goBack;

@end

NS_ASSUME_NONNULL_END

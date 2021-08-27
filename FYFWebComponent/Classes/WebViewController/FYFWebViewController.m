//
//  FYFWebViewController.m
//  FYFWebComponent
//
//  Created by 范云飞 on 2021/8/18.
//

#import "FYFWebViewController.h"

#import <Masonry/Masonry.h>
#import <FYFDefines/FYFViewDefine.h>
#import <FYFDefines/FYFColorDefine.h>
#import <FYFDeviceInfo/FYFDeviceHelper.h>

#import "UIImage+FYFWebImageNamed.h"
#import "FYFWebView.h"
#import "FYFWebViewJSBridge.h"
#import "WKWebView+FYFExtension.h"
#import "FYFJSBridgeManager.h"

NSString * const FYFScheme = @"FYF";
NSString * const FYFShareFunctionNo = @"100001";

@interface FYFWebViewController ()
<WKNavigationDelegate,
WKUIDelegate,
UIGestureRecognizerDelegate>

/// 当前的webView
@property (nonatomic, strong) FYFWebView *webView;
/// 当前的jsBridge
@property (nonatomic, weak) FYFWebViewJSBridge *jsBridge;
/// 原生导航栏
@property (nonatomic, strong) UIView *navView;
/// 进度条
@property (nonatomic, strong) UIProgressView *progressView;
/// 刷新按钮
@property (nonatomic, strong) UIButton *refreshButton;

@end

@implementation FYFWebViewController

- (void)dealloc {
    [[FYFJSBridgeManager shareInstance] clear:self.jsBridge];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress" context:nil];
    [self.webView removeObserver:self forKeyPath:@"title" context:nil];
    [self.webView removeObserver:self forKeyPath:@"canGoBack" context:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.webView.navigationDelegate = nil;
    self.webView = nil;
    self.jsBridge = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _isUseNativeNavBar = NO;
        _navBarStyle = FYFWebNativeNavBarStyleDefault;
    }
    return self;
}

- (instancetype)initWebViewUrl:(NSString *)webViewUrl {
    if (self = [super init]) {
        _webViewUrl = webViewUrl;
        _isUseNativeNavBar = NO;
        _navBarStyle = FYFWebNativeNavBarStyleDefault;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.jsBridge = [[FYFJSBridgeManager shareInstance] createBridgeForWebView:self.webView];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionNew context:nil];
    if (self.isUseNativeNavBar) {
        self.title = self.navTitle;
    } else {
        [self.view addSubview:self.navView];
    }
    [self addNavgationLeftItem];
    [self addNavgationRightItem];

    [self.view addSubview:self.webView];
    [self.view addSubview:self.progressView];
    [self addRefreshButton];
    
    if (self.webViewUrl && self.webViewUrl.length) {
        [self.jsBridge prepareLoadUrl:self.webViewUrl];
    }

    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeOrientation) name:UIWindowDidBecomeHiddenNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.isUseNativeNavBar) {
        [self.navigationController setNavigationBarHidden:YES animated:animated];
    }

    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}];
    
    [[FYFJSBridgeManager shareInstance] registor:self.jsBridge];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (!self.isUseNativeNavBar) {
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

// 退出全屏
- (void)changeOrientation {
    //ios13以下导航栏会向上偏移,需要给他恢复到原来的位置
    CGRect navFrame = self.navigationController.navigationBar.frame;
    navFrame.origin.y = FYFStatusBarHeight;
    self.navigationController.navigationBar.frame = navFrame;
    
    //强制归正到竖屏：不然会影响外部页面布局
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val =UIInterfaceOrientationPortrait;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

- (void)addRefreshButton {
#ifdef DEBUG
    [self refreshButton];
#endif
}

#pragma mark - 导航按钮
- (void)addNavgationLeftItem {
    self.navigationItem.leftBarButtonItem = nil;
    UIView *leftView = [[UIView alloc] init];
    UIButton *backButton = [self createButtonWithImageOffset:-10.f imageName:@"fyf_web_back_icon" action:@selector(goBack)];
    backButton.frame = CGRectMake(0.f, 0.f, 32.f, FYFNavigationBarHeight);
    [leftView addSubview:backButton];
    CGFloat leftViewW = 32.f;
    if ([self.webView canGoBack]) {
        UIButton *closeButton = [self createButtonWithImageOffset:-2.f imageName:@"fyf_web_close_icon" action:@selector(closeCurrentWebView)];
        closeButton.frame = CGRectMake(28.f, 0.f, 32.f, FYFNavigationBarHeight);
        [leftView addSubview:closeButton];
        leftViewW = 60.f;
    }
    leftView.frame = CGRectMake(0, 0, leftViewW, FYFNavigationBarHeight);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftView];
}

- (void)addNavgationRightItem {
    if (self.showShareItem) {
        UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithImage:[UIImage fyf_webImageNamed:@"fyf_web_share_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(shareClick)];
        self.navigationItem.rightBarButtonItem = shareItem;
    }
}

- (UIButton *)createButtonWithImageOffset:(CGFloat)offset imageName:(NSString *)imageName action:(SEL)selector {
    UIButton *button = [[UIButton alloc] init];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0.f, offset, 0.f, 0.f)];
    [button setImage:[UIImage fyf_webImageNamed:imageName] forState:UIControlStateNormal];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)goBack {
    if([self.webView canGoBack] || self.webView.backForwardList.backList.count > 0) {
        //单一个canGoBack不准确
        [self.webView goBack];
    } else {
        [self closeCurrentWebView];
    }
}

//这个方法让H5直接关闭当前webview，无论H5里面进入基层H5页面
- (void)closeCurrentWebView {
    if (self.presentingViewController && self.navigationController.viewControllers.count == 1) {
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)shareClick {
    //主动调用js获取分享信息，然后在js回调结果中唤起分享组件
    [[FYFJSBridgeManager shareInstance] iosTriggerJSFunctionNo:FYFShareFunctionNo param:nil];
}

#pragma mark - public Methods
- (void)setWebViewUrl:(NSString *)webViewUrl {
    _webViewUrl = webViewUrl;
    if (!webViewUrl && !webViewUrl.length) {
        return;
    }
    [self.jsBridge prepareLoadUrl:webViewUrl];
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
    CFDataRef exceptions = SecTrustCopyExceptions(serverTrust);
    SecTrustSetExceptions(serverTrust, exceptions);
    CFRelease(exceptions);
    
    completionHandler(NSURLSessionAuthChallengeUseCredential,[NSURLCredential credentialForTrust:serverTrust]);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *URL = navigationAction.request.URL;
    NSString *scheme = [URL scheme];
    if ([scheme isEqualToString:FYFScheme]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSString *screenInfojs = [NSString stringWithFormat:@"var h5InitData = {}; h5InitData.screen_info = '%@'; h5InitData.status_bar_padding='%@';",[FYFDeviceHelper fyf_getSystemName], @(FYFSysStatusBarHeight)];
    [self.webView fyf_safeAsyncEvaluateJavaScriptString:screenInfojs];
    
    self.navView.hidden = NO;
    self.progressView.hidden = NO;
    [self.view bringSubviewToFront:self.progressView];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%@", webView.URL.absoluteString);
        
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    // 浏览器导航栏是白色的，出现会闪烁，加个延迟效果
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.navView.hidden = YES;
    });
    
    //禁止web内长按图片放大功能
    [webView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:nil];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.progressView.hidden = YES;
    self.webView.scrollView.scrollEnabled = YES;
    [self showErrorViewWithError:error];
}

- (void)showErrorViewWithError:(NSError *)error {
    NSString *message = @"页面出错了,请稍后再试";
    if (error.code == -1009) {
        message = @"内容加载失败,请检查当前网络";
    }
    NSLog(@"message:%@",message);
    
    //可以再次添加错误占位图，并进行重试
}

#pragma mark - WKUIDelegate

/// web界面中有弹出警告框时调用
/// @param webView 实现该代理的webview
/// @param message 警告框中的内容
/// @param completionHandler 警告框选择之后回调
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

/// web界面中有确认框时调用
/// @param webView 实现该代理的webview
/// @param message 确认框中的内容
/// @param completionHandler 确认框选择之后回调
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    //解决内部链接无法打开问题
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.webView canGoBack]) {
        return NO;
    }
    return YES;
}

#pragma mark - KVO Progress
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        [self.progressView setAlpha:1.0];
        [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
        if (self.progressView.progress >= 1) {
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0];
            } completion:^(BOOL finished) {
                self.progressView.hidden = YES;
                [self.progressView setProgress:0.0 animated:NO];
            }];
        }
    } else if ([keyPath isEqualToString:@"title"]) {
        if (object == self.webView) {
            if (self.navTitle.length > 0 && self.webViewUrl.length > 0 && [self.webView.URL.absoluteString containsString:self.webViewUrl] == YES) {
                self.navigationItem.title = self.navTitle;
                return;
            }
            self.navigationItem.title = self.webView.title;
        } else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    } else if ([keyPath isEqualToString:@"canGoBack"]) {
        [self addNavgationLeftItem];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setNativeNavigationBarShow:(BOOL)show {
    if (self.isUseNativeNavBar != show) {
        self.isUseNativeNavBar = show;
        if (self.isUseNativeNavBar) {
            self.webView.frame = CGRectMake(0, FYFSafeArea_TopBarHeight, FYFScreenWidth, FYFScreenHeight - FYFSafeArea_TopBarHeight);
        } else {
            self.webView.frame = CGRectMake(0, FYFStatusBarHeight, FYFScreenWidth, FYFScreenHeight);
        }
        
        [self.view setNeedsLayout];
        [self.navigationController setNavigationBarHidden:!show animated:NO];
    }
}

#pragma mark - Private Methods
- (void)close {
    if (self.navigationController.viewControllers.count == 1) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)updateStatusBarStyle {
    if (self.navBarStyle == FYFWebNativeNavBarStyleDefault) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
        if (@available(iOS 13.0,*)) {
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
        }
    }
}

- (void)refreshClick {
    if (self.webView.URL.absoluteString.length > 0) {
        [self.webView reload];
    }
}

#pragma mark - Getters
- (FYFWebView *)webView {
    if (!_webView) {
        _webView = [[FYFWebView alloc] init];
        _webView.holderObject = self;
        if (self.isUseNativeNavBar) {
            _webView.frame = CGRectMake(0, FYFSafeArea_TopBarHeight, FYFScreenWidth, FYFScreenHeight - FYFSafeArea_TopBarHeight);
        } else {
            _webView.frame = CGRectMake(0, 0, FYFScreenWidth, FYFScreenHeight);
        }
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.opaque = NO;
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        _webView.allowsBackForwardNavigationGestures = NO;
        _webView.scrollView.scrollEnabled = YES;
        _webView.scrollView.bounces = NO;
        if (@available(iOS 11.0, *)) {
            _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        // 设置UA
        [self setWebViewUA];
    }
    return _webView;
}

- (UIView *)navView {
    if (!_navView) {
        _navView = [UIView new];
        _navView.backgroundColor = [UIColor whiteColor];
        _navView.frame = CGRectMake(0, 0, FYFScreenWidth, FYFSafeArea_TopBarHeight);
        
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(0, FYFSysStatusBarHeight, 40, FYFSafeArea_NavBarHeight);
        [backButton setImage:[UIImage fyf_webImageNamed:@"fyf_appicon_navback"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        
        [_navView addSubview:backButton];
    }
    return _navView;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        if (self.isUseNativeNavBar) {
            _progressView.frame = CGRectMake(0, FYFNavigationBarFullHeight - 1, [[UIScreen mainScreen] bounds].size.width, 2);
        } else {
            _progressView.frame = CGRectMake(0, -1, [[UIScreen mainScreen] bounds].size.width, 2);
        }
        
        _progressView.transform = CGAffineTransformMakeScale(1.0f, 0.5);
        _progressView.progressTintColor = FYFColorFromRGB(0x00BF13);
    }
    return _progressView;
}

- (void)setWebViewUA {
    //此部分内容需放到setWebUI内
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *customUA = [NSString stringWithFormat:@"KingStar/APP/iOS/%@", version];
    if (@available(iOS 12.0, *)){
        //由于iOS12的UA改为异步，所以不管在js还是客户端第一次加载都获取不到，所以此时需要先设置好再去获取（1、如下设置；2、先在AppDelegate中设置到本地）
        NSString *userAgent = [self.webView valueForKey:@"applicationNameForUserAgent"];
        NSString *newUserAgent = [NSString stringWithFormat:@"%@%@", userAgent, customUA];
        
        if ([newUserAgent containsString: customUA] == NO) {
            [self.webView setValue:newUserAgent forKey:@"applicationNameForUserAgent"];
        }
    }
    [self.webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSString *userAgent = result;
        if ([userAgent rangeOfString:customUA].location != NSNotFound) {
            return ;
        }
        NSString *newUserAgent = [userAgent stringByAppendingString:customUA];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:newUserAgent, @"UserAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //不添加以下代码则只是在本地更改UA，网页并未同步更改
        if (@available(iOS 9.0, *)) {
            [self.webView setCustomUserAgent:newUserAgent];
        } else {
            [self.webView setValue:newUserAgent forKey:@"applicationNameForUserAgent"];
        }
    }]; //加载请求必须同步在设置UA的后面
}

- (UIButton *)refreshButton {
    if (!_refreshButton) {
        _refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_refreshButton setTitle:@"刷新" forState:UIControlEventTouchUpInside];
        [_refreshButton setImage:[UIImage fyf_webImageNamed:@"fyf_web_refresh_icon"] forState:UIControlStateNormal];
        [_refreshButton addTarget:self action:@selector(refreshClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_refreshButton];
        
        [_refreshButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-20);
            make.width.height.mas_equalTo(60);
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-150);
            } else {
                make.bottom.equalTo(self.view).offset(-150);
            }
        }];
    }
    return _refreshButton;
}

@end

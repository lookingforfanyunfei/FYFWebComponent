//
//  FYFViewController.m
//  FYFWebComponent
//
//  Created by 786452470@qq.com on 08/27/2021.
//  Copyright (c) 2021 786452470@qq.com. All rights reserved.
//

#import "FYFViewController.h"
#import <FYFWebComponent/FYFWebViewController.h>

@interface FYFViewController ()

@end

@implementation FYFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIButton *htmlButton = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame) - 80)/2, 200, 80, 30)];
    [htmlButton setTitle:@"资源文件" forState:UIControlStateNormal];
    [htmlButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [htmlButton addTarget:self action:@selector(htmlClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:htmlButton];
}

- (void)htmlClick {

    FYFWebViewController *webVC = [[FYFWebViewController alloc] initWebViewUrl:@"https://luna.gtjaqh.com/news-static/html/2021/0825/af7c33e841a0e3bc02cabf66b590e2e5.html"];
    webVC.isUseNativeNavBar = YES;
    webVC.showShareItem = YES;
    
    [self.navigationController pushViewController:webVC animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

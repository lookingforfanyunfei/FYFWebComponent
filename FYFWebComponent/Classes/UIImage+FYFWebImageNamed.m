//
//  UIImage+FYFWebImageNamed.m
//  
//
//  Created by 范云飞 on 2021/8/20.
//

#import "UIImage+FYFWebImageNamed.h"

@implementation UIImage (FYFWebImageNamed)

+ (UIImage *)fyf_webImageNamed:(NSString *)name {
    static NSBundle *webBundle = nil;
    if (!webBundle) {
        NSString *bundlePath = [[NSBundle bundleForClass:NSClassFromString(@"FYFWebComponent")].resourcePath stringByAppendingPathComponent:@"FYFWebComponent.bundle"];
        webBundle = [NSBundle bundleWithPath:bundlePath];
    }
    return [self fyf_webImageNamed:name inBundle:webBundle];
}

+ (UIImage *)fyf_webImageNamed:(NSString *)name inBundle:(NSBundle *)bundle {
    UIImage *resultImage = nil;
    if (bundle) {
        resultImage = [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    } else {
        resultImage = [UIImage imageNamed:name];
    }
    return resultImage;
}

@end

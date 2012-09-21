//
//  UIView+Loading.h
//  VOA
//
//  Created by yangzexin on 12-2-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIViewController (Loading)

- (void)setLoading:(BOOL)loading;
- (void)setLoading:(BOOL)loading message:(NSString *)msg;

- (void)setWaiting:(BOOL)loading;

- (void)setDownloading:(BOOL)loading;
- (void)setDownloadingPercent:(float)percent;

- (void)setLoading:(BOOL)loading 
         labelText:(NSString *)text 
    indicatorWidth:(CGFloat)indicatorWid
    hideOtherViews:(BOOL)hide
    showBackground:(BOOL)show;

- (void)setCenterLabelText:(NSString *)text;
- (void)hideCenterLabelText;

@end

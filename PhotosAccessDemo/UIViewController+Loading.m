//
//  UIView+Loading.m
//  VOA
//
//  Created by yangzexin on 12-2-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIViewController+Loading.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIViewController (Loading)

- (void)setLoading:(BOOL)loading
{
    [self setLoading:loading 
           labelText:NSLocalizedString(@"loading", nil) 
      indicatorWidth:24.0f
      hideOtherViews:YES 
      showBackground:NO];
}
- (void)setLoading:(BOOL)loading message:(NSString *)msg
{
    [self setLoading:loading 
           labelText:msg 
      indicatorWidth:24.0f
      hideOtherViews:NO 
      showBackground:YES];    
}

- (void)setWaiting:(BOOL)loading
{
    [self setLoading:loading 
           labelText:NSLocalizedString(@"loading", nil) 
      indicatorWidth:24.0f
      hideOtherViews:NO
      showBackground:YES];
}

- (void)setDownloading:(BOOL)loading
{
    [self setLoading:loading 
           labelText:NSLocalizedString(@"downloading", nil) 
      indicatorWidth:24.0f
      hideOtherViews:NO
      showBackground:YES];
}

- (void)setDownloadingPercent:(float)percent
{
    [self setLoading:YES 
           labelText:[NSString stringWithFormat:@"%.0f%%", percent * 100] 
      indicatorWidth:24.0f
      hideOtherViews:NO
      showBackground:YES];
}

static NSInteger TAG = 2277;
static NSInteger TAG_ROUND_RECT = 2276;
static NSInteger TAG_LABEL = 2278;
static NSInteger TAG_INDICATOR = 2279;

- (void)setLoading:(BOOL)loading 
         labelText:(NSString *)text 
    indicatorWidth:(CGFloat)indicatorWid
    hideOtherViews:(BOOL)hideOtherViews
    showBackground:(BOOL)showBackground
{
    UIView *loadingView = [self.view viewWithTag:TAG];
    UIView *roundRectView = nil;
    UILabel *label = nil;
    UIActivityIndicatorView *indicator = nil;
    if(!loadingView){
        // 创建loadingView
        loadingView = [[[UIView alloc] init] autorelease];
        loadingView.tag = TAG;
        loadingView.clipsToBounds = YES;
        [self.view addSubview:loadingView];
        
        roundRectView = [[[UIView alloc] init] autorelease];
        roundRectView.backgroundColor = [UIColor blackColor];
        roundRectView.tag = TAG_ROUND_RECT;
        roundRectView.layer.cornerRadius = 10.0f;
        roundRectView.alpha = 0.72f;
        [loadingView addSubview:roundRectView];
        
        label = [[[UILabel alloc] init] autorelease];
        label.tag = TAG_LABEL;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:14.0f];
        [loadingView addSubview:label];
        
        indicator = [[[UIActivityIndicatorView alloc] init] autorelease];
        indicator.tag = TAG_INDICATOR;
        [loadingView addSubview:indicator];
    }else{
        roundRectView = [loadingView viewWithTag:TAG_ROUND_RECT];
        label = (UILabel*)[loadingView viewWithTag:TAG_LABEL];
        indicator = (UIActivityIndicatorView *)[loadingView viewWithTag:TAG_INDICATOR];
    }
    
    if(hideOtherViews){
        loadingView.backgroundColor = [UIColor whiteColor];
    }else{
        loadingView.backgroundColor = [UIColor clearColor];
    }
    roundRectView.hidden = !showBackground;
    if(showBackground){
        label.textColor = [UIColor whiteColor];
    }else{
        label.textColor = [UIColor blackColor];
    }
    label.text = text;
    if(showBackground){
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    }else{
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    }
    
    loadingView.hidden = !loading;
    if(loading){
        [self.view bringSubviewToFront:loadingView];
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if(UIInterfaceOrientationIsLandscape(orientation)){
            loadingView.frame = CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width);
        }else{
            loadingView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        }
        CGFloat labelWid = [label.text sizeWithFont:label.font].width;
        CGFloat leftEdge = (loadingView.frame.size.width - labelWid - indicatorWid) / 2;
        CGFloat topEdge = (loadingView.frame.size.height - indicatorWid) / 2;
        
        if(indicatorWid == 0){
            [indicator stopAnimating];
        }else{
            indicator.frame = CGRectMake(leftEdge, topEdge, indicatorWid, indicatorWid);
            [indicator startAnimating];
        }
        
        CGFloat labelAdditionalY = (indicatorWid - label.font.lineHeight) / 2;
        label.frame = CGRectMake(leftEdge + indicatorWid, 
                                 topEdge + labelAdditionalY, 
                                 labelWid, 
                                 label.font.lineHeight);
        
        CGFloat roundRectPadding = 5;
        CGFloat roundRectWidth = labelWid + indicatorWid + roundRectPadding * 2;
        CGFloat verticalCenter = label.frame.origin.y + label.frame.size.height / 2;
        CGFloat roundRectY = verticalCenter - roundRectWidth / 2;
        roundRectView.frame = CGRectMake(leftEdge - roundRectPadding, 
                                         roundRectY, roundRectWidth, roundRectWidth);
        
    }else{
        [indicator stopAnimating];
    }
}

- (void)setCenterLabelText:(NSString *)text
{
    [self setLoading:YES 
           labelText:text 
      indicatorWidth:0 
      hideOtherViews:YES 
      showBackground:NO];
}
- (void)hideCenterLabelText
{
    [self setLoading:NO];
}

@end

//
//  UIViewController+Alert.m
//  VOA
//
//  Created by yangzexin on 12-3-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIViewController+Alert.h"

@implementation UIViewController (Alert)

- (void)alert:(NSString *)string
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
                                                    message:string 
                                                   delegate:nil 
                                          cancelButtonTitle:@"确定" 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

@end

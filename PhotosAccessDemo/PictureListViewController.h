//
//  PictureListViewController.h
//  PhotosAccessDemo
//
//  Created by yangzexin on 12-4-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PictureListViewController : UIViewController {
    UITableView *_tableView;
    
    NSMutableArray *_fileNameList;
    NSMutableArray *_importQueue;
}

@end

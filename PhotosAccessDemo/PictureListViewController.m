//
//  PictureListViewController.m
//  PhotosAccessDemo
//
//  Created by yangzexin on 12-4-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PictureListViewController.h"

#define ALERT_VIEW_IMPORT 0x01
#define ALERT_VIEW_DELETE 0x02

@interface PictureListViewController () <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property(nonatomic, retain)UITableView *tableView;
@property(nonatomic, retain)NSMutableArray *fileNameList;
@property(nonatomic, retain)NSMutableArray *importQueue;

- (NSString *)documentPath;
- (void)loadFileNameList;
- (void)runSaveImage;
- (void)runSaveImageStarted;
- (void)runSaveImageFinished:(NSError *)error;
- (void)confirmImportImages;

@end

@implementation PictureListViewController

@synthesize tableView = _tableView;
@synthesize fileNameList = _fileNameList;
@synthesize importQueue = _importQueue;

#pragma mark - instance methods
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_tableView release];
    [_importQueue release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    
    self.title = NSLocalizedString(@"title_pictures", nil);
    
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(onApplicationEnterForground:) 
                                                 name:UIApplicationWillEnterForegroundNotification 
                                               object:nil];
    [self loadFileNameList];
    [self.tableView reloadData];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    self.tableView = nil;
}
- (void)loadView
{
    [super loadView];
    
    CGRect frame;
    
    self.tableView = [[[UITableView alloc] init] autorelease];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = self.view.frame.size.width;
    frame.size.height = self.view.frame.size.height;
    self.tableView.frame = frame;
    self.tableView.autoresizingMask = 
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
    
    UIBarButtonItem *actionBtn = [[[UIBarButtonItem alloc] init] autorelease];
    actionBtn.target = self;
    actionBtn.action = @selector(onActionBtnTapped);
    actionBtn.title = NSLocalizedString(@"import_all", nil);
    self.navigationItem.rightBarButtonItem = actionBtn;
    
    UIBarButtonItem *deleteAllBtn = [[[UIBarButtonItem alloc] init] autorelease];
    deleteAllBtn.target = self;
    deleteAllBtn.action = @selector(onDeleteAllBtnTapped);
    deleteAllBtn.title = NSLocalizedString(@"delete_all", nil);
    self.navigationItem.leftBarButtonItem = deleteAllBtn;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark - events
- (void)onApplicationEnterForground:(NSNotification *)n
{
    [self loadFileNameList];
    [self.tableView reloadData];
}
- (void)onActionBtnTapped
{
    NSMutableArray *queue = [NSMutableArray array];
    for(NSInteger i = 0; i < self.fileNameList.count; ++i){
        [queue addObject:[NSNumber numberWithInt:i]];
    }
    self.importQueue = queue;

    [self confirmImportImages];
}
- (void)onDeleteAllBtnTapped
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"confirm_delete_image", nil) 
                                                    message:nil 
                                                   delegate:self 
                                          cancelButtonTitle:NSLocalizedString(@"alert_approve", nil) 
                                          otherButtonTitles:NSLocalizedString(@"alert_cancel", nil), nil];
    alert.tag = ALERT_VIEW_DELETE;
    [alert show];
    [alert release];
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    [self performSelectorOnMainThread:@selector(runSaveImageFinished:) 
                           withObject:error 
                        waitUntilDone:YES];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == ALERT_VIEW_IMPORT){
        if(buttonIndex == 0){
            // save image to photos
            if([self.importQueue count] != 0){
                [NSThread detachNewThreadSelector:@selector(runSaveImage) toTarget:self withObject:nil];
            }
        }else{
            self.importQueue = nil;
        }
    }else if(alertView.tag == ALERT_VIEW_DELETE){
        if(buttonIndex == 0){
            for(NSString *fileName in self.fileNameList){
                NSString *filePath = [self.documentPath stringByAppendingPathComponent:fileName];
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            }
            [self loadFileNameList];
            [self.tableView reloadData];
        }
    }
}

#pragma mark - private methods
- (NSString *)documentPath
{
    NSString *documentPath 
        = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return documentPath;
}
- (void)loadFileNameList
{
    self.fileNameList = [NSMutableArray array];
    [self.fileNameList addObjectsFromArray:
        [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.documentPath error:nil]];
}
- (void)runSaveImage
{
    @autoreleasepool {
        [self performSelectorOnMainThread:@selector(runSaveImageStarted) 
                               withObject:nil 
                            waitUntilDone:YES];
        NSNumber *firstImageIdx = [self.importQueue objectAtIndex:0];
        NSInteger index = [firstImageIdx intValue];
        [self.importQueue removeObjectAtIndex:0];
        NSString *fileName = [self.fileNameList objectAtIndex:index];
        NSString *filePath = [self.documentPath stringByAppendingPathComponent:fileName];
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}
- (void)runSaveImageStarted
{
    [self setLoading:YES message:NSLocalizedString(@"msg_saving", nil)];
}
- (void)runSaveImageFinished:(NSError *)error
{
    if(error){
    }else{
        if([self.importQueue count] == 0){
            [self setLoading:NO];
            [self alert:NSLocalizedString(@"msg_save_image_success", nil)];
        }
    }
    if([self.importQueue count] != 0){
        [NSThread detachNewThreadSelector:@selector(runSaveImage) toTarget:self withObject:nil];
    }
}

- (void)confirmImportImages
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"confirm_add_image_to_photos", nil) 
                                                    message:nil 
                                                   delegate:self 
                                          cancelButtonTitle:NSLocalizedString(@"alert_approve", nil) 
                                          otherButtonTitles:NSLocalizedString(@"alert_cancel", nil), nil];
    alert.tag = ALERT_VIEW_IMPORT;
    [alert show];
    [alert release];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableArray *queue = [NSMutableArray arrayWithObject:[NSNumber numberWithInt:indexPath.row]];
    self.importQueue = queue;
    
    [self confirmImportImages];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.fileNameList count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"__id";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                      reuseIdentifier:identifier] autorelease];
    }
    cell.textLabel.text = [self.fileNameList objectAtIndex:indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        NSString *fileName = [self.fileNameList objectAtIndex:indexPath.row];
        NSString *filePath = [self.documentPath stringByAppendingPathComponent:fileName];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        [self.fileNameList removeObjectAtIndex:indexPath.row];
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                         withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
}

@end

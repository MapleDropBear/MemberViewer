//
//  ViewController.h
//  MemberViewer
//
//  Created by Chris Fowler on 2015-11-11.
//  Copyright © 2015 Chris Fowler. All rights reserved.
//

#import <UIKit/UIKit.h>
//video recording
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
  UITableView *_tableView;
  UIActivityIndicatorView *_activityIndicatorView;
  NSArray *_memberData;
  UINavigationBar *_navBar;
}

-(BOOL)startCameraController:(UIViewController*)controller
                                 usingDelegate:(id )delegate;
-(void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void*)contextInfo;

@property (nonatomic, retain) UINavigationBar *navBar;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) NSArray *memberData;

@end
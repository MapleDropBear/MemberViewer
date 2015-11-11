//
//  ViewController.h
//  MemberViewer
//
//  Created by Chris Fowler on 2015-11-11.
//  Copyright © 2015 Chris Fowler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
  UITableView *_tableView;
  UIActivityIndicatorView *_activityIndicatorView;
  NSArray *_memberData;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) NSArray *memberData;

@end
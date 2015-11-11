//
//  ViewController.m
//  MemberViewer
//
//  Created by Chris Fowler on 2015-11-11.
//  Copyright © 2015 Chris Fowler. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

@implementation ViewController

@synthesize tableView = _tableView, activityIndicatorView = _activityIndicatorView, memberData = _memberData, navBar = _navBar;



- (void)viewDidLoad
{
  [super viewDidLoad];
 
  // top menu field
  
  self.navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 60.0)];
  
  
  UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Record"
                                                                  style:UIBarButtonItemStyleDone target:self action:@selector(recordButtonPressed:)];
  UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"Member Views"];
  item.rightBarButtonItem = rightButton;
  item.hidesBackButton = YES;
  [self.navBar pushNavigationItem:item animated:NO];

  [self.view addSubview:self.navBar];
  
  // Setup table view
  self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 60.0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.tableView.hidden = YES;
  [self.view addSubview:self.tableView];
  
  // Setup Activity Indicator view
  self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  self.activityIndicatorView.hidesWhenStopped = YES;
  self.activityIndicatorView.center = self.view.center;
  [self.view addSubview:self.activityIndicatorView];
  [self.activityIndicatorView startAnimating];
  
  // Init Data
  self.memberData = [[NSArray alloc] init];
  
  // call URL
  NSURL *url = [[NSURL alloc] initWithString:@"https://bigdev.kwickie.com/api/members"];
  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
  
  AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  op.responseSerializer = [AFJSONResponseSerializer serializer];

  // needed to set specific content type
  op.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/vnd.api+json", nil];
  [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
  {
    NSLog(@"JSON: %@", responseObject);
   
    // populate data.
    self.memberData = responseObject;
    [self.activityIndicatorView stopAnimating];
    [self.tableView setHidden:NO];
    [self.tableView reloadData];
  } failure:^(AFHTTPRequestOperation *operation, NSError *error)
  {
    NSLog(@"Error: %@", error);
  }];
  
  [[NSOperationQueue mainQueue] addOperation:op];
  
  
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (self.memberData && self.memberData.count) {
    return self.memberData.count;
  } else {
    return 0;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellID = @"Cell Identifier";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
  
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
  }
  
  NSDictionary *member = [self.memberData objectAtIndex:indexPath.row];
  
  cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [member objectForKey:@"firstName"], [member objectForKey:@"lastName"]];
  
  NSObject* imagePath = [member objectForKey:@"profilePicturePath"];
  
  if(imagePath != [NSNull null])
  {
    // format the string to avoid warning
    NSURL *url = [[NSURL alloc] initWithString: [NSString stringWithFormat:@"%@", imagePath]];
    // invoke async UI call to show the image, place a placeholder
    [cell.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder"]];
  }
  else
  {
    cell.imageView.image = [UIImage imageNamed:@"placeholder"];
  }
  
  
  return cell;
}


// recording interface called.
-(IBAction)recordButtonPressed:(UIBarButtonItem*)btn
{
  NSLog(@"button tapped %@", btn.title);
}


@end

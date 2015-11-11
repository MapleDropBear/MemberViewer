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

// info about the controller
// So I went with a single view controller just becuase of the time constraints of the test and simplicity of the requests.
// I also programatically generated the layout just for speed and to show that I know how to when nessesary in prototyping, etc.


@implementation ViewController

@synthesize tableView = _tableView, activityIndicatorView = _activityIndicatorView, memberData = _memberData, navBar = _navBar;



- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // top menu field
  self.navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 60.0)];
  
  // record button
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
     // Log for output. Disabled.
     //NSLog(@"JSON: %@", responseObject);
     
     // populate data.
     self.memberData = responseObject;
     // stop spinner
     [self.activityIndicatorView stopAnimating];
     // show table and refresh
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
  [self startCameraController:self usingDelegate:self];
}

-(BOOL)startCameraController:(UIViewController*)controller usingDelegate:(id )delegate
{
  // check for valid
  if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
      || (delegate == nil)
      || (controller == nil))
  {
    return NO;
  }
  
  // get an image picker controller
  UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
  cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
  
  cameraUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
  
  // not caring about edit just want to record.
  cameraUI.allowsEditing = NO;
  cameraUI.delegate = delegate;
  
  // start the recording device
  [controller presentViewController:cameraUI animated:YES completion:nil];
  return YES;
}

// using image picker controller to save the movie to drive
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
  NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
  [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
  
  // Handle a movie capture
  if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo)
  {
    NSString *moviePath = (NSString *)[[info objectForKey:UIImagePickerControllerMediaURL] path];
    
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(moviePath))
    {
      UISaveVideoAtPathToSavedPhotosAlbum(moviePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    }
  }
}


// Return from saving attempt
-(void)video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
  if (error)
  {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"
                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
  }
  else
  {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
  }
}

@end

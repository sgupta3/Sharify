//
//  CameraTableViewController.h
//  Sharify
//
//  Created by Sahil Gupta on 2015-06-03.
//  Copyright (c) 2015 SahilGupta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface CameraTableViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property(nonatomic,strong) UIImagePickerController *imagePicker;
@property(nonatomic,strong) UIImage *image;
@property(nonatomic,strong) NSString *videoFilePath;
@property(nonatomic,strong) NSArray *friends;
@property(nonatomic,strong) PFRelation *friendsRelation;
@property(nonatomic,strong) NSMutableArray *recipients;
-(void) uploadMessage;
@end

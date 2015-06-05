//
//  ImageViewController.h
//  Sharify
//
//  Created by Sahil Gupta on 2015-06-04.
//  Copyright (c) 2015 SahilGupta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ImageViewController : UIViewController

@property(nonatomic,strong)PFObject *message;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

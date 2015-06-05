//
//  InboxViewController.h
//  Sharify
//
//  Created by Sahil Gupta on 2015-05-28.
//  Copyright (c) 2015 SahilGupta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MediaPlayer/MediaPlayer.h>

@interface InboxViewController : UITableViewController

@property(nonatomic,strong)NSArray *messages;
@property(nonatomic,strong)PFObject *messageToView;
@property(nonatomic,strong) MPMoviePlayerController *moviePlayer;

@end

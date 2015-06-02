//
//  FriendsTableViewController.h
//  Sharify
//
//  Created by Sahil Gupta on 2015-06-02.
//  Copyright (c) 2015 SahilGupta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FriendsTableViewController : UITableViewController

@property(nonatomic,strong)PFRelation *friendsRelation;
@property(nonatomic,strong)NSArray *friends;

@end

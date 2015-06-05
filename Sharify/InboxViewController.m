//
//  InboxViewController.m
//  Sharify
//
//  Created by Sahil Gupta on 2015-05-28.
//  Copyright (c) 2015 SahilGupta. All rights reserved.
//

#import "InboxViewController.h"
#import "ImageViewController.h"

@interface InboxViewController ()

- (IBAction)logout:(UIBarButtonItem *)sender;

@end

@implementation InboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.moviePlayer = [[MPMoviePlayerController alloc] init];
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        NSLog(@"Current User: %@", currentUser.username);
    } else {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
}

-(void) viewWillAppear:(BOOL)animated  {
    [super viewWillAppear:animated];
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    [query whereKey:@"recipientIds" equalTo:[[PFUser currentUser] objectId]];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error){
            NSLog(@"Error: %@, %@",error,error.userInfo);
        } else {
            self.messages = objects;
            [self.tableView reloadData];
            NSLog(@"Retrieved Messages: %lu",self.messages.count);
        }
    }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFObject *message = [self.messages objectAtIndex:indexPath.row];
    
    NSString *fileType = [message objectForKey:@"fileType"];
    
    if([fileType isEqualToString:@"image"]){
        cell.imageView.image = [UIImage imageNamed:@"icon_image"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"icon_video"];
    }
    
    cell.textLabel.text = [message objectForKey:@"senderName"];
    
    return cell;
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.messageToView = [self.messages objectAtIndex:indexPath.row];
    NSString *fileType = [self.messageToView objectForKey:@"fileType"];
    if([fileType isEqualToString:@"image"]){
        [self performSegueWithIdentifier:@"showImage" sender:self];
    } else {
        PFFile *videoFile = [self.messageToView objectForKey:@"file"];
        NSURL *fileUrl = [NSURL URLWithString:videoFile.url];
        self.moviePlayer.contentURL = fileUrl;
        [self.moviePlayer prepareToPlay];
        //ADD it to the view controller so we can see it.
        
        [self.view addSubview:self.moviePlayer.view];
        [self.moviePlayer setFullscreen:YES animated:YES];
    }
    
    NSMutableArray *recipientIds = [NSMutableArray arrayWithArray:[self.messageToView objectForKey:@"recipientIds"]];
    NSLog(@"Recipients: %@", recipientIds);
    
    if(recipientIds.count == 1) {
        //Delete the recipients
        
        [self.messageToView deleteInBackground];
    
    } else {
        //Remove the recipients from the object
        [recipientIds removeObject:[[PFUser currentUser] objectId]];
         [self.messageToView setObject:recipientIds forKey:@"recipientIds"];
         [self.messageToView saveInBackground];
    
    }
    
}

- (IBAction)logout:(UIBarButtonItem *)sender {
    [PFUser logOut];
    [self performSegueWithIdentifier:@"showLogin" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showLogin"]) {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    } else if([segue.identifier isEqualToString:@"showImage"]) {
        
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        ImageViewController *imageViewController = (ImageViewController *)segue.destinationViewController;
        imageViewController.message = self.messageToView;
    }
}
@end

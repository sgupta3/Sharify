//
//  CameraTableViewController.m
//  Sharify
//
//  Created by Sahil Gupta on 2015-06-03.
//  Copyright (c) 2015 SahilGupta. All rights reserved.
//

#import "CameraTableViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface CameraTableViewController ()

- (IBAction)cancel:(UIBarButtonItem *)sender;
- (IBAction)send:(UIBarButtonItem *)sender;

@end

@implementation CameraTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.recipients = [[NSMutableArray alloc] init];
    self.friendsRelation = [[PFUser currentUser] objectForKey:@"friendsRelation"];

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initImagePickerController];

    PFQuery *query = [self.friendsRelation query];
    
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            NSLog(@"Error: %@ %@",error,error.userInfo);
        } else {
            self.friends = objects;
            [self.tableView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initImagePickerController {
    if (self.image == nil && [self.videoFilePath length] == 0) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.allowsEditing = NO;
        self.imagePicker.videoMaximumDuration = 10;
        
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:self.imagePicker.sourceType];
        [self presentViewController:self.imagePicker animated:NO completion:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    cell.textLabel.text = user.username;
    
    if([self.recipients containsObject:user.objectId]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    
    if(cell.accessoryType == UITableViewCellAccessoryNone){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.recipients addObject:user.objectId];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.recipients removeObject:user.objectId];
    }
}

#pragma mark - Image Picker Controller Delegate


- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.tabBarController setSelectedIndex:0];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if([mediaType isEqualToString:(NSString *)kUTTypeImage]){
        self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if(self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            UIImageWriteToSavedPhotosAlbum(self.image, nil,nil,nil);
        }
    } else if ( [mediaType isEqualToString:(NSString *)kUTTypeVideo]){
        self.videoFilePath = (__bridge NSString *)([[info objectForKey:UIImagePickerControllerMediaURL] path]);
        if(self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            if(UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.videoFilePath)){
                UISaveVideoAtPathToSavedPhotosAlbum(self.videoFilePath, nil, nil, nil);
            }
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

#pragma mark - Helpers

- (void) resetStateOfViewController {
    self.image = nil;
    self.videoFilePath = nil;
    [self.recipients removeAllObjects];
    [self.tabBarController setSelectedIndex:0];
}

- (UIImage *) resizeImage: (UIImage *) image toWidth:(float)width andHeight:(float)height {
    CGSize sizeOfNewImage = CGSizeMake(width,height);
    CGRect newRectangle = CGRectMake(0, 0, width, height);
    
    UIGraphicsBeginImageContext(sizeOfNewImage);
    [self.image drawInRect:newRectangle];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}



#pragma mark - IBActions

- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self resetStateOfViewController];
}

- (IBAction)send:(UIBarButtonItem *)sender {
    if(self.image == nil && self.videoFilePath.length == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Try again!" message:@"Please capture a photo or video" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    } else {
        [self uploadMessage];
    }
    
}

- (void) uploadMessage {
    
    NSData *fileData;
    NSString *fileName;
    NSString *fileType;
    
    if(self.image != nil) {
        UIImage *resizedImage = [self resizeImage:self.image toWidth:320.0 andHeight:480.0];
        fileData = UIImagePNGRepresentation(resizedImage);
        fileName = @"image.png";
        fileType = @"image";
    } else {
        fileData = [NSData dataWithContentsOfFile:self.videoFilePath];
        fileName = @"video.mov";
        fileType = @"video";
    }
    
    PFFile *file = [PFFile fileWithName:fileName data:fileData];
    
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error){
            [[[UIAlertView alloc] initWithTitle:@"An Error occurred!" message:@"Please try sending the message again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            [self resetStateOfViewController];
        } else {
            PFObject *message = [PFObject objectWithClassName:@"Messages"];
            [message setObject:file forKey:@"file"];
            [message setObject:fileType forKey:@"fileType"];
            [message setObject:self.recipients forKey:@"recipientIds"];
            [message setObject:[[PFUser currentUser] objectId] forKey:@"senderId"];
            [message setObject:[[PFUser currentUser] username] forKey:@"senderName"];
            [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(error){
                    [[[UIAlertView alloc] initWithTitle:@"An Error occurred!" message:@"Please try sending the message again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Success!" message:@"Message was successfully sent." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                    [self resetStateOfViewController];

                }
            }];
        }
    }];
    
}
@end

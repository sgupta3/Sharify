//
//  SignUpViewController.m
//  Sharify
//
//  Created by Sahil Gupta on 2015-06-01.
//  Copyright (c) 2015 SahilGupta. All rights reserved.
//

#import "SignUpViewController.h"
#import <Parse/Parse.h>

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)signupButton:(UIButton *)sender {
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *email =    [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([username length] == 0 || [password length] == 0 || [email length] == 0 ) {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Make sure you enter a username, password and email address." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        PFUser *user = [PFUser user];
        user.username = username;
        user.password = password;
        user.email = email;
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(error) {
                [[[UIAlertView alloc] initWithTitle:@"Oops!" message:[error.userInfo objectForKey:@"error"] delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } else {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }];
    }

}
@end

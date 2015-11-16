//
//  LoginViewController.m
//  TestAudioProject
//
//  Created by Yurii Huber on 19.10.15.
//  Copyright (c) 2015 Yurii Huber. All rights reserved.
//

#import "LoginViewController.h"
#import "VKSdk.h"


@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [VKSdk initializeWithDelegate:self andAppId:@"5112182"];
    if ([VKSdk wakeUpSession])
    {
        //Start working
        //[self performSegueWithIdentifier:@"musicTableViewController" sender:self];
    } else {
        
        NSArray *scope = @[@"friends,audio"];
        [VKSdk authorize:scope];
        //        [VKSdk authorize:scope revokeAccess:YES];
        //        [VKSdk authorize:scope revokeAccess:YES forceOAuth:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    
}

/**
 Notifies delegate about existing token has expired
 @param expiredToken old token that has expired
 */
- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
    
}

/**
 Notifies delegate about user authorization cancelation
 @param authorizationError error that describes authorization error
 */
- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
    
}

/**
 Pass view controller that should be presented to user. Usually, it's an authorization window
 @param controller view controller that must be shown to user
 */
- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    
    [self presentViewController:controller
                       animated:YES
                     completion:^{}];
    
    [self performSegueWithIdentifier:@"musicTableViewController" sender:self];
}

/**
 Notifies delegate about receiving new access token
 @param newToken new token for API requests
 */
- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
    
}

@end

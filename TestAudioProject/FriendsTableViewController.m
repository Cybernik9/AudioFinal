//
//  FriendsTableViewController.m
//  TestAudioProject
//
//  Created by Yurii Huber on 23.10.15.
//  Copyright (c) 2015 Yurii Huber. All rights reserved.
//

#import "FriendsTableViewController.h"
#import "UIImageView+AFNetworking.h"
#import "MusicViewController.h"
#import "VKSdk.h"

@interface FriendsTableViewController () <VKSdkDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray* friendsArray;

@property (assign, nonatomic) NSInteger countFriends;
@property (weak, nonatomic) NSString* searchString;

@property (strong, nonatomic) NSString* ownerId;

@end

@implementation FriendsTableViewController

static bool isRenewed;
static const NSInteger countUpdateFriends = 25;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [VKSdk initializeWithDelegate:self andAppId:@"5112182"];
    
    if (![VKSdk wakeUpSession]) {
        
        NSArray *scope = @[@"friends,audio"];
        [VKSdk authorize:scope];
    }
    else {
        [self getFriendsFromServer:0];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - VKSdkDelegate

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
    
    NSArray *scope = @[@"friends,audio"];
    [VKSdk authorize:scope];
}

/**
 Pass view controller that should be presented to user. Usually, it's an authorization window
 @param controller view controller that must be shown to user
 */
- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    
    [self presentViewController:controller
                       animated:YES
                     completion:^{}];
}

/**
 Notifies delegate about receiving new access token
 @param newToken new token for API requests
 */
- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
    [self getFriendsFromServer:0];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.friendsArray count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"My music";
        cell.detailTextLabel.text = nil;
        cell.imageView.image = nil;
    } else {
        cell.textLabel.text = [[self.friendsArray objectAtIndex:indexPath.row - 1] objectForKey:@"first_name"];
        cell.detailTextLabel.text = [[self.friendsArray objectAtIndex:indexPath.row - 1] objectForKey:@"last_name"];
        
        NSString *strUrl = [[self.friendsArray objectAtIndex:indexPath.row - 1] objectForKey:@"photo_50"];
        NSURL *url = [NSURL URLWithString:strUrl];
        
        NSURLRequest* request = [NSURLRequest requestWithURL: url];
        
        __weak UITableViewCell* weakCell = cell;
        
        cell.imageView.image = nil;
        
        [cell.imageView
         setImageWithURLRequest:request
         placeholderImage:nil
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
             weakCell.imageView.image = image;
             [weakCell layoutSubviews];
         }
         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
             
         }];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        self.ownerId = nil;
    } else {
        self.ownerId = [[self.friendsArray objectAtIndex:indexPath.row - 1] objectForKey:@"id"];
    }

    [self performSegueWithIdentifier:@"musicIdentifier" sender:self];
}

- (void)scrollViewDidScroll:(UIScrollView *)scroll {
    
    NSInteger currentOffset = scroll.contentOffset.y;
    NSInteger maximumOffset = scroll.contentSize.height - scroll.frame.size.height;
    
    if (maximumOffset - currentOffset <= 250.0 && [self.friendsArray count] < self.countFriends && !isRenewed) {
        
        if (self.searchString) {
            [self getSearchFriendsFromServer:self.searchString offset:[self.friendsArray count]];
        }
        else {
            [self getFriendsFromServer:[self.friendsArray count]];
        }
        isRenewed = YES;
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"musicIdentifier"]) {
        
        MusicViewController *mvc = segue.destinationViewController;
        mvc.ownerId = self.ownerId;
    }
}

#pragma mark - API

- (void) getFriendsFromServer:(NSInteger)offset {
    
    NSDictionary* params =
    [NSDictionary dictionaryWithObjectsAndKeys:
     @"name",                 @"order",
     @(countUpdateFriends),   @"count",
     @(offset),               @"offset",
     @"photo_50",             @"fields", nil];
    
    VKRequest * audioReq = [[VKApi friends] get:params];
    
    if (offset == 0) {
        
        self.friendsArray = nil;
        self.friendsArray = [[NSMutableArray alloc] init];
    }
    
    [audioReq executeWithResultBlock:^(VKResponse * response) {
        NSLog(@"Json result: %@", response.json);
        
        [self.friendsArray addObjectsFromArray:[response.json objectForKey:@"items"]];
        self.countFriends = [[response.json objectForKey:@"count"] integerValue];
        isRenewed = NO;
        
        [self.tableView reloadData];
        
    } errorBlock:^(NSError * error) {
        if (error.code != VK_API_ERROR) {
            [error.vkError.request repeat];
        }
        else {
            NSLog(@"VK error: %@", error);
        }
    }];
}

- (void)getSearchFriendsFromServer:(NSString*)searchSymbol offset:(NSInteger)offset {
    
    NSDictionary* params =
    [NSDictionary dictionaryWithObjectsAndKeys:
     searchSymbol,            @"q",
     @(countUpdateFriends),   @"count",
     @(offset),               @"offset",
     @"photo_50",             @"fields", nil];
    
    VKRequest * audioReq = [VKApi requestWithMethod:@"friends.search" andParameters:params andHttpMethod:@"GET"];
    
    if (offset == 0) {
        
        self.friendsArray = nil;
        self.friendsArray = [[NSMutableArray alloc] init];
    }
    
    [audioReq executeWithResultBlock:^(VKResponse * response) {
        NSLog(@"Json result: %@", response.json);
        
        [self.friendsArray addObjectsFromArray:[response.json objectForKey:@"items"]];
        self.countFriends = [[response.json objectForKey:@"count"] integerValue];
        isRenewed = NO;
        
        [self.tableView reloadData];
        
    } errorBlock:^(NSError * error) {
        if (error.code != VK_API_ERROR) {
            [error.vkError.request repeat];
        }
        else {
            NSLog(@"VK error: %@", error);
        }
    }];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if ([searchText isEqualToString:@""]) {
        [self getFriendsFromServer:0];
        self.searchString = nil;
    }
    else {
        [self getSearchFriendsFromServer:searchText offset:0];
        self.searchString = searchText;
    }
}

@end

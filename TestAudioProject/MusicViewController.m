//
//  ViewController.m
//  TestAudioProject
//
//  Created by Yurii Huber on 19.10.15.
//  Copyright (c) 2015 Yurii Huber. All rights reserved.
//

#import "MusicViewController.h"
#import "FriendsTableViewController.h"
#import "VKSdk.h"
#import "Cell.h"
#import "Player.h"
//@import AVFoundation;

@interface MusicViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray* musicArray;
//@property (strong, nonatomic) NSArray* musicPlayArray;
//@property (strong, nonatomic) VKAudio* audioPlay;

@end

@implementation MusicViewController

static NSInteger activeRow = -1;

static NSString* artistMusic;
static NSString* titleMusic;
static NSString* timeMusic;

static NSTimer* timer;

static VKAudio* audioPlayNow;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.musicArray = [[NSMutableArray alloc] init];
    //self.musicPlayArray = [[NSMutableArray alloc] init];
    
    self.ownerId = [FriendsTableViewController getOwnerId];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self printArtist:artistMusic printTitle:titleMusic];
    [self printBackgroundButton];
    
    [self getMusicFromServer];
    
    if (activeRow >= 0) {
        [self recreateTimer];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.musicArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    VKAudio *tempAudio = [self.musicArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = tempAudio.artist;
    cell.detailTextLabel.text = tempAudio.title;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    activeRow = indexPath.row;
    [self.tableView reloadData];
    
    //self.musicPlayArray = [self.musicArray copy];
    //VKAudio *tempAudio = [self.musicPlayArray objectAtIndex:indexPath.row];
    
    VKAudio *tempAudio = [self.musicArray objectAtIndex:indexPath.row];
    
    //audioPlayNow = tempAudio;
    
    self.musicSlider.maximumValue = [tempAudio.duration floatValue];
    self.musicSlider.value = 0.f;
    [self printArtist:tempAudio.artist printTitle:tempAudio.title];
    [self.playStopButton setBackgroundImage:[UIImage imageNamed:@"stopButton.png"] forState:UIControlStateNormal];
    [self playMusic];
    [self recreateTimer];
}

#pragma mark - My metod

- (void) getMusicFromServer {
    
    NSDictionary* params =
    [NSDictionary dictionaryWithObjectsAndKeys:
     self.ownerId,  @"owner_id", nil];
    
    VKRequest * audioReq = [VKApi requestWithMethod:@"audio.get" andParameters:params andHttpMethod:@"GET"];
    
    [audioReq executeWithResultBlock:^(VKResponse * response) {
        NSLog(@"Json result: %@", response.json);
        VKAudios *audios = [[VKAudios alloc] initWithDictionary:response.json objectClass:VKAudio.class];
        self.musicArray = audios.items;
        [self.tableView reloadData];
        
    } errorBlock:^(NSError * error) {
        
        UIAlertController * alert =   [UIAlertController
                                       alertControllerWithTitle:@"Error"
                                       message:@"User close or hasn't have audios"
                                       preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* alertAction = [UIAlertAction
                                      actionWithTitle:@"Exit"
                                      style:UIAlertActionStyleCancel
                                      handler:^(UIAlertAction * action) {
                                          
                                          [self.navigationController popToRootViewControllerAnimated:YES];
                                      }];
        
        [alert addAction:alertAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

- (void) playMusic {
    
    VKAudio *tempAudio = [self.musicArray objectAtIndex:activeRow];
    
    [[Player sharedPlayer] playWithStringPath:tempAudio.url];
}

#pragma mark - Print

- (void) printArtist:(NSString*)artist printTitle:(NSString*)title {
    
    self.artistLable.text = artistMusic = artist;
    self.titleLable.text = titleMusic = title;
}

- (void) printBackgroundButton {
    
    if ([[Player sharedPlayer] rate] == 1.0) {
        [self.playStopButton setBackgroundImage:[UIImage imageNamed:@"stopButton.png"] forState:UIControlStateNormal];
    } else {
        [self.playStopButton setBackgroundImage:[UIImage imageNamed:@"playButton.png"] forState:UIControlStateNormal];
    }
}

-(NSString*)convertTime:(NSUInteger)time{
    
    int h = floor(time / 3600);
    int min = floor(time % 3600 / 60);
    int sec = floor(time % 3600 % 60);
    
    NSString *strH = h >= 10 ? [NSString stringWithFormat:@"%d", h] : [NSString stringWithFormat:@"0%d", h];
    NSString *strMin = min >= 10 ? [NSString stringWithFormat:@"%d", min] : [NSString stringWithFormat:@"0%d", min];
    NSString *strSec = sec >= 10 ? [NSString stringWithFormat:@"%d", sec] : [NSString stringWithFormat:@"0%d", sec];
    
    if ( !h ) {
        return [NSString stringWithFormat:@"%@:%@", strMin, strSec];
    }
    
    return [NSString stringWithFormat:@"%@:%@:%@",strH, strMin, strSec];
}

- (void)showCurrentTimeChanging {
    
    //VKAudio *tempAudio = [self.musicPlayArray objectAtIndex:activeRow];
    
    VKAudio *tempAudio = [self.musicArray objectAtIndex:activeRow];
    
    //VKAudio *tempAudio = audioPlayNow;
    
    CGFloat duration = [tempAudio.duration doubleValue];
    CGFloat currentTime = [[Player sharedPlayer] currentTime];
    
    if (duration <= (currentTime+0.1)) {
        //[self nextTrack:nil];
        NSLog(@"nextTrack");
        activeRow++;
        
        //tempAudio = [self.musicPlayArray objectAtIndex:activeRow];
        tempAudio = [self.musicArray objectAtIndex:activeRow];
        //audioPlayNow = tempAudio;
        artistMusic = tempAudio.artist;
        titleMusic = tempAudio.title;
        [self printArtist:artistMusic printTitle:titleMusic];
        [self playMusic];
    }
    
    self.musicSlider.maximumValue = duration;
    [self.musicSlider setValue:currentTime animated:YES];
    
    self.endTimeLable.text = [self convertTime:duration];
    self.beginTimeLable.text = [self convertTime:currentTime];
}

-(void) recreateTimer {
    
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(showCurrentTimeChanging) userInfo:nil repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

#pragma mark - Action

- (IBAction)actionPlayStopMusic:(id)sender {
    
    if (![[Player sharedPlayer] playerCreated]) {
        //[self recreateTimer];
        [self playMusic];
//        currentTrackDict = [self.audioFiles firstObject];
//        currentTrackIndex = 0;
//        _playingTitlelabel.text = [NSString stringWithFormat:@"%@ - %@",[currentTrackDict objectForKey:@"artist"], [currentTrackDict objectForKey:@"title"]];
//        NSString *url = [currentTrackDict objectForKey:@"url"];
//        [[Player sharedPlayer] playWithStringPath:url];
    }
    
    
    if ([[Player sharedPlayer] rate] == 1.0) {
        [[Player sharedPlayer] pause];
        
        [self printBackgroundButton];
    }
    else {
        [[Player sharedPlayer] playCurrentAudioTrack];

        [self printBackgroundButton];
    }
    
    
//    NSUInteger currentUserID = [VKUser currentUser].accessToken.userID;
//    VKStorageItem *item = [[VKStorage sharedStorage]
//                           storageItemForUserID:currentUserID];
//    
//    NSString *mp3Link = @"https://mp3.vk.com/music/pop/j-lo.mp3";
//    NSURL *mp3URL = [NSURL URLWithString:mp3Link];
//    NSData *mp3Data = //mp3 data from request
//    
//    [item.cachedData addCachedData:mp3Data
//                            forURL:mp3URL
//                          liveTime:VKCachedDataLiveTimeOneMonth];
}

- (IBAction)actionSlider:(UISlider*)sender {
    
    float value = sender.value;
    float maxValue = sender.maximumValue;
    
    if (fabsf(value - maxValue) < FLT_EPSILON)
    {
        // hit
        NSLog(@"NEXT");
    }
    
    CMTime sliderValueTime = CMTimeMakeWithSeconds(self.musicSlider.value, 600);
    [[Player sharedPlayer] seekToTime:sliderValueTime];
    [self showCurrentTimeChanging];
}

- (IBAction)actionBeginChangeValue:(id)sender {

    [self actionPlayStopMusic:nil];
}

- (IBAction)actionEndChangeValue:(id)sender {
    
    [self actionPlayStopMusic:nil];
}

- (IBAction)actionSliderEndValue:(id)sender {
    
    NSLog(@"actionSliderEndValue");
}


@end

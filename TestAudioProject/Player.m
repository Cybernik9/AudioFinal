//
//  Player.m
//  TestAudioProject
//
//  Created by Yurii Huber on 26.10.15.
//  Copyright (c) 2015 Yurii Huber. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "Player.h"

static AVPlayer *player;

@implementation Player

+ (instancetype) sharedPlayer {
    static Player *sharedPlayer = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPlayer = [[Player alloc] init];
    });
    return sharedPlayer;
}


#pragma mark - Public methods

- (void) playWithStringPath:(NSString *)url {
    
    if (player) {
        [self stop];
    }
    player = [[AVPlayer alloc]initWithURL:[NSURL URLWithString:url]];
    
    if ([player rate] == 0) {
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(currentTimeChanging) userInfo:nil repeats:YES];
        [player addObserver:self forKeyPath:@"status" options:0 context:NULL];
    }
}

- (BOOL) playerCreated {
    return player ? YES : NO;
}

- (float) rate {
    return  [player rate];
}

- (void) pause {
    [player pause];
}

- (void) stop {
    if (player) {
        [player pause];
        [player removeObserver:self forKeyPath:@"status"];
        player = nil;
    }
}

- (void) playCurrentAudioTrack {
    [player play];
}

- (float) currentTime {
    return CMTimeGetSeconds(player.currentItem.currentTime);
}

- (void) seekToTime:(CMTime)sliderValueTime {
    [player seekToTime: sliderValueTime];
}


#pragma mark - Action methods

- (void)currentTimeChanging {
    _duration = CMTimeGetSeconds(player.currentItem.duration);
    if (isnan(_duration)) {
        _duration = 1;
    }
}


#pragma mark - Notification observers

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        if (player.status == AVPlayerStatusReadyToPlay) {
            [player play];
            _duration = CMTimeGetSeconds(player.currentItem.duration);
        } else if (player.status == AVPlayerStatusFailed) {
            NSLog(@"Error! player.status == AVPlayerStatusFailed");
        }
    }
}

@end

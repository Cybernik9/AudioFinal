//
//  Cell.h
//  TestAudioProject
//
//  Created by Yurii Huber on 23.10.15.
//  Copyright (c) 2015 Yurii Huber. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Cell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *artistLable;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *timeLable;

@property (weak, nonatomic) IBOutlet UIButton *playStopButton;
@property (weak, nonatomic) IBOutlet UISlider *misicSlider;

@end

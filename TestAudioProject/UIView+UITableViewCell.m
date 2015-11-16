//
//  UIView+UITableViewCell.m
//  TestAudioProject
//
//  Created by Yurii Huber on 23.10.15.
//  Copyright (c) 2015 Yurii Huber. All rights reserved.
//

#import "UIView+UITableViewCell.h"

@implementation UIView (UItableViewCell)

- (UITableViewCell*) superCell {
    
    if (!self.superview) {
        return nil;
    }
    
    if ([self.superview isKindOfClass:[UITableViewCell class]]) {
        return (UITableViewCell*)self.superview;
    }
    
    return [self.superview superCell];
}

@end

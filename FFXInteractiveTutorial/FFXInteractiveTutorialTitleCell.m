//
//  FFXInteractiveTutorialTitleCell.m
//  FFXInteractiveTutorial
//
//  Created by Robert Biehl on 03/10/2015.
//  Copyright © 2015 Robert Biehl. All rights reserved.
//

#import "FFXInteractiveTutorialTitleCell.h"

@implementation FFXInteractiveTutorialTitleCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

@end

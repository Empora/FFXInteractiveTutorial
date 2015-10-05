//
//  FFXInteractiveTutorialHightlightView.m
//  FFXInteractiveTutorial
//
//  Created by Robert Biehl on 03/10/2015.
//  Copyright © 2015 Robert Biehl. All rights reserved.
//

#import "FFXInteractiveTutorialHightlightView.h"

@implementation FFXInteractiveTutorialHightlightView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = self.tintColor.CGColor;
        self.layer.borderWidth = 5.0;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void) layoutSubviews{
    [super layoutSubviews];

    self.layer.cornerRadius = self.bounds.size.width/2.0;
    self.layer.borderColor = self.current ? self.tintColor.CGColor : [self.tintColor colorWithAlphaComponent:0.25].CGColor;
}

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    return NO;
}

- (void)setCurrent:(BOOL)current{
    if (_current != current) {
        _current = current;
        [self setNeedsLayout];
    }
}

@end

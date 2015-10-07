//
//  FFXInteractiveTutorialHightlightView.m
//  FFXInteractiveTutorial
//
//  Created by Robert Biehl on 03/10/2015.
//  Copyright © 2015 Robert Biehl. All rights reserved.
//

#import "FFXInteractiveTutorialHightlightView.h"

@interface FFXInteractiveTutorialHightlightView()

@property (nonatomic, assign) BOOL animating;

@end

@implementation FFXInteractiveTutorialHightlightView

- (void)setAnimating:(BOOL)animating{
    _animating = animating;
    if (_animating) {
        CABasicAnimation* animation =[CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animation.duration=1.0;
        animation.repeatCount=HUGE_VALF;
        animation.autoreverses=YES;
        animation.fromValue=@1;
        animation.toValue=@1.4;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [self.layer addAnimation:animation forKey:@"animateOpacity"];
        
        CABasicAnimation* animation2 =[CABasicAnimation animationWithKeyPath:@"borderWidth"];
        animation2.duration=1.0;
        animation2.repeatCount=HUGE_VALF;
        animation2.autoreverses=YES;
        animation2.fromValue=@3;
        animation2.toValue=@5;
        animation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        //[self.layer addAnimation:animation2 forKey:@"animateBorder"];

    } else {
        [self.layer removeAllAnimations];
    }
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = self.tintColor.CGColor;
        self.layer.borderWidth = 3.0;
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
        
        self.animating = current;
    }
}

@end

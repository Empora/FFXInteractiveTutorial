//
//  FFXInteractiveTutorialHightlightView.h
//  FFXInteractiveTutorial
//
//  Created by Robert Biehl on 03/10/2015.
//  Copyright © 2015 Robert Biehl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FFXInteractiveTutorialItem.h"

typedef enum : NSUInteger {
    /**
     *  Alpha Animation
     */
    FFXTutorialHighlightViewAnimationStyleAlpha = 0,
    
    /**
     *  Style that creates Box around View
     */
    FFXTutorialHighlightViewAnimationStyleBorder,
    
    /**
     *
     */
    FFXTutorialHighlightViewAnimationStyleSize
    
} FFXTutorialHighlightViewAnimationStyle;

@interface FFXInteractiveTutorialHightlightView : UIView

@property (nonatomic, weak) FFXInteractiveTutorialItem* item;

@property (nonatomic, assign) BOOL current;

@property (nonatomic, assign) FFXTutorialHighlightViewAnimationStyle animationStyle;
@property (nonatomic, assign) NSString * itemStyle;

@end

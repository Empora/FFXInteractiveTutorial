//
//  FFXInteractiveTutorial.h
//  FFXInteractiveTutorial
//
//  Created by Robert Biehl on 02/10/2015.
//  Copyright © 2015 Robert Biehl. All rights reserved.
//

@import UIKit;

#import "FFXInteractiveTutorialItem.h"

@interface FFXInteractiveTutorialMetrics : NSObject

/**
 *  Highlight view color
 */
@property (nonatomic, strong) UIColor* highlightColor;

/**
 *  Tutorial text view background color
 */
@property (nonatomic, strong) UIColor* backgroundColor;

/**
 *  Tutorial text view title font
 */
@property (nonatomic, strong) UIFont* titleFont;

/**
 *  Tutorial text view title color
 */
@property (nonatomic, strong) UIColor* titleColor;

/**
 *  Tutorial text view subtitle font
 */
@property (nonatomic, strong) UIFont* subtitleFont;

/**
 *  Tutorial text view subtitle color
 */
@property (nonatomic, strong) UIColor* subtitleColor;

@end

@interface FFXInteractiveTutorial : NSObject

+ (instancetype) defaultTutorial;

@property (nonatomic, readonly) FFXInteractiveTutorialMetrics* metrics;

- (instancetype)initWithWindow:(UIWindow*) window items:(NSArray<FFXInteractiveTutorialItem*>*)tutorialItems;

- (instancetype)initWithWindow:(UIWindow*) window file:(NSString*) path;

- (void) fullfillItemWithIdentifier:(NSString*) identifier;

/**
 *  Enable the tutorial and start scanning the view hierarchy for tutorial elements
 */
- (void) start;

/**
 *  Stop the tutorial
 */
- (void) stop;

@end

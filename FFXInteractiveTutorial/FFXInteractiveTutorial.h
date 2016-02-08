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


@class FFXInteractiveTutorial;
@protocol FFXInteractiveTutorialDelegate <NSObject>

@optional

- (BOOL) tutorial:(FFXInteractiveTutorial*) tutorial shouldFulfillItem:(NSString*)requirement;

@end

@interface FFXInteractiveTutorial : NSObject

+ (instancetype) defaultTutorial;

@property (nonatomic, weak) id<FFXInteractiveTutorialDelegate> delegate;

@property (nonatomic, readonly) FFXInteractiveTutorialMetrics* metrics;

/**
 *  Load previous tutorial state
 *
 *  @param window
 *
 *  @return tutorial instance or nil
 */
+ (instancetype) restoreTutorialInWindow:(UIWindow*) window;

- (instancetype) initWithWindow:(UIWindow*) window items:(NSArray<FFXInteractiveTutorialItem*>*)tutorialItems;

- (instancetype) initWithWindow:(UIWindow*) window file:(NSString*) path;

- (void) fulfillItemWithIdentifier:(NSString*) identifier;

/**
 *  Enable the tutorial and start scanning the view hierarchy for tutorial elements
 */
- (void) start;

/**
 *  Stop the tutorial
 */
- (void) stop;

/**
 *  Save the tutorial state to restore it later with restoreTutorialInWindow:
 */
- (void) save;

/**
 *  Reset current Tutorial State
 */

-(void) reset;

@end

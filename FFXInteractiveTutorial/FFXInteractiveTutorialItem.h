//
//  FFXInteractiveTutorialItem.h
//  FFXInteractiveTutorial
//
//  Created by Robert Biehl on 02/10/2015.
//  Copyright © 2015 Robert Biehl. All rights reserved.
//

@import UIKit;

@interface FFXInteractiveTutorialItem : NSObject<NSCopying>

+ (instancetype) itemWithIdentifier:(NSString*)identifier viewPath:(NSString*)viewPath title:(NSString*)title;

- (instancetype) initWithIdentifier:(NSString*)identifier ViewPath:(NSString*)viewPath title:(NSString*)title;

@property (nonatomic, strong) NSString* identifier;

/**
 *  String representing the path of the view to be used in a tutorial;
 */
@property (nonatomic, copy) NSString* viewPath;

/**
 *  Is this tutorial item allowed to show only once?
 *  Default: YES
 */
@property (nonatomic, assign) BOOL unique;

/**
 *  Should the matched view be highlighted?
 *  Default: YES
 */
@property (nonatomic, assign) BOOL highlightView;

@property (nonatomic, copy) NSString* title;

@property (nonatomic, copy) NSString* subtitle;

@property (nonatomic, weak) UIView* currentView;

@property (nonatomic, readonly) BOOL active;

/**
 *  Disables a tutorial item for a certain timeframe
 *
 *  @param timeInterval
 */
- (void) disable:(NSTimeInterval) timeInterval;

@end
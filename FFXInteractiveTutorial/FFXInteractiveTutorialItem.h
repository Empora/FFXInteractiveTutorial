//
//  FFXInteractiveTutorialItem.h
//  FFXInteractiveTutorial
//
//  Created by Robert Biehl on 02/10/2015.
//  Copyright © 2015 Robert Biehl. All rights reserved.
//

@import UIKit;

typedef enum : NSUInteger {
    /**
     *  Custom (manuale) interaction fulfillment.
     *  In this case the fulfill method on FFXInteractiveTutorial
     *  needs to be called directly.
     */
    FFXTutorialItemFullfillmentInteractionCustom = 0,
    /**
     *  If the referenced view supports tap gestures the item will be fulfilled upon the interaction
     *  The referenced view must be a, or a descendent of one of the following classes 
     *  Supported classes:
     *  UIControl
     *  
     *  Soon to be supported:
     *  UITableViewCell
     *  UICollectionViewCell
     *  UITabBarButton
     */
    FFXTutorialItemFullfillmentInteractionTap = 0,
    FFXTutorialItemFullfillmentInteractionDefault = FFXTutorialItemFullfillmentInteractionCustom,
} FFXTutorialItemFullfillmentInteraction;


typedef enum : NSUInteger {
    /**
     *  Style that create Circle around view
     */
    FFXTutorialItemStyleCircle = 0,
    
    /**
     *  Style that creates Box around View
     */
    FFXTutorialItemStyleBox = 1

} FFXTutorialItemStyle;

@interface FFXInteractiveTutorialItem : NSObject<NSCopying,NSCoding>

+ (instancetype) itemWithIdentifier:(NSString*)identifier viewPath:(NSString*)viewPath title:(NSString*)title;

- (instancetype) initWithIdentifier:(NSString*)identifier viewPath:(NSString*)viewPath title:(NSString*)title;

@property (nonatomic, strong) NSString* identifier;

/**
 *  String representing the path of the view to be used in a tutorial;
 */
@property (nonatomic, copy) NSString* viewPath;

@property (nonatomic, assign) FFXTutorialItemFullfillmentInteraction fullfillmentInteraction;

/**
 *  Is this tutorial item allowed to show only once?
 *  Default: YES
 */
@property (nonatomic, assign) BOOL unique;

@property (nonatomic, readonly) BOOL fulfilled;

@property (nonatomic, readonly) BOOL active;

/**
 *  Should the matched view be highlighted?
 *  Default: YES
 */
@property (nonatomic, assign) BOOL highlightView;

/**
 *  Should we scroll to the matched view
 *  Default: YES
 */

@property (nonatomic, assign) BOOL scrollToView;

@property (nonatomic,assign) FFXTutorialItemStyle itemStyle;

/**
 *  Set the highlight display style
 */
@property (nonatomic, copy) NSString* highlightStyle;

/**
 *  Set the highlight display style
 */
@property (nonatomic, copy) NSString* highlightLevel;

@property (nonatomic, copy) NSString* title;

@property (nonatomic, copy) NSString* subtitle;

@property (nonatomic, weak) UIView* currentView;

/**
 *  The next tutorial item in a subprocess of steps.
 *  Only visible if the current item is fulfilled.
 */
@property (nonatomic, strong) FFXInteractiveTutorialItem* nextItem;

/**
 *  Returns the last one active in the current subprocess
 */
@property (nonatomic, readonly) FFXInteractiveTutorialItem* lastActiveItem;

/**
 *  Disables a tutorial item for a certain timeframe
 *
 *  @param timeInterval
 */
- (void) disable:(NSTimeInterval) timeInterval;

/**
 *  Fullfill a tutorial item;
 */
- (void) fulfill;

@end
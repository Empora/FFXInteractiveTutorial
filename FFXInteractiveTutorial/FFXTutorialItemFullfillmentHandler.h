//
//  FFXTutorialItemFullfillmentHandler.h
//  FFXInteractiveTutorial
//
//  Created by Robert Biehl on 05/10/2015.
//  Copyright © 2015 Robert Biehl. All rights reserved.
//

@import UIKit;

typedef void (^FFXTutorialItemInteractionBlock)(UIView* view, id sender);

@interface FFXTutorialItemFullfillmentHandler : NSObject

+ (instancetype) handlerWithView:(UIView*)view interactionBlock:(FFXTutorialItemInteractionBlock) interactionBlock;

@end

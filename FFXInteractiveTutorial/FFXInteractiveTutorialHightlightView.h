//
//  FFXInteractiveTutorialHightlightView.h
//  FFXInteractiveTutorial
//
//  Created by Robert Biehl on 03/10/2015.
//  Copyright © 2015 Robert Biehl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FFXInteractiveTutorialItem.h"

@interface FFXInteractiveTutorialHightlightView : UIView

@property (nonatomic, weak) FFXInteractiveTutorialItem* item;

@property (nonatomic, assign) BOOL current;

@end

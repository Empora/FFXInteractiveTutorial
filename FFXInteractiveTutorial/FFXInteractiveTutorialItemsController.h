//
//  FFXInteractiveTutorialItemsController.h
//  FFXInteractiveTutorial
//
//  Created by Robert Biehl on 03/10/2015.
//  Copyright © 2015 Robert Biehl. All rights reserved.
//

@import UIKit;

#import "FFXInteractiveTutorial.h"
#import "FFXInteractiveTutorialItem.h"

@interface FFXInteractiveTutorialItemsController : UICollectionViewController

@property (nonatomic, copy) void(^itemMessageTappedBlock)(FFXInteractiveTutorialItem*);

@property (nonatomic, strong) FFXInteractiveTutorialMetrics* metrics;

- (instancetype)initWithWindow:(UIWindow*) window;

- (void) setItems:(NSArray<FFXInteractiveTutorialItem*>*)items;
- (void) setItems:(NSArray<FFXInteractiveTutorialItem*>*)items animated:(BOOL) animated;

@end

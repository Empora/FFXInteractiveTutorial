//
//  FFXInteractiveTutorial.m
//  FFXInteractiveTutorial
//
//  Created by Robert Biehl on 02/10/2015.
//  Copyright © 2015 Robert Biehl. All rights reserved.
//

#import "FFXInteractiveTutorial.h"

#import <Mixpanel/MPObjectSelector.h>

#import "FFXInteractiveTutorialItemsController.h"

#define FFX_INTERACTIVE_TUTORIAL_HIDE_ITEM_INTERVAL 60.0

@implementation FFXInteractiveTutorialMetrics
@end

@interface FFXInteractiveTutorial()

@property (nonatomic, strong) FFXInteractiveTutorialMetrics* metrics;

@property (nonatomic, strong) UIWindow* window;
@property (nonatomic, strong) NSMutableArray* items;

@property (nonatomic, strong) NSMutableArray* activeItems;
@property (nonatomic, strong) FFXInteractiveTutorialItemsController* viewController;

@end

@implementation FFXInteractiveTutorial

#pragma mark Private

- (void) showItems:(NSArray<FFXInteractiveTutorialItem*>*)items{
    [self.viewController setItems:items animated:YES];
}

- (FFXInteractiveTutorialMetrics*) defaultMetrics{
    FFXInteractiveTutorialMetrics* metrics = [[FFXInteractiveTutorialMetrics alloc] init];
    metrics.titleColor = metrics.subtitleColor = [UIColor whiteColor];
    metrics.backgroundColor = metrics.highlightColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    return metrics;
}

#pragma mark Public
- (instancetype)initWithWindow:(UIWindow*) window items:(NSArray<FFXInteractiveTutorialItem*>*)tutorialItems{
    self = [super init];
    if (self) {
        self.window = window;
        self.items = [tutorialItems mutableCopy];

        self.activeItems = [NSMutableArray array];
        self.viewController = [[FFXInteractiveTutorialItemsController alloc] initWithWindow:window];
        
        __weak __typeof(self) weakSelf = self;
        self.viewController.itemMessageTappedBlock = ^(FFXInteractiveTutorialItem* item){
            [item disable:FFX_INTERACTIVE_TUTORIAL_HIDE_ITEM_INTERVAL];
            [weakSelf triggerCheck];
        };
        
        self.metrics = [self defaultMetrics];
        self.viewController.metrics = self.metrics;
    }
    return self;
}

-(void)setWindow:(UIWindow *)window{
    if (window != _window) {
        _window = window;
    }
}

-(void)triggerCheck{
    NSMutableArray* candidates = [NSMutableArray array];
    
    if (self.window.rootViewController) {
        for (FFXInteractiveTutorialItem* item in self.items) {
            if (!item.active) {
                continue;
            }
            
            MPObjectSelector* sel = [[MPObjectSelector alloc] initWithString:item.viewPath];
            NSArray* result = [sel selectFromRoot:self.window.rootViewController.view];
            NSLog(@"path %@ => %@", item.viewPath, result);
            
            if (result.count) {
                item.currentView = [result firstObject];
                [candidates addObject:item];
            }
        }
    }

    [self.activeItems removeAllObjects];
    for (FFXInteractiveTutorialItem* item in candidates) {
        if (item.unique) {
            // only add unique item if there is no other high priority tutorial item
            if (self.activeItems.count == 0) {
                [self.activeItems addObject:item];
            }
            return;
        } else {
            [self.activeItems addObject:item];
        }
    }
    
    [self showItems:self.activeItems];
}

- (void)fullfillItemWithIdentifier:(NSString *)identifier{
    NSUInteger index = [self.items indexOfObjectPassingTest:^BOOL(FFXInteractiveTutorialItem* _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        return [item.identifier isEqualToString:identifier];
    }];
    if (index != NSNotFound) {
        NSMutableArray* items = [self.items mutableCopy];
        [items removeObjectAtIndex:index];
        self.items = items;
    }
}

-(void)dealloc{

}

@end

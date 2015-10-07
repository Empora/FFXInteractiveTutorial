//
//  FFXInteractiveTutorial.m
//  FFXInteractiveTutorial
//
//  Created by Robert Biehl on 02/10/2015.
//  Copyright © 2015 Robert Biehl. All rights reserved.
//

#import "FFXInteractiveTutorial.h"

#import <Mixpanel/MPObjectSelector.h>
#import <Mixpanel/MPObjectSerializer.h>
#import <Mixpanel/MPObjectSerializerConfig.h>
#import <Mixpanel/MPObjectIdentityProvider.h>

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

/**
 *  Trigger UI update repeatedly
 *  TODO: replace with more advanced less trigger method
 */
@property (nonatomic, strong) NSTimer* timer;

- (void) triggerCheck;

@end

@implementation FFXInteractiveTutorial

#pragma mark Private

#ifdef DEBUG
- (NSString*) cleanPathForView:(UIView*) view{
    if (!view.superview) {
        return NSStringFromClass([view class]);
    }
    return [NSString stringWithFormat:@"%@/%@", [self cleanPathForView:view.superview], NSStringFromClass([view class])];
}
#endif

/**
 *  Checks if the view itself or one of his ancestors is hidden
 *
 *  @param view
 *
 *  @return
 */
- (BOOL) viewHasHiddenAncestor:(UIView *)view {
    UIView *ancestor = view;
    while (ancestor) {
        if (ancestor.hidden)
            return YES;
        ancestor = ancestor.superview;
    }
    return NO;
}

- (void) showItems:(NSArray<FFXInteractiveTutorialItem*>*)items{
    [self.viewController setItems:items animated:YES];
}

- (FFXInteractiveTutorialMetrics*) defaultMetrics{
    FFXInteractiveTutorialMetrics* metrics = [[FFXInteractiveTutorialMetrics alloc] init];
    metrics.titleColor = metrics.subtitleColor = [UIColor whiteColor];
//    metrics.backgroundColor = metrics.highlightColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    metrics.backgroundColor = metrics.highlightColor = [UIColor colorWithRed:255.0/255.0 green:45.0/255.0 blue:85.0/255.0 alpha:1.0];
    return metrics;
}

#pragma mark Public

static FFXInteractiveTutorial *defaultTutorial = nil;

+ (instancetype) defaultTutorial{
    return defaultTutorial;
}

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
        
        if (!defaultTutorial) {
            defaultTutorial = self;
        }
    }
    return self;
}

- (instancetype)initWithWindow:(UIWindow *)window file:(NSString *)path{
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data
                                              options:kNilOptions
                                                error:&error];
    
    NSMutableArray<FFXInteractiveTutorialItem*>* items = [NSMutableArray array];
    if ([json isKindOfClass:[NSArray class]]) {
        for (NSDictionary* itemDict in json) {
            FFXInteractiveTutorialItem* item = [[FFXInteractiveTutorialItem alloc] init];
            [item setValuesForKeysWithDictionary:itemDict];
            
            [items addObject:item];
        }
    }
    return [self initWithWindow:window items:items];
}

-(void)setWindow:(UIWindow *)window{
    if (window != _window) {
        _window = window;
    }
}

- (void)start{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(triggerCheck) userInfo:nil repeats:YES];
    }
}

- (void)stop{
    [_timer invalidate];
}

-(void)triggerCheck{
    NSMutableArray* candidates = [NSMutableArray array];
    
    if (self.window.rootViewController) {
        for (FFXInteractiveTutorialItem* currentItem in self.items) {
            FFXInteractiveTutorialItem* item = currentItem.lastActiveItem;
            if (!item) {
                continue;
            }
            
            // TODO: reuse MPObjectSelector
            MPObjectSelector* sel = [[MPObjectSelector alloc] initWithString:item.viewPath];
            NSArray* result = [sel selectFromRoot:self.window];

            BOOL isNew = NO;
            if (result.count) {
                for (UIView* view in result) {
                    if ([self viewHasHiddenAncestor:view]) {
                        continue;
                    }
                    if (!CGRectIntersectsRect(self.window.bounds, [self.window convertRect:view.bounds fromView:view])) {
                        NSLog(@"not visible view %@: %@", item.title, NSStringFromCGRect([self.window convertRect:view.bounds fromView:view]));
                        continue;
                    }
                    NSLog(@"visible view %@: %@", item.title, NSStringFromCGRect([self.window convertRect:view.bounds fromView:view]));
                    
                    item.currentView = view;
                    [candidates addObject:item];
                    break;
                }
                
                if ([self.activeItems indexOfObject:item] == NSNotFound) {
                    isNew = YES;
                }
            }
            
#ifdef DEBUG
            if (isNew) {
                //NSLog(@"path %@ => %@", item.viewPath, result);
                //NSLog(@"Clean path: %@", [self cleanPathForView:[result firstObject]]);
            }
#endif
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
    [_timer invalidate];
}

@end

//
//  FFXInteractiveTutorialItem.m
//  FFXInteractiveTutorial
//
//  Created by Robert Biehl on 02/10/2015.
//  Copyright © 2015 Robert Biehl. All rights reserved.
//

#import "FFXInteractiveTutorialItem.h"

#import "FFXTutorialItemFullfillmentHandler.h"

@interface FFXInteractiveTutorialItem()

@property (nonatomic, assign) BOOL fulfilled;

@property (nonatomic, strong) NSDate* disabledUntil;

@property (nonatomic, strong) FFXTutorialItemFullfillmentHandler* handler;

@end

@implementation FFXInteractiveTutorialItem

+ (instancetype) itemWithIdentifier:(NSString*)identifier viewPath:(NSString *)viewPath title:(NSString *)title{
    return [[FFXInteractiveTutorialItem alloc] initWithIdentifier:identifier viewPath:viewPath title:title];
}

- (instancetype) initWithIdentifier:(NSString *)identifier viewPath:(NSString *)viewPath title:(NSString *)title{
    self = [super init];
    if (self) {
        self.identifier = identifier;
        self.viewPath = viewPath;
        self.title = title;
    }
    return self;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"<%@: %p, identifier:%@; viewPath: %@>",
            NSStringFromClass([self class]), self, self.identifier, self.viewPath];
}

- (void)setCurrentView:(UIView *)currentView{
    if (_currentView != currentView) {
        _currentView = currentView;
        
        __weak __typeof(self) weakSelf = self;
        self.handler = [FFXTutorialItemFullfillmentHandler handlerWithView:currentView interactionBlock:^(UIView *view, id sender) {
            [weakSelf fulfill];
            NSLog(@"Interaction on %@ referenced from %@", sender, view);
        }];
    }
}

- (BOOL)active{
    return !self.fulfilled && ((_disabledUntil==nil) || ([_disabledUntil timeIntervalSinceNow] <= 0.0));
}

- (void)disable:(NSTimeInterval)timeInterval{
    _disabledUntil = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
}

- (void)fulfill{
    self.fulfilled = YES;
}

- (FFXInteractiveTutorialItem *)lastActiveItem{
    if (self.active) {
        return self;
    } else {
        return self.nextItem.lastActiveItem;
    }
}

#pragma mark NSCopying

- (id)copy{
    FFXInteractiveTutorialItem* copy = [[FFXInteractiveTutorialItem alloc] initWithIdentifier:self.identifier viewPath:self.viewPath title:self.title];
    copy.unique = self.unique;
    copy.highlightView = self.highlightView;
    copy.subtitle = self.subtitle;
    copy.currentView = self.currentView;
    return copy;
}

- (id)copyWithZone:(NSZone *)zone{
    FFXInteractiveTutorialItem* copy = [[FFXInteractiveTutorialItem allocWithZone:zone] initWithIdentifier:self.identifier viewPath:self.viewPath title:self.title];
    copy.unique = self.unique;
    copy.highlightView = self.highlightView;
    copy.subtitle = self.subtitle;
    copy.currentView = self.currentView;
    return copy;
}

@end

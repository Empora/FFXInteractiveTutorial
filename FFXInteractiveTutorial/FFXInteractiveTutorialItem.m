//
//  FFXInteractiveTutorialItem.m
//  FFXInteractiveTutorial
//
//  Created by Robert Biehl on 02/10/2015.
//  Copyright © 2015 Robert Biehl. All rights reserved.
//

#import "FFXInteractiveTutorialItem.h"

@interface FFXInteractiveTutorialItem()

@property (nonatomic, strong) NSDate* disabledUntil;

@end

@implementation FFXInteractiveTutorialItem

+ (instancetype) itemWithIdentifier:(NSString*)identifier viewPath:(NSString *)viewPath title:(NSString *)title{
    return [[FFXInteractiveTutorialItem alloc] initWithIdentifier:identifier viewPath:viewPath title:title];
}

- (instancetype) initWithIdentifier:(NSString*)identifier viewPath:(NSString *)viewPath title:(NSString *)title{
    self = [super init];
    if (self) {
        self.identifier = identifier;
        self.viewPath = viewPath;
        self.title = title;
    }
    return self;
}

- (BOOL)active{
    return (_disabledUntil==nil) || ([_disabledUntil timeIntervalSinceNow] <= 0.0);
}

- (void)disable:(NSTimeInterval)timeInterval{
    _disabledUntil = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
}

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

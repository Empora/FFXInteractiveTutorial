//
//  FFXInteractiveTutorialItem.m
//  FFXInteractiveTutorial
//
//  Created by Robert Biehl on 02/10/2015.
//  Copyright © 2015 Robert Biehl. All rights reserved.
//

#import "FFXInteractiveTutorialItem.h"

#import "FFXTutorialItemFullfillmentHandler.h"

NSString * const kFFXTutorialItemStyleCircle = @"Circle";
NSString * const kFFXTutorialItemStyleBox = @"Box";

@interface FFXInteractiveTutorialItem()

@property (nonatomic, assign) BOOL fulfilled;

@property (nonatomic, strong) NSDate* disabledUntil;

@property (nonatomic, strong) FFXTutorialItemFullfillmentHandler* handler;

@end

@implementation FFXInteractiveTutorialItem

- (void) mySharedItemInit{
    _highlightView = YES;
    _unique = NO;
    _highlightStyle = @"outside";
    _highlightLevel = @"stable";
}

+ (instancetype) itemWithIdentifier:(NSString*)identifier viewPath:(NSString *)viewPath title:(NSString *)title{
    return [[FFXInteractiveTutorialItem alloc] initWithIdentifier:identifier viewPath:viewPath title:title];
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self mySharedItemInit];
    }
    return self;
}

- (instancetype) initWithIdentifier:(NSString *)identifier viewPath:(NSString *)viewPath title:(NSString *)title{
    self = [super init];
    if (self) {
        self.identifier = identifier;
        self.viewPath = viewPath;
        self.title = title;
        [self mySharedItemInit];
    }
    return self;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"<%@: %p, identifier:%@; viewPath: %@; active: %d;>",
            NSStringFromClass([self class]), self, self.identifier, self.viewPath, self.active];
}

- (void)setValue:(id)value forKey:(NSString *)key{
    if ([key isEqualToString:@"nextItem"] && [value isKindOfClass:[NSDictionary class]]) {
        FFXInteractiveTutorialItem* item = [[FFXInteractiveTutorialItem alloc] init];
        [item setValuesForKeysWithDictionary:value];
        self.nextItem = item;
    } else {
        [super setValue:value forKey:key];
    }
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
    _fulfilled = YES;
}

- (BOOL)fulfilled{
    if (self.nextItem.fulfilled) {
        _fulfilled = YES;
    }
    return _fulfilled;
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
    copy.fulfilled = self.fulfilled;
    return copy;
}

- (id)copyWithZone:(NSZone *)zone{
    FFXInteractiveTutorialItem* copy = [[FFXInteractiveTutorialItem allocWithZone:zone] initWithIdentifier:self.identifier viewPath:self.viewPath title:self.title];
    copy.unique = self.unique;
    copy.highlightView = self.highlightView;
    copy.subtitle = self.subtitle;
    copy.currentView = self.currentView;
    copy.fulfilled = self.fulfilled;
    return copy;
}

#pragma mark NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
        self.viewPath = [aDecoder decodeObjectForKey:@"viewPath"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.subtitle = [aDecoder decodeObjectForKey:@"subtitle"];
        self.unique = [aDecoder decodeBoolForKey:@"unique"];
        self.highlightView = [aDecoder decodeBoolForKey:@"highlightView"];
        self.fulfilled = [aDecoder decodeBoolForKey:@"fulfilled"];
        self.disabledUntil = [aDecoder decodeObjectForKey:@"disabledUntil"];
        self.nextItem = [aDecoder decodeObjectForKey:@"nextItem"];
        self.itemStyle = [aDecoder decodeObjectForKey:@"itemStyle"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
    [aCoder encodeObject:self.itemStyle forKey:@"itemStyle"];
    [aCoder encodeObject:self.viewPath forKey:@"viewPath"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.subtitle forKey:@"subtitle"];
    [aCoder encodeBool:self.unique forKey:@"unique"];
    [aCoder encodeBool:self.highlightView forKey:@"highlightView"];
    [aCoder encodeBool:self.fulfilled forKey:@"fulfilled"];
    [aCoder encodeBool:self.disabledUntil forKey:@"disabledUntil"];
    [aCoder encodeObject:self.nextItem forKey:@"nextItem"];

}

@end

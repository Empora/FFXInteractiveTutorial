//
//  FFXTutorialItemFullfillmentHandler.m
//  FFXInteractiveTutorial
//
//  Created by Robert Biehl on 05/10/2015.
//  Copyright © 2015 Robert Biehl. All rights reserved.
//

#import "FFXTutorialItemFullfillmentHandler.h"

@interface FFXTutorialItemFullfillmentHandler()

@property (nonatomic, copy) FFXTutorialItemInteractionBlock block;
@property (nonatomic, weak) UIView* view;

@property (nonatomic, weak) UIGestureRecognizer* gesture;

@property (nonatomic, strong) UIButton* button;
@property (nonatomic, strong) UICollectionViewCell* collectionViewCell;
@property (nonatomic, strong) UITableViewCell* tableViewCell;
@property (nonatomic, strong) UITabBar* tabBar;

@end

@implementation FFXTutorialItemFullfillmentHandler

#pragma mark Private

- (UIView*) findFirstAncestorMatching:(NSArray*) allowedClasses{
    UIView* parent = self.view;
    while (parent) {
        for (Class cls in allowedClasses) {
            if ([parent isKindOfClass:cls]) {
                return parent;
            }
        }
        parent = parent.superview;
    }
    return nil;
}

- (void)setView:(UIView *)view{
    _view = view;
    UIView* ancestor = [self findFirstAncestorMatching:@[[UIButton class], [UICollectionViewCell class], [UITableViewCell class], [UITabBar class]]];
    if ([ancestor isKindOfClass:[UIButton class]]) {
        self.button = (id)ancestor;
    } else if ([ancestor isKindOfClass:[UICollectionViewCell class]]) {
        self.collectionViewCell = (id)ancestor;
    } else if ([ancestor isKindOfClass:[UITableViewCell class]]) {
        self.tableViewCell = (id)ancestor;
    } else if ([ancestor isKindOfClass:[UITabBar class]]) {
        self.tabBar = (id)ancestor;
    } else {
        UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(executeBlock:)];
        gesture.cancelsTouchesInView = NO;
        self.gesture = gesture;
        [view addGestureRecognizer:gesture];
    }
}

- (void)setButton:(UIButton *)button{
    _button = button;
    [button addTarget:self action:@selector(executeBlock:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setCollectionViewCell:(UICollectionViewCell *)view{
    _collectionViewCell = view;
    [view addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:nil];
    [view addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:nil];
}

- (void)setTableViewCell:(UITableViewCell *)view{
    _tableViewCell = view;
    [view addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
    [view addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:nil];
    [view addObserver:self forKeyPath:@"textLabel.highlighted" options:NSKeyValueObservingOptionNew context:nil];

}

- (void)setTabBar:(UITabBar *)view{
    _tabBar = view;
    [view addObserver:self forKeyPath:@"selectedItem" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:nil];
}

- (void) executeBlock:(id) sender{
    if (_block) {
        FFXTutorialItemInteractionBlock block = _block;
        block(self.view, sender);
    }
}

#pragma mark Public

+ (instancetype)handlerWithView:(UIView *)view interactionBlock:(FFXTutorialItemInteractionBlock)interactionBlock{
    FFXTutorialItemFullfillmentHandler* handler = [[FFXTutorialItemFullfillmentHandler alloc] init];
    handler.block = interactionBlock;
    handler.view = view;
    return handler;
}

- (void)dealloc{
    if (_button) {
        [_button removeTarget:self action:@selector(executeBlock:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (_collectionViewCell) {
        [_collectionViewCell removeObserver:self forKeyPath:@"selected"];
        [_collectionViewCell removeObserver:self forKeyPath:@"highlighted"];
    }
    if (_tableViewCell) {
        [_tableViewCell removeObserver:self forKeyPath:@"selected"];
        [_tableViewCell removeObserver:self forKeyPath:@"textLabel.highlighted"];
    }
    if (_tabBar) {
        [_tabBar removeObserver:self forKeyPath:@"selectedItem"];
    }
    if (_gesture) {
        [_gesture.view removeGestureRecognizer:_gesture];
    }
}

#pragma mark Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if (object == _collectionViewCell){
        // TODO
        if(_collectionViewCell.selected || _collectionViewCell.highlighted){
            [self executeBlock:_tableViewCell];
        }
    }
    if (object == _tableViewCell){
        // TODO: refactor this workaround
        // Workaround: highlighted is not KVO compliant
        if(_tableViewCell.isSelected){
            [self executeBlock:_tableViewCell];
        } else if(_tableViewCell.isHighlighted){
            _tableViewCell.selected = YES;
        }
    }
    if (object == _tabBar){
        NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            BOOL isButton = [NSStringFromClass([evaluatedObject class]) isEqualToString:@"UITabBarButton"];
            return isButton;
        }];
        NSUInteger viewIndex = [[self.view.superview.subviews filteredArrayUsingPredicate:predicate] indexOfObject:self.view];
        NSUInteger itemIndex = [_tabBar.items indexOfObject:_tabBar.selectedItem];
        if (viewIndex != NSNotFound && itemIndex == viewIndex ) {
            [self executeBlock:_tabBar];
        }
    }
}

@end

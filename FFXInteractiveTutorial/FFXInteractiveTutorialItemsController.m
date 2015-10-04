//
//  FFXInteractiveTutorialItemsController.m
//  FFXInteractiveTutorial
//
//  Created by Robert Biehl on 03/10/2015.
//  Copyright © 2015 Robert Biehl. All rights reserved.
//

#import "FFXInteractiveTutorialItemsController.h"

#import "FFXInteractiveTutorialHightlightView.h"
#import "FFXInteractiveTutorialTitleCell.h"

@interface FFXInteractiveTutorialItemsController()

@property (nonatomic, strong) UIWindow* window;

@property (nonatomic, strong) UIDynamicAnimator* animator;
@property (nonatomic, strong) NSArray<FFXInteractiveTutorialItem*>* items;
@property (nonatomic, strong) NSMapTable* highlightViewCache;

@property (nonatomic, strong) UIPageControl* pageControl;

@end

@implementation FFXInteractiveTutorialItemsController

#pragma mark Private

- (UIView*) findStableContextForView:(UIView*) view{
    UIView* contextView = view;
    while (true) {
        if (contextView.superview) {
            contextView = contextView.superview;
            if ([contextView isKindOfClass:[UIScrollView class]]) {
                return contextView;
            }
        } else {
            return contextView;
        }
    }
}

/**
 *  Selects the current tutorial item
 *
 *  @param itemIndex
 *  @param animated
 */
- (void) setCurrentItemIndex:(NSUInteger)itemIndex animated:(BOOL) animated{
    if(!self.items.count){
        return;
    }
    
    itemIndex = MIN(itemIndex, self.items.count-1);
    self.pageControl.currentPage = itemIndex;
    FFXInteractiveTutorialItem* item = self.items[itemIndex];
    
    void(^updateBlock)() = ^{
        for (FFXInteractiveTutorialHightlightView* view in self.highlightViewCache.objectEnumerator.allObjects) {
            view.current = (item == view.item);
        }
    };
    
    if (animated) {
        [UIView animateWithDuration:0.4 animations:updateBlock];
    } else {
        updateBlock();
    }
    
    
    [self.highlightViewCache objectForKey:item];
}

- (void) updateHighlightViewsWithItems:(NSArray*) items animated:(BOOL) animated{
    NSMapTable* localHighlightViewCache = [self.highlightViewCache copy];
    [self.highlightViewCache removeAllObjects];
    
    NSMapTable* highlightViewsInUse = [NSMapTable strongToStrongObjectsMapTable];
    for (FFXInteractiveTutorialItem* item in items) {
        FFXInteractiveTutorialHightlightView* view = [localHighlightViewCache objectForKey:item];
        if (view) {
            [highlightViewsInUse setObject:view forKey:item];
            [localHighlightViewCache removeObjectForKey:item];
        }
    }
    NSMutableArray* unusedHighlightViews = [localHighlightViewCache.objectEnumerator.allObjects mutableCopy];
    
    for (FFXInteractiveTutorialItem* item in items) {
        UIView* container = [self findStableContextForView:item.currentView];
        if (container) {
            CGPoint center = [container convertPoint:item.currentView.center fromView:item.currentView.superview];
            CGFloat padding = 10.0;
            CGFloat sideLength = padding+MAX(item.currentView.frame.size.height, item.currentView.frame.size.width);
            
            // acquire highlightView
            FFXInteractiveTutorialHightlightView* view = [highlightViewsInUse objectForKey:item];
            if (!view && unusedHighlightViews.count) {
                view = [unusedHighlightViews lastObject];
                [unusedHighlightViews removeLastObject];
            }
            if (!view) {
                view = [[FFXInteractiveTutorialHightlightView alloc] init];
                view.frame = CGRectMake(center.x-sideLength/2.0, center.y-sideLength/2.0, sideLength, sideLength);
                view.alpha = 0.0;
            }
            view.item = item;
        
            [container addSubview:view];
    
            void(^animationBlock)() = ^{
                view.tintColor = self.metrics.highlightColor;
                view.alpha = 1.0;
                view.frame = CGRectMake(center.x-sideLength/2.0, center.y-sideLength/2.0, sideLength, sideLength);
            };
            if (animated) {
                [UIView transitionWithView:view duration:0.3 options:UIViewAnimationOptionCurveEaseInOut
                                animations:animationBlock
                                completion:nil];
            } else {
                animationBlock();
            }

            [self.highlightViewCache setObject:view forKey:item];
        }
    }
    
    for (UIView* view in unusedHighlightViews) {
        [view removeFromSuperview];
    }
    
    [self setCurrentItemIndex:self.pageControl.currentPage animated:animated];
}

- (IBAction) pageControlAction:(id)sender{
    [self setCurrentItemIndex:self.pageControl.currentPage animated:YES];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.pageControl.currentPage inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

#pragma mark Public

- (instancetype)initWithWindow:(UIWindow*) window{
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:window];
        self.highlightViewCache = [NSMapTable strongToStrongObjectsMapTable];
        
        self.window = window;
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    UIPageControl* pageControl = [[UIPageControl alloc] init];
    [pageControl addTarget:self action:@selector(pageControlAction:) forControlEvents:UIControlEventValueChanged];
    pageControl.hidesForSinglePage = YES;
    pageControl.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 44.0);
    self.pageControl = pageControl;
    [self.view addSubview:self.pageControl];
    
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:[FFXInteractiveTutorialTitleCell class] forCellWithReuseIdentifier:NSStringFromClass([FFXInteractiveTutorialTitleCell class])];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    ((UICollectionViewFlowLayout*)self.collectionViewLayout).itemSize = self.collectionView.bounds.size;
}

- (void)setMetrics:(FFXInteractiveTutorialMetrics *)metrics{
    if (_metrics != metrics) {
        _metrics = metrics;
    }
}

- (void) setItems:(NSArray<FFXInteractiveTutorialItem*>*)items{
    [self setItems:items animated:NO];
}

- (void) setItems:(NSArray<FFXInteractiveTutorialItem*>*)items animated:(BOOL) animated{
    if ([_items isEqualToArray:items]) {
        return;
    }
    
    // Set items
    _items = [items copy];
    
    // Setup new items
    if (items.count) {
        CGFloat height = 88.0;
        self.view.frame = CGRectMake(0, self.window.bounds.size.height-height-50.0, self.window.bounds.size.width, height);
        self.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        
        if (!self.view.superview) {
            [self.window addSubview:self.view];
            if(animated) {
                CGRect frame = self.view.frame;
                self.view.frame = CGRectOffset(frame, 0.0, frame.size.height);
                [UIView animateWithDuration:0.4 delay:0.0
                     usingSpringWithDamping:0.5
                      initialSpringVelocity:0.5 options:0
                                 animations:^{
                                     self.view.frame = frame;
                                 }
                                 completion: nil];
            }
        }
    } else {
        if (self.view.superview) {
            if(animated) {
                [UIView animateWithDuration:0.4 delay:0.0
                                    options:0
                                 animations:^{
                                     self.view.alpha = 0.0;
                                 }
                                 completion:^(BOOL finished) {
                                     self.view.alpha = 1.0;
                                     [self.view removeFromSuperview];
                                 }];
            } else {
                [self.view removeFromSuperview];
            }
        }
    }
    
    [self updateHighlightViewsWithItems:items animated:animated];
    self.collectionView.backgroundColor = self.metrics.backgroundColor;
    [self.collectionView reloadData];
    self.pageControl.numberOfPages = items.count;
}

- (void)dealloc{
    
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.items.count > indexPath.item) {
        FFXInteractiveTutorialItem* item = self.items[indexPath.item];
        self.itemMessageTappedBlock(item);
    }
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section == 0) {
        return self.items.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FFXInteractiveTutorialTitleCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FFXInteractiveTutorialTitleCell class]) forIndexPath:indexPath];
    
    FFXInteractiveTutorialItem* item = self.items[indexPath.item];
    
    cell.titleLabel.text = item.title;
    
    return cell;
}

#pragma mark UIScrollViewDelegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView{

}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat pageWidth = self.collectionView.frame.size.width;
    NSUInteger currentindex = (NSUInteger)(self.collectionView.contentOffset.x + pageWidth / 2) / pageWidth;
    [self setCurrentItemIndex:currentindex animated:NO];
}

@end

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

@interface FFXInteractiveTutorialItemsController()<UICollectionViewDelegateFlowLayout>

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

- (CGRect) calculateViewFrameForItem:(FFXInteractiveTutorialItem*) item{
    
    CGFloat minHeight = 50.0;
    CGFloat maxHeight = 88.0;
    CGFloat bottomSpacing = 0.0;
    
    CGFloat currentViewBottom = [self.window convertRect:item.currentView.frame fromView:item.currentView].origin.y+item.currentView.frame.size.height;
    CGFloat height = MAX(minHeight, MIN(maxHeight, self.window.bounds.size.height-currentViewBottom));
    
    CGRect frame = CGRectMake(0, self.window.bounds.size.height-height-bottomSpacing, self.window.bounds.size.width, height);
    
    return frame;
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
    
    // for each item create/reuse and configure a highlightview if necessary
    for (FFXInteractiveTutorialItem* item in items) {
        if (item.scrollToView) {
            UIView * view = [self findStableContextForView:item.currentView];
            if ([view isKindOfClass:[UIScrollView class]]) {
                UIScrollView * scrollView = (UIScrollView*)view;
                [scrollView scrollRectToVisible:item.currentView.frame animated:YES];
            }
        }
        
        if (!item.highlightView) {
            continue;
        }
        UIView* container = nil;
        if ([item.highlightLevel isEqualToString:@"superview"]) {
            container = item.currentView.superview;
        } else {
            container = [self findStableContextForView:item.currentView];
        }
        if (container) {
            CGPoint viewsCenter = CGPointMake(item.currentView.frame.origin.x + (item.currentView.frame.size.width/2), item.currentView.frame.origin.y + (item.currentView.frame.size.height/2));
            CGPoint center = [container convertPoint:viewsCenter fromView:item.currentView.superview];
            CGFloat padding = 10.0;
            CGFloat sideLength = padding + ([item.highlightStyle isEqualToString:@"inside"] ? MIN(item.currentView.frame.size.height, item.currentView.frame.size.width) : MAX(item.currentView.frame.size.height, item.currentView.frame.size.width));
            
            // acquire highlightView
            FFXInteractiveTutorialHightlightView* view = [highlightViewsInUse objectForKey:item];
            
            // On fixed box animation just animate the border
            if (item.itemStyle == FFXTutorialItemStyleBox)
            {
                view.animationStyle = FFXTutorialHighlightViewAnimationStyleAlpha;
            } else {
                view.animationStyle = FFXTutorialHighlightViewAnimationStyleSize;
            }
            
            if (!view && unusedHighlightViews.count) {
                view = [unusedHighlightViews lastObject];
                [unusedHighlightViews removeLastObject];
            }
            if (!view) {
                view = [[FFXInteractiveTutorialHightlightView alloc] init];
                if (item.itemStyle == FFXTutorialItemStyleBox) {
                    view.frame = item.currentView.frame;
                } else {
                    view.frame = CGRectMake(center.x-sideLength/2.0, center.y-sideLength/2.0, sideLength, sideLength);
                }
                view.alpha = 0.0;
            }
            view.item = item;
        
            [container addSubview:view];
    
            void(^animationBlock)() = ^{
                view.tintColor = self.metrics.highlightColor;
                view.alpha = 1.0;
                
                if (item.itemStyle == FFXTutorialItemStyleBox) {
                    view.frame = item.currentView.frame;
                } else {
                    view.frame = CGRectMake(center.x-sideLength/2.0, center.y-sideLength/2.0, sideLength, sideLength);
                }
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
    
    [self.window addSubview:self.view];
    self.view.hidden = YES;
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
}

- (void)setMetrics:(FFXInteractiveTutorialMetrics *)metrics{
    if (_metrics != metrics) {
        _metrics = metrics;
    }
}

- (void) setItems:(NSArray<FFXInteractiveTutorialItem*>*)items{
    [self setItems:items animated:NO];
}


/**
 *  Show/hide the collection view
 *
 *  @param show     <#show description#>
 *  @param animated <#animated description#>
 */
- (void) showView:(BOOL) show animated:(BOOL) animated{
    if (show) {
        CGRect newFrame = [self calculateViewFrameForItem:self.items[0]];
        
        ((UICollectionViewFlowLayout*)self.collectionViewLayout).itemSize = newFrame.size;
        
        void(^animationBlock)() = ^{
            self.view.frame = newFrame;
            [self.collectionView performBatchUpdates:^{
                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            } completion:^(BOOL finished){
                [self.collectionView reloadData];
            }];
        };
        
        if (!self.view.superview || self.view.hidden) {
            self.view.alpha = 1.0;
            self.view.hidden = NO;
            self.view.frame = newFrame;
            self.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
            [self.window addSubview:self.view];
            if(animated) {
                self.view.frame = CGRectOffset(newFrame, 0.0, newFrame.size.height);
                [UIView animateWithDuration:0.4 delay:0.0
                     usingSpringWithDamping:0.5
                      initialSpringVelocity:0.5 options:UIViewAnimationOptionBeginFromCurrentState
                                 animations:animationBlock
                                 completion: nil];
            } else {
                animationBlock();
            }
        } else {
            if (!CGRectEqualToRect(self.view.frame, newFrame) && animated) {
                [UIView animateWithDuration:0.4
                                      delay:0.0
                                    options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                                 animations:animationBlock
                                 completion: nil];
            } else {
                [self.collectionView reloadData];
            }
        }
    } else {
        if (!self.view.hidden) {
            if(animated) {
                [UIView animateWithDuration:0.4 delay:0.0
                                    options:UIViewAnimationOptionBeginFromCurrentState
                                 animations:^{
                                     self.view.alpha = 0.0;
                                     NSLog(@"anim start");
                                 }
                                 completion:^(BOOL finished) {
                                     self.view.hidden = YES;
                                     NSLog(@"anim finished: %d", finished);
                                 }];
            } else {
                self.view.hidden = YES;
            }
        }
    }
}

- (void) setItems:(NSArray<FFXInteractiveTutorialItem*>*)items animated:(BOOL) animated{
    if ([_items isEqualToArray:items]) {
        return;
    }
    
    // Set items
    BOOL oldItemCount = _items.count;
    _items = [items copy];
    
    if (items.count && self.view.hidden) {
        [self showView:YES animated:animated];
    } else if(items.count==0 && !self.view.hidden){
        [self showView:NO animated:animated];
    } else {
        [self.collectionView performBatchUpdates:^{
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        } completion:^(BOOL finished){
            [self.collectionView reloadData];
        }];
    }
    
    // Setup new items
    [self updateHighlightViewsWithItems:items animated:animated];
    self.collectionView.backgroundColor = self.metrics.backgroundColor;
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
    
    cell.titleLabel.text = NSLocalizedString(item.title, nil);
    cell.titleLabel.font = self.metrics.titleFont;
    cell.titleLabel.textColor = self.metrics.titleColor;
    
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

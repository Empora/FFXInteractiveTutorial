//
//  AppDelegate.m
//  FFXInteractiveTutorial
//
//  Created by Robert Biehl on 02/10/2015.
//  Copyright © 2015 Robert Biehl. All rights reserved.
//

#import "AppDelegate.h"

#import "FFXInteractiveTutorial.h"

@interface AppDelegate ()

@property FFXInteractiveTutorial* tutorial;
@property NSTimer* timer;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    NSMutableArray* items = [NSMutableArray array];
    FFXInteractiveTutorialItem* cellItem = [FFXInteractiveTutorialItem itemWithIdentifier:@"tutorialCell" viewPath:@"/UIView/*/*/*/*/*/UILabel[restorationIdentifier='tutorialCell']" title:@"Push the Cell!"];

    [items addObject:cellItem];
    
    FFXInteractiveTutorialItem* findFriendsButtonItem = [FFXInteractiveTutorialItem itemWithIdentifier:@"findFriends" viewPath:@"/UIView/*/*/UIButton[accessibilityIdentifier='findFriends']" title:@"Tap button to find friends!"];
    
    FFXInteractiveTutorialItem* findFriendsTabBarItem = [FFXInteractiveTutorialItem itemWithIdentifier:@"tabbaritem" viewPath:@"/UIView/UITabBarButton[1]" title:@"Check out the friends tab!"];
    findFriendsTabBarItem.nextItem = findFriendsButtonItem;
    [items addObject:findFriendsTabBarItem];
    
    //self.tutorial = [[FFXInteractiveTutorial alloc] initWithWindow:self.window items:items];
    
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"tutorial"
                                                         ofType:@"json"];
    self.tutorial = [[FFXInteractiveTutorial alloc] initWithWindow:self.window file:jsonPath];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self.tutorial selector:@selector(triggerCheck) userInfo:nil repeats:YES];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

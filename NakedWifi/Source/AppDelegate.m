//
//  Naked Wifi
//
//  Copyright (C) 2013 Naked Apartments
//  All rights reserved.
//
//  Developed for Naked Apartments by:
//  Mark Mathis
//  http://tadamobile.com
//  markmathis@gmail.com
//

#import "AppDelegate.h"

#import "Theme.h"

#import "RegularTheme.h"

#import "RootViewController.h"
#import "WifiVC.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [Theme setCurrentTheme:[[RegularTheme alloc] init]];
    
    WifiVC *wifiVC = [[WifiVC alloc] init];
    
    UINavigationController *wifiNavigationController = [[UINavigationController alloc] initWithRootViewController:wifiVC];
    wifiNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"WIFI" image:[UIImage imageNamed:@"179-notepad"] tag:0];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[wifiNavigationController];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];

    #if RUN_KIF_TESTS
    	[[KIFTestController sharedInstance] startTestingWithCompletionBlock:^{
    		// Exit after the tests complete. When running on CI, this lets you check the return value for pass/fail.
    		exit([[KIFTestController sharedInstance] failureCount]);
    	}];
    #endif

    return YES;
}

@end

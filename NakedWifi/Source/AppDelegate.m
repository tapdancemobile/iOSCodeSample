//  Created by ttefabbob on 6/11/13.
#import "AppDelegate.h"

#import "Theme.h"

#import "RegularTheme.h"

#import "RootViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [Theme setCurrentTheme:[[RegularTheme alloc] init]];
    			
    RootViewController *rootViewController = [[RootViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = navigationController;
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

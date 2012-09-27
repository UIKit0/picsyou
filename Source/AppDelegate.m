//
//  AppDelegate.m
//  Picsyou
//
//  Created by Frédéric Sagnes on 27/09/12.
//  Copyright (c) 2012 teapot apps. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    ViewController *rootViewController = [[ViewController alloc] initWithNibName:nil bundle:nil];

    window.rootViewController = rootViewController;
    self.window = window;
    [window makeKeyAndVisible];

    return YES;
}

@end

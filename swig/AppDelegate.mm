//
//  AppDelegate.m
//  swig
//
//  Created by Pierre-Marc Airoldi on 2014-08-14.
//  Copyright (c) 2014 PeteAppDesigns. All rights reserved.
//

#import "AppDelegate.h"
#import "Swig.h"

static pj_thread_desc   a_thread_desc;
static pj_thread_t     *a_thread;
#define KEEP_ALIVE_INTERVAL 600

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    SWUserAgent *userAgent = [SWUserAgent sharedInstance];
    
    SWTransportConfiguration *tcp = [[SWTransportConfiguration alloc] initWithTransportType:PJSIP_TRANSPORT_TCP];
    SWTransportConfiguration *udp = [[SWTransportConfiguration alloc] initWithTransportType:PJSIP_TRANSPORT_UDP];
    
    [userAgent beginWithTransportConfigurations:@[tcp, udp]];

    [self didCall];
//    [self sipCall];
 
    return YES;
}

-(void)didCall {
    
    SWUserAgent *userAgent = [SWUserAgent sharedInstance];
    
    SWAccountConfiguration *accountConfiguration = [[SWAccountConfiguration alloc] initWithURI:@"sip:161672@montreal3.voip.ms"];
    
    NSMutableArray *auth = [accountConfiguration.sipConfig.authCreds mutableCopy];
    
    SWAuthCredInfo *authInfo = [SWAuthCredInfo new];
    authInfo.scheme = @"digest";
    authInfo.realm = @"*";
    authInfo.username = @"161672";
    authInfo.data = @"qwer1234";
    
    [auth addObject:authInfo];
    
    accountConfiguration.sipConfig.authCreds = auth;
    
    accountConfiguration.regConfig.registrarUri = @"sip:montreal3.voip.ms;transport=tcp";
    
    SWAccount *account = [[SWAccount alloc] initWithAccountConfiguration:accountConfiguration];
    
    [userAgent addAccount:account];
}

-(void)sipCall {
    
    SWUserAgent *userAgent = [SWUserAgent sharedInstance];
    
    SWAccountConfiguration *accountConfiguration = [[SWAccountConfiguration alloc] initWithURI:@"sip:mobila@getonsip.com"];
    
    NSMutableArray *auth = [accountConfiguration.sipConfig.authCreds mutableCopy];
    
    SWAuthCredInfo *authInfo = [SWAuthCredInfo new];
    authInfo.scheme = @"digest";
    authInfo.realm = @"*";
    authInfo.username = @"getonsip_mobila";
    authInfo.data = @"NQFxmwxw4wQMEfp3";
    
    [auth addObject:authInfo];
    
    accountConfiguration.sipConfig.authCreds = auth;
    
    NSMutableArray *proxy = [accountConfiguration.sipConfig.proxies mutableCopy];
    
    [proxy addObject:@"sip:sip.onsip.com"];
    
    accountConfiguration.sipConfig.proxies = proxy;
    
    accountConfiguration.regConfig.registrarUri = @"sip:getonsip.com;transport=tcp";
    
    SWAccount *account = [[SWAccount alloc] initWithAccountConfiguration:accountConfiguration];
    
    [userAgent addAccount:account];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [self performSelectorOnMainThread:@selector(keepAlive) withObject:nil waitUntilDone:YES];
    [application setKeepAliveTimeout:KEEP_ALIVE_INTERVAL handler: ^{
        [self performSelectorOnMainThread:@selector(keepAlive) withObject:nil waitUntilDone:YES];
    }];
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

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
}

-(void)keepAlive {
    
    int i;
    
    if (!pj_thread_is_registered()) {
        pj_thread_register("ipjsua", a_thread_desc, &a_thread);
    }
    
    /* Since iOS requires that the minimum keep alive interval is 600s,
     * application needs to make sure that the account's registration
     * timeout is long enough.
     */
    for (i = 0; i < (int)pjsua_acc_get_count(); ++i) {
        if (pjsua_acc_is_valid(i)) {
            pjsua_acc_set_registration(i, PJ_TRUE);
        }
    }
}

@end
//
//  AppDelegate.m
//  MIDIMonitor
//
//  Created by Julian Porter on 18/07/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import "InjectAppDelegate.h"
#import "InjectViewController.h"

@interface InjectAppDelegate ()

@property (weak) IBOutlet NSWindow *Window;
@property (weak) IBOutlet InjectViewController *Viewcontroller;
@end

@implementation InjectAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end

//
//  AppDelegate.m
//  MIDIMonitor
//
//  Created by Julian Porter on 18/07/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewControllerM.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *Window;
@property (weak) IBOutlet ScanViewController *Viewcontroller;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end

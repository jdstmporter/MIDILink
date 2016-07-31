//
//  ViewController.h
//  MIDILink
//
//  Created by Julian Porter on 28/04/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EndPointList.h"
#import "LinksList.h"


@interface ViewController : NSViewController

@property (weak) IBOutlet EndPoints *endpoints;
- (IBAction)scan:(NSButton *)sender;
- (IBAction)link:(NSButton *)sender;
- (IBAction)scasnFromMenu:(NSMenuItem *)sender;

- (void) unlinkAll;

@property (weak) IBOutlet LinksList *links;

@end

//
//  InjectorView.h
//  MIDILink
//
//  Created by Julian Porter on 29/07/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MIDIManager/MIDIManager.h>



@interface InjectorView : NSView<NSMenuDelegate,NSTextFieldDelegate>

@property (strong,nonatomic) MIDIBuilder *message;

@property (strong) IBOutlet NSPopUpButton *messageType;
@property (strong) IBOutlet NSPopUpButton *channel;
@property (strong) IBOutlet NSTextField *hexValue;

@property (strong) IBOutlet NSPopUpButton *controlChange;
@property (strong) IBOutlet NSTextField *byte1;
@property (strong) IBOutlet NSTextField *byte2;
@property (strong) IBOutlet NSTextField *pitchBend;

@property (strong) IBOutlet NSTextField *byte1Label;
@property (strong) IBOutlet NSTextField *byte2Label;

@property (strong) IBOutlet NSTextField *statusDec;
@property (strong) IBOutlet NSTextField *Byte1Dec;
@property (strong) IBOutlet NSTextField *Byte2Dec;

@property (strong) IBOutlet NSTextField *statusHex;
@property (strong) IBOutlet NSTextField *Byte1Hex;
@property (strong) IBOutlet NSTextField *Byte2Hex;

@property (strong) IBOutlet NSTextField *statusBin;
@property (strong) IBOutlet NSTextField *Byte1Bin;
@property (strong) IBOutlet NSTextField *Byte2Bin;

- (IBAction)changeMessageType:(NSPopUpButton *)sender;
- (IBAction)changeChannel:(NSPopUpButton *)sender;
- (IBAction)statusByteEvent:(id)sender;

- (IBAction)changControlChange:(NSPopUpButton *)sender;
- (IBAction)changeByte1:(NSTextField *)sender;
- (IBAction)changeByte2:(NSTextField *)sender;
- (IBAction)changePitchBend:(id)sender;
- (IBAction)injectPacket:(id)sender;

- (void) reset;

@end

//
//  InjectorView.m
//  MIDILink
//
//  Created by Julian Porter on 29/07/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import "InjectorView.h"

NSString * asBin(Byte b) {
    char c[9];
    c[8]='\0';
    for(NSInteger i=0;i<8;i++) {
        NSInteger bit=b&(1<<i);
        c[7-i]=(bit) ? '1' : '0';
    }
    return [NSString stringWithCString:c encoding:NSUTF8StringEncoding];
}

@implementation InjectorView

- (void) initialise {
    self.message=[[MIDIBuilder alloc] init];

}

- (instancetype)init {
    self=[super init];
    if(self) [self initialise];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self=[super initWithCoder:coder];
    if(self) [self initialise];
    return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    self=[super initWithFrame:frameRect];
    if(self) [self initialise];
    return self;
}

- (void)reset {
    
    if([self.channel numberOfItems]==0) {
        for(NSInteger index=0;index<16;index++) {
            NSString *title=[NSString stringWithFormat:@"%ld",index];
            NSMenuItem *item=[[NSMenuItem alloc] initWithTitle:title action:NULL keyEquivalent:@""];
            [item setTag:index];
            [self.channel.menu addItem:item];
        }
    }
    if([self.messageType numberOfItems]==0) {
        for(NSInteger index=0;index<[MIDIBuilder nCommandTypes];index++) {
            MIDICommandTypes type=[MIDIBuilder commandTypes][index];
            NSString *title=[MIDIBuilder commandNameForIndex:index];
            NSMenuItem *item=[[NSMenuItem alloc] initWithTitle:title action:NULL keyEquivalent:@""];
            [item setTag:type];
            [self.messageType.menu addItem:item];
        }
    }
    if([self.controlChange numberOfItems]==0) {
        for(NSInteger index=0;index<[MIDIBuilder nControlChangeCodes];index++) {
            NSString *title=[MIDIBuilder nameAtIndex:index];
            Byte tag=[MIDIBuilder controllerCodeAtIndex:index];
            NSMenuItem *item=[[NSMenuItem alloc] initWithTitle:title action:NULL keyEquivalent:@""];
            [item setTag:tag];
            [self.controlChange.menu addItem:item];
        }
    }

    
    self.message=[[MIDIBuilder alloc] init];
    [self.messageType selectItemAtIndex:0];
    [self.channel selectItemAtIndex:0];
    [self.controlChange selectItemWithTag:0];
    
    [self.controlChange setEnabled:(self.message.type==ControlChange)];
    [self.pitchBend setEnabled:(self.message.type==PitchBend)];
    
    [self changeMessageType:nil];
}



- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (IBAction)changeMessageType:(NSPopUpButton *)sender {
    NSMenuItem *selected=[self.messageType selectedItem];
    MIDICommandTypes type=selected.tag & 0xf0;
    [self.message setType:type];
    [self.hexValue setIntValue:self.message.status];
    [self updatePitchBend];
}

- (IBAction)changeChannel:(NSPopUpButton *)sender {
    NSMenuItem *selected=[self.channel selectedItem];
    UInt8 channel=selected.tag & 0xff;
    [self.message setChannel:channel];
    [self.hexValue setIntValue:self.message.status];
    [self updatePitchBend];
}

- (IBAction)statusByteEvent:(id)sender {
}

- (void) updateDisplay {
    
}

- (void) updatePitchBend {

    NSArray *names=[MIDIBuilder dataBytesForType:self.message.type];
    NSInteger n=[names count];
    BOOL first=n>=1;
    BOOL second=n>=2;
    NSString *name1= first ? [names objectAtIndex:0] : @"Byte 1";
    NSString *name2= second ? [names objectAtIndex:1] : @"n/a";
    [self.byte1Label setStringValue:name1];
    [self.byte2Label setStringValue:name2];
    
    [self.byte1 setEnabled:first];
    [self.byte2 setEnabled:second];
    [self.controlChange setEnabled:(self.message.type==ControlChange)];
    [self.pitchBend setEnabled:(self.message.type==PitchBend)];

    
    NSInteger byte1=self.message.data1;
    [self.byte1 setIntegerValue:byte1];
    NSInteger byte2=self.message.data2;
    [self.byte2 setIntegerValue:byte2];
    NSInteger pb=((byte1&0x7f)|(byte2<<7))&0x3fff;
    [self.pitchBend setIntegerValue:pb-8192];
    
    if ([MIDIBuilder isControlCode:(Byte)byte1]) {
        [self.controlChange selectItemWithTag:(Byte)byte1];
    } else {
        [self.controlChange selectItemWithTag:0];
    }

    [self.statusDec setStringValue:[NSString stringWithFormat:@"%d",self.message.status]];
    [self.statusHex setStringValue:[NSString stringWithFormat:@"%02x",self.message.status]];
    [self.statusBin setStringValue:asBin(self.message.status)];
    
    if(first) {
        [self.Byte1Dec setStringValue:[NSString stringWithFormat:@"%d",self.message.data1]];
        [self.Byte1Hex setStringValue:[NSString stringWithFormat:@"%02x",self.message.data1]];
        [self.Byte1Bin setStringValue:asBin(self.message.data1)];
    } else {
        for(NSTextField *f in @[self.Byte1Dec,self.Byte1Hex,self.Byte1Bin]) [f setStringValue:@""];
    }
    if(second) {
        [self.Byte2Dec setStringValue:[NSString stringWithFormat:@"%d",self.message.data2]];
        [self.Byte2Hex setStringValue:[NSString stringWithFormat:@"%02x",self.message.data2]];
        [self.Byte2Bin setStringValue:asBin(self.message.data2)];
    } else {
        for(NSTextField *f in @[self.Byte2Dec,self.Byte2Hex,self.Byte2Bin]) [f setStringValue:@""];
    }
}

- (IBAction)changControlChange:(NSPopUpButton *)sender {
    NSMenuItem *selected=[self.controlChange selectedItem];
    Byte tag=selected.tag;
    if(tag!=0) [self.message setData1:tag];
    [self updatePitchBend];
}

- (IBAction)changeByte1:(NSTextField *)sender {
    [self.message setData1:self.byte1.integerValue];
    [self updatePitchBend];
}

- (IBAction)changeByte2:(NSTextField *)sender {
    [self.message setData2:self.byte2.integerValue];
    [self updatePitchBend];
}

- (IBAction)changePitchBend:(id)sender {
    NSInteger pb=[self.pitchBend integerValue]+8192;
    [self.message setData1:pb&0x7f];
    [self.message setData2:(pb>>7)&0x7f];
    [self updatePitchBend];
}

- (IBAction)injectPacket:(id)sender {
}
@end

//
//  MIDIManager.h
//  MIDIManager
//
//  Created by Julian Porter on 04/05/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//! Project version number for MIDIManager.
FOUNDATION_EXPORT double MIDIManagerVersionNumber;

//! Project version string for MIDIManager.
FOUNDATION_EXPORT const unsigned char MIDIManagerVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <MIDIManager/PublicHeader.h>

#import <MIDIManager/MIDISystem.h>
#import <MIDIManager/MIDIThing.h>
#import <MIDIManager/Endpoint.h>
#import <MIDIManager/MIDILink.h>
#import <MIDIManager/LinkWrapper.h>
#import <MIDIManager/EndpointWrapper.h>
#import <MIDIManager/MIDIDecoder.h>
#import <MIDIManager/MIDIMessage.h>
#import <MIDIManager/MIDISerialiser.h>
#import <MIDIManager/MIDIXMLSerialiser.h>
#import <MIDIManager/MIDICSVSerialiser.h>
#import <MIDIManager/MIDIJSONSerialiser.h>

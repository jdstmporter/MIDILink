//
//  EndPointList.h
//  MIDILink
//
//  Created by Julian Porter on 28/04/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MIDIManager/MIDIManager.h>




@interface EndPoints : NSView <NSTableViewDelegate,NSTableViewDataSource>

@property (strong,nonatomic) NSArray * _Nonnull sources;
@property (strong,nonatomic) NSArray * _Nonnull destinations;
@property (atomic) NSInteger source;
@property (atomic) NSInteger destination;

@property (readonly) EndPointPair * _Nullable linkablePair;

@property (weak,nonatomic) IBOutlet NSTableView * _Nullable sourcesView;
@property (weak,nonatomic) IBOutlet NSTableView * _Nullable destinationsView;

- (IBAction) action:(NSTableView * _Nullable)sender;
- (IBAction) doubleAction:(NSTableView * _Nullable)sender;

- (void) scan;



@end

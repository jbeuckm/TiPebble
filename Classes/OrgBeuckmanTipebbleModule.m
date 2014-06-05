/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "OrgBeuckmanTipebbleModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"


@implementation OrgBeuckmanTipebbleModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"01b0607f-455b-4c1e-8f26-a07128d90089";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"org.beuckman.tipebble";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];

    [[PBPebbleCentral defaultCentral] setDelegate:self];

    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:@"foo",@"name",nil];
    [self fireEvent:@"foo" withObject:event];
    
    
	NSLog(@"[INFO] %@ loaded",self);
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidConnect:(PBWatch*)watch isNew:(BOOL)isNew {
    NSLog(@"Pebble connected: %@", [watch name]);
    _connectedWatch = watch;

    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:[watch name],@"name",nil];
    [self fireEvent:@"watchConnected" withObject:event];
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidDisconnect:(PBWatch*)watch {
    NSLog(@"Pebble disconnected: %@", [watch name]);
    
    if (_connectedWatch == watch || [watch isEqual:_connectedWatch]) {
        _connectedWatch = nil;
    }

    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:[watch name],@"name",nil];
    [self fireEvent:@"watchDisconnected" withObject:event];
}


-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup 

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
	if (count == 1 && [type isEqualToString:@"my_event"])
	{
		// the first (of potentially many) listener is being added 
		// for event named 'my_event'
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
	if (count == 0 && [type isEqualToString:@"my_event"])
	{
		// the last listener called for event named 'my_event' has
		// been removed, we can optionally clean up any resources
		// since no body is listening at this point for that event
	}
}

#pragma Public APIs

-(id)setAppUUID:(id)uuid
{
    NSString *uuidString = [TiUtils stringValue:uuid];

    uuid_t myAppUUIDbytes;
    NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:uuidString];
    [myAppUUID getUUIDBytes:myAppUUIDbytes];
    
    [[PBPebbleCentral defaultCentral] setAppUUID:[NSData dataWithBytes:myAppUUIDbytes length:16]];
}


-(id)example:(id)args
{
	// example method
	return @"hello world";
}

-(id)exampleProp
{
	// example property getter
	return @"hello world";
}

-(void)setExampleProp:(id)value
{
	// example property setter
}

@end
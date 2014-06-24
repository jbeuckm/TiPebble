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
    
    _connectedWatch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
    [_connectedWatch appMessagesAddReceiveUpdateHandler:^BOOL(PBWatch *watch, NSDictionary *update) {
        NSLog(@"Received message: %@", update);
        [self fireEvent:@"update" withObject:update];
        return YES;
    }];
    
    pebbleDataQueue = [[KBPebbleMessageQueue alloc] init];
    pebbleDataQueue.watch = _connectedWatch;
    
	NSLog(@"[INFO] %@ loaded", self);
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

-(void)setAppUUID:(id)uuid
{
//    ENSURE_UI_THREAD_1_ARG(uuid);
    ENSURE_SINGLE_ARG(uuid, NSString);
    
    NSLog(@"[INFO] TiPebble setAppUUID() with %@", uuid);

    NSString *uuidString = [TiUtils stringValue:uuid];

    uuid_t myAppUUIDbytes;
    NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:uuidString];
    [myAppUUID getUUIDBytes:myAppUUIDbytes];
    NSLog(@"%@", myAppUUID);

    [[PBPebbleCentral defaultCentral] setAppUUID:[NSData dataWithBytes:myAppUUIDbytes length:16]];
}


-(id)connectedCount
{
    NSArray *connected = [[PBPebbleCentral defaultCentral] connectedWatches];
    return NUMINT((int)connected.count);
}

-(void)sendMessage:(id)args
{
    if (![self checkWatchConnected]) return;
    
    ENSURE_UI_THREAD_1_ARG(args);
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    NSLog(@"[INFO] TiPebble sendMessage()");
    
    id success = [args objectForKey:@"success"];
    id error = [args objectForKey:@"error"];
    RELEASE_TO_NIL(successCallback);
    RELEASE_TO_NIL(errorCallback);
    successCallback = [success retain];
    errorCallback = [error retain];
    
    NSDictionary *message = [args objectForKey:@"message"];
    NSMutableDictionary *update = [[NSMutableDictionary alloc] init];

    NSMutableArray *keys = [[message allKeys] mutableCopy];
    
    for (NSString *key in keys) {
        
        id obj = [message objectForKey: key];
        
        NSNumber *updateKey = @([key integerValue]);

        if ([obj isKindOfClass:[NSString class]]) {
            NSString *objString = [[NSString alloc] initWithString:obj];
            NSLog(@"[INFO] adding NSString %@", objString);
            [update setObject:objString forKey:updateKey];
        }
        if ([obj isKindOfClass:[NSNumber class]]) {
            NSNumber *objNumber = [[NSNumber alloc] initWithInteger:[obj integerValue]];
            NSLog(@"[INFO] adding NSNumber %@", objNumber);
            [update setObject:objNumber forKey:updateKey];
        }

    }
    
    NSLog(@"[INFO] %@", update);

    [_connectedWatch appMessagesPushUpdate:update onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
        if (!error) {
            NSLog(@"Successfully sent message.");
            [self _fireEventToListener:@"success" withObject:nil listener:successCallback thisObject:nil];
        }
        else {
            NSLog(@"Error sending message: %@", error);
            [self _fireEventToListener:@"error" withObject:error listener:errorCallback thisObject:nil];
        }
    }];

}

-(BOOL)checkWatchConnected
{
    if (_connectedWatch == nil) {
        
        NSLog(@"[ERROR] No Pebble watch connected.");
        if (errorCallback != nil) {
            NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:@"No Pebble watch connected.",@"message",nil];
            [self _fireEventToListener:@"error" withObject:event listener:errorCallback thisObject:nil];
        }
        
        return FALSE;
    }
    else {
        return TRUE;
    }
}

-(void)getVersionInfo:(id)args
{
    if (![self checkWatchConnected]) return;
    
    ENSURE_UI_THREAD_1_ARG(args);
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    NSLog(@"[INFO] TiPebble getVersionInfo()");
    
    id success = [args objectForKey:@"success"];
    id error = [args objectForKey:@"error"];
    RELEASE_TO_NIL(successCallback);
    RELEASE_TO_NIL(errorCallback);
    successCallback = [success retain];
    errorCallback = [error retain];

    [_connectedWatch getVersionInfo:^(PBWatch *watch, PBVersionInfo *versionInfo ) {
        
        NSLog(@"Pebble firmware os version: %li", (long)versionInfo.runningFirmwareMetadata.version.os);
        NSLog(@"Pebble firmware major version: %li", (long)versionInfo.runningFirmwareMetadata.version.major);
        NSLog(@"Pebble firmware minor version: %li", (long)versionInfo.runningFirmwareMetadata.version.minor);
        NSLog(@"Pebble firmware suffix version: %@", versionInfo.runningFirmwareMetadata.version.suffix);
        
        if (successCallback != nil) {
            NSDictionary *versionInfoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSString stringWithFormat:@"%li", (long)versionInfo.runningFirmwareMetadata.version.os], @"os",
                    [NSString stringWithFormat:@"%li", (long)versionInfo.runningFirmwareMetadata.version.major], @"major",
                    [NSString stringWithFormat:@"%li", (long)versionInfo.runningFirmwareMetadata.version.minor], @"minor",
                    versionInfo.runningFirmwareMetadata.version.suffix, @"suffix",
                    nil];

            [self _fireEventToListener:@"success" withObject:versionInfoDict listener:successCallback thisObject:nil];
        }
        
    }
            onTimeout:^(PBWatch *watch) {
                NSLog(@"[INFO] Timed out trying to get version info from Pebble.");
                if (errorCallback != nil) {
                    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:@"Timed out trying to get version info from Pebble.",@"message",nil];
                    [self _fireEventToListener:@"error" withObject:event listener:errorCallback thisObject:nil];
                }
            }
     ];
    
}


-(void)launchApp:(id)args
{
    if (![self checkWatchConnected]) return;
    
//    ENSURE_UI_THREAD_1_ARG(args);
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    NSLog(@"[INFO] TiPebble launchApp()");
    
    id success = [args objectForKey:@"success"];
    id error = [args objectForKey:@"error"];
    RELEASE_TO_NIL(successCallback);
    RELEASE_TO_NIL(errorCallback);
    successCallback = [success retain];
    errorCallback = [error retain];
    
    [_connectedWatch appMessagesLaunch:^(PBWatch *watch, NSError *error) {
        if (!error) {
            if (successCallback != nil) {
                NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:@"Successfully launched app.",@"message",nil];
                [self _fireEventToListener:@"success" withObject:event listener:successCallback thisObject:nil];
            }
        }
        else {
            NSLog(@"[ERROR] error launching Pebble app");
            if (errorCallback != nil) {
                NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:error.description,@"description",nil];
                [self _fireEventToListener:@"error" withObject:event listener:errorCallback thisObject:nil];
            }
        }
    }];
}


-(void)killApp:(id)args
{
    if (![self checkWatchConnected]) return;
    
    ENSURE_UI_THREAD_1_ARG(args);
    ENSURE_SINGLE_ARG(args, NSDictionary);

    NSLog(@"[INFO] TiPebble killApp()");

    id success = [args objectForKey:@"success"];
    id error = [args objectForKey:@"error"];
    RELEASE_TO_NIL(successCallback);
    RELEASE_TO_NIL(errorCallback);
    successCallback = [success retain];
    errorCallback = [error retain];
    
    [_connectedWatch appMessagesKill:^(PBWatch *watch, NSError *error) {
        if (!error) {
            if (successCallback != nil) {
                NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:@"Successfully killed app.",@"message",nil];
                [self _fireEventToListener:@"success" withObject:event listener:successCallback thisObject:nil];
            }
        }
        else {
            NSLog(@"[ERROR] error killing Pebble app");
            if (errorCallback != nil) {
                NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:error.description,@"description",nil];
                [self _fireEventToListener:@"error" withObject:event listener:errorCallback thisObject:nil];
            }
        }
    }];
}


-(void)sendImage:(id)args
{
    if (![self checkWatchConnected]) return;
    
    ENSURE_UI_THREAD_1_ARG(args);
    ENSURE_SINGLE_ARG(args, NSDictionary);

    NSLog(@"[INFO] TiPebble sendImage()");

    TiBlob *blob = [args objectForKey:@"image"];
    UIImage *image = [blob image];

    NSInteger updateKey = [TiUtils intValue:[args objectForKey:@"key"]];
    [self sendImageToPebble:image withKey: @(updateKey)];
    
    NSLog(@"[INFO] Back from sendImageToPebble");

}

#define MAX_OUTGOING_SIZE 95

-(void)sendImageToPebble:(UIImage*)image withKey:(id)key {

    PBBitmap* pbBitmap = [PBBitmap pebbleBitmapWithUIImage:image];
    size_t length = [pbBitmap.pixelData length];
    uint8_t j = 0;
    NSLog(@"length of the pixelData: %zu", length);
    for(size_t i = 0; i < length; i += MAX_OUTGOING_SIZE-1) {
        NSMutableData *outgoing = [[NSMutableData alloc] initWithCapacity:MAX_OUTGOING_SIZE];
        [outgoing appendBytes:&j length:1];
        [outgoing appendData:[pbBitmap.pixelData subdataWithRange:NSMakeRange(i, MIN(MAX_OUTGOING_SIZE-1, length - i))]];
        //enqueue ex: https://github.com/Katharine/peapod/
        [pebbleDataQueue enqueue:@{key: outgoing}];
        ++j;
        NSLog(@" --enqueued %lu bytes", MIN(MAX_OUTGOING_SIZE-1, length - i));
    }
}



@end

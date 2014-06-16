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
    pebbleDataQueue = [[KBPebbleMessageQueue alloc] init];
    
    NSArray *connected = [[PBPebbleCentral defaultCentral] connectedWatches];
	NSLog(@"[INFO] TiPebble connected.count = %li", (long)connected.count);
	if (connected.count > 0) {
        _connectedWatch = [connected objectAtIndex:0];
        pebbleDataQueue.watch = _connectedWatch;
    }
    else {
        _connectedWatch = nil;
    }
    
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
    NSLog(@"[INFO] TiPebble setAppUUID()");
    
    NSString *uuidString = [TiUtils stringValue:uuid];

    uuid_t myAppUUIDbytes;
    NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:uuidString];
    [myAppUUID getUUIDBytes:myAppUUIDbytes];
    
    [[PBPebbleCentral defaultCentral] setAppUUID:[NSData dataWithBytes:myAppUUIDbytes length:16]];
}


-(id)connectedCount
{
    NSArray *connected = [[PBPebbleCentral defaultCentral] connectedWatches];
    return NUMINT((int)connected.count);
}


-(void)getVersionInfo:(id)args
{
    ENSURE_UI_THREAD_1_ARG(args);
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    NSLog(@"[INFO] TiPebble getVersionInfo()");
    
    id success = [args objectForKey:@"success"];
    id error = [args objectForKey:@"error"];
    RELEASE_TO_NIL(successCallback);
    RELEASE_TO_NIL(errorCallback);
    successCallback = [success retain];
    errorCallback = [error retain];

    if (_connectedWatch == nil) {
        
        NSLog(@"[INFO] No Pebble watch connected.");
        if (errorCallback != nil) {
            NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:@"No Pebble watch connected.",@"message",nil];
            [self _fireEventToListener:@"error" withObject:event listener:errorCallback thisObject:nil];
        }
        
        return;
    }

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
    NSLog(@"[INFO] TiPebble launchApp()");
    
//    ENSURE_UI_THREAD_1_ARG(args);
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    id success = [args objectForKey:@"success"];
    id error = [args objectForKey:@"error"];
    RELEASE_TO_NIL(successCallback);
    RELEASE_TO_NIL(errorCallback);
    successCallback = [success retain];
    errorCallback = [error retain];
    
    if (_connectedWatch == nil) {
        if (errorCallback != nil) {
            NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:@"No Pebble watch connected.",@"message",nil];
            [self _fireEventToListener:@"error" withObject:event listener:errorCallback thisObject:nil];
        }
        return;
    }
    
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
    NSLog(@"[INFO] TiPebble killApp()");

//    ENSURE_UI_THREAD_1_ARG(args);
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    id success = [args objectForKey:@"success"];
    id error = [args objectForKey:@"error"];
    RELEASE_TO_NIL(successCallback);
    RELEASE_TO_NIL(errorCallback);
    successCallback = [success retain];
    errorCallback = [error retain];
    
    if (_connectedWatch == nil) {
        if (errorCallback != nil) {
            NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:@"No Pebble watch connected.",@"message",nil];
            [self _fireEventToListener:@"error" withObject:event listener:errorCallback thisObject:nil];
        }
        return;
    }
    
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

int sendImageCount = 0;

-(void)sendImage:(id)args
{    
    ENSURE_UI_THREAD_1_ARG(args);
    ENSURE_SINGLE_ARG(args, NSDictionary);

    NSLog(@"[INFO] TiPebble sendImage() %d", sendImageCount);
    sendImageCount++;

    TiBlob *blob = [args objectForKey:@"image"];
    UIImage *image = [blob image];

    
    if (_connectedWatch == nil || [_connectedWatch isConnected] == NO) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"No connected watch!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    [self sendImageToPebble:image withKey: @(2)];
    
    NSLog(@"[INFO] Back from sendImageToPebble");
/*
    return;

    //    NSData *bitmap = [KBPebbleImage ditheredBitmapFromImage:img withHeight:128 width:128];
    //    NSData *bitmap = [KBPebbleImage ditheredBitmapFromImage:img withHeight:4 width:4];
    PBBitmap *bitmap = [PBBitmap pebbleBitmapWithUIImage : img];
    
    NSLog(@"bitmap.rowSizeBytes: %hu", bitmap.rowSizeBytes);
    NSLog(@"bitmap.pixelData: %@", bitmap.pixelData);
    
    
    // Get the temperature:
    temperature++;
    
    // Get weather icon:
    uint8_t weatherIconID = 0;
    
    // Send data to watch:
    // See demos/feature_app_messages/weather.c in the native watch app SDK for the same definitions on the watch's end:
    NSNumber *iconKey = @(0); // This is our custom-defined key for the icon ID, which is of type uint8_t.
    NSNumber *temperatureKey = @(1); // This is our custom-defined key for the temperature string.
    NSNumber *bitmapKey = @(2); // This is our custom-defined key for the bitmap (NSData).
    
    NSDictionary *update = @{
                             iconKey:        [NSNumber numberWithUint8:weatherIconID],
                             temperatureKey: [NSString stringWithFormat:@"%d\u00B0C", temperature]
                             };
    
    [_targetWatch appMessagesPushUpdate:update onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
        message = error ? [error localizedDescription] : @"-Update sent!";
        showAlert();
    }];
    */
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
        NSLog(@" - - - enqueued %lu bytes", MIN(MAX_OUTGOING_SIZE-1, length - i));
    }
}



@end

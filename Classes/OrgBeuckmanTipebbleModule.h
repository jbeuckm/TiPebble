/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "TiModule.h"
#import <PebbleKit/PebbleKit.h>

@interface OrgBeuckmanTipebbleModule : TiModule <PBPebbleCentralDelegate>
{
    PBWatch *_connectedWatch;

    KrollCallback *successCallback;
    KrollCallback *errorCallback;
    
}

@end

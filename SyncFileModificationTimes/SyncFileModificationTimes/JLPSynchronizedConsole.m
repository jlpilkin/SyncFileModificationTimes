//
//  JLPSynchronizedConsole.m
//  SyncFileModificationTimes
//
//  Created by Joshua Pilkington on 4/18/16.
//  Copyright © 2016 Joshua Pilkington. All rights reserved.
//

#import "JLPSynchronizedConsole.h"

@implementation JLPSynchronizedConsole

static BOOL _JLPSynchronizedConsole_isPrinting;

+(BOOL) isPrinting
{
	@synchronized( self )
	{
		return _JLPSynchronizedConsole_isPrinting;
	}
}

+(void) setIsPrinting:(BOOL)isPrinting
{
	@synchronized( self )
	{
		_JLPSynchronizedConsole_isPrinting = isPrinting;
	}
}

+(void) printString:(const char*)string
{
	@synchronized( self )
	{
		while( [self isPrinting] )
		{
			[NSThread sleepForTimeInterval:0.001];
		}
		[self setIsPrinting:true];
		printf( "%s", string );
		[self setIsPrinting:false];
	}
}

/**
 * @discussion Initializes this class before it receives its first message
 */
+(void) load
{
	if( self == [JLPSynchronizedConsole self] )
	{
		_JLPSynchronizedConsole_isPrinting = false;
	}
}


@end

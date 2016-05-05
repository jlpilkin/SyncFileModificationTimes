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

+(void) printString:(const char*)string
{
	@synchronized( self )
	{
		printf( "%s", string );
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

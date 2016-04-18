//
//  JLPSyncFileInfoThread.m
//  SyncFileModificationTimes
//
//  Created by Joshua Pilkington on 4/17/16.
//  Copyright © 2016 Joshua Pilkington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLPSyncFileInfoThread.h"
#import "JLPSyncFileInfoThreadParams.h"

@implementation JLPSyncFileInfoThread

/**
 * @discussion Initializes a new instance of a SyncFileInfos daemon thread
 *             with the specified parameters
 * @param params SyncFileInfos daemon thread parameters
 * @return New instance
 */
-(id) initWithParams:(JLPSyncFileInfoThreadParams*)params
{
	self = [super init];
	if( self != nil )
	{
		self.threadFswatch = [[NSThread alloc] initWithTarget:self.class
			selector:@selector(runFswatchThread:)
			object:(NSObject*)params];
	}
	return self;
}

/**
 * @discussion Main thread method for a SyncFileInfos daemon thread
 *
 * @param params Thread parameters
 */
+(void) runFswatchThread:(NSObject*)params
{
	// TODO: Create NSTask for fswatch command
}

@end

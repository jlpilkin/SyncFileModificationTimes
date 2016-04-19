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
	// Get a reference to the thread parameters
	if( params == nil || ![params isKindOfClass:JLPSyncFileInfoThreadParams.class] )
	{
		return;
	}
	JLPSyncFileInfoThreadParams* threadParams = (JLPSyncFileInfoThreadParams*)params;

	// Create NSTask for fswatch command
	NSPipe *pipeFswatch = [NSPipe pipe];
	NSTask *taskFswatch = [[NSTask alloc] init];
	[taskFswatch setLaunchPath: threadParams.fswatchPath];
	[taskFswatch setStandardOutput: [NSPipe pipe]];
	[taskFswatch setStandardOutput: pipeFswatch];
	taskFswatch.arguments = @[
		@"-0",
		threadParams.directoryFilesSource
	];
	
	// Create NSTask for xargs command
	NSPipe *pipeXargs = [NSPipe pipe];
	NSTask *taskXargs = [[NSTask alloc] init];
	taskXargs.launchPath = @"/usr/bin/xargs";
	[taskXargs setStandardInput: pipeFswatch];
	[taskXargs setStandardOutput: pipeXargs];
	taskXargs.arguments = @[
		@"-0",
		@"-n",
		@"1",
		@"-I",
		@"{}",
		threadParams.syncFileModificationTimesPath,
		threadParams.directoryFilesSource,
		threadParams.directoryFilesDestination,
		@"{}"
	];
	[taskFswatch launch];
	[taskXargs launch];
	
	// Keep reading the task
	NSFileHandle *fileXargs = pipeXargs.fileHandleForReading;
	while( [taskFswatch isRunning] )
	{
		NSData* dataLast = [fileXargs availableData];
		if( dataLast != nil && [dataLast bytes] != NULL )
		{
			printf( "%s", (const char*)[dataLast bytes] );
		}
		else
		{
			[NSThread sleepForTimeInterval:0.010];
		}
	}
	NSData* dataLast = [fileXargs availableData];
	if( dataLast != nil && [dataLast bytes] != NULL )
	{
		printf( "%s", (const char*)[dataLast bytes] );
	}
}

@end

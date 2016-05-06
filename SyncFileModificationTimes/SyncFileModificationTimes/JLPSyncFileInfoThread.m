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
#import "JLPSynchronizedConsole.h"

@implementation JLPSyncFileInfoThread

/**
 * @discussion Initializes a new instance of a SyncFileInfos daemon thread
 *             with no parameters
 * @return New empty instance
 */
-(id) init
{
	self = [super init];
	if( self != nil )
	{
		self->_done = 0;
		self.threadFswatch = nil;
		self.dataAvailable = nil;
	}
	return self;
}

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
		self->_done = 0;
		self.dataAvailable = nil;
		params.thread = self;
		self.threadFswatch = [[NSThread alloc] initWithTarget:self.class
			selector:@selector(runFswatchThread:)
			object:(NSObject*)params];
	}
	return self;
}

/**
 * @discussion Determines if this thread is set to the done state
 * @return Done state
 */
-(BOOL) isDone
{
	@synchronized( self )
	{
		return self->_done == 1;
	}
}

/**
 * @discussion Sets the done state to true
 */
-(void) setDone
{
	@synchronized( self )
	{
		self->_done = 1;
	}
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

	// Enable unbuffered IO
	NSDictionary *defaultEnvironment = [[NSProcessInfo processInfo] environment];
	NSMutableDictionary *environment = [[NSMutableDictionary alloc] initWithDictionary:defaultEnvironment];
	[environment setObject:@"YES" forKey:@"NSUnbufferedIO"];
	
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
	[taskFswatch setEnvironment:environment];
	
	// Create NSTask for xargs command
	NSPipe *pipeXargs = [NSPipe pipe];
	NSTask *taskXargs = [[NSTask alloc] init];
	taskXargs.launchPath = threadParams.xargsPath;
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
	[taskXargs setEnvironment:environment];
	
	// Get the file handle of xargs
	NSFileHandle *fileXargs = pipeXargs.fileHandleForReading;
	
	// Register for file data notifications
	[[NSNotificationCenter defaultCenter]
		addObserver:threadParams.thread
		selector:@selector(readPipe:)
		name: NSFileHandleReadCompletionNotification
		object: fileXargs];

	// Set the xargs pipe to send data notifications in the background
	[fileXargs readInBackgroundAndNotify];
	
	// Launch tasks
	[taskFswatch launch];
	[taskXargs launch];
	
	// Get the current run loop
	NSRunLoop* myRunLoop = [NSRunLoop currentRunLoop];

	// Create a run loop observer and attach it to the run loop.
	CFRunLoopObserverContext context = {
		0,
		(__bridge void *)(self),
		NULL,
		NULL,
		NULL
	};
	CFRunLoopObserverRef observer = CFRunLoopObserverCreate(
		kCFAllocatorDefault,
		kCFRunLoopAllActivities,
		YES,
		0,
		&runLoopObserver,
		&context
	);
 
	// Add the observer if possible
	if( observer )
	{
		CFRunLoopRef cfLoop = [myRunLoop getCFRunLoop];
		CFRunLoopAddObserver( cfLoop, observer, kCFRunLoopDefaultMode );
	}
	
	// Process the run loop or end the task if triggered
	while( [taskFswatch isRunning] || [taskXargs isRunning] )
	{
		if( [threadParams.thread isDone] )
		{
			[taskFswatch terminate];
			[taskXargs terminate];
		}
		else
		{
			[myRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];;
		}
	}
}

/**
 * @discussion Run loop observer
 */
void runLoopObserver(
	CFRunLoopObserverRef observer,
	CFRunLoopActivity activity,
	void* info
)
{
    // Do nothing
}

/**
 * @discussion Determines whether this thread is still running
 * @return True if running
 */
-(BOOL) isRunning
{
	@synchronized( self )
	{
		return self.threadFswatch != nil && [self.threadFswatch isExecuting];
	}
}

/**
 * @discussion Reads the data from the pipe from a data available notification
 * @param notification Data available notification
 */
-(void) readPipe:(NSNotification*)notification
{
	// Get the data
	NSData *data = [[notification userInfo]
        objectForKey:NSFileHandleNotificationDataItem];

	// Display the data
	if( data != nil && data.length > 0 )
	{
		[JLPSynchronizedConsole printString:(const char*)[data bytes]];
	}
	
	// Re-register for notifications
	[[notification object] readInBackgroundAndNotify];
}

@end

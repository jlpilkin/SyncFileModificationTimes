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
		self->_numTasksEnded = 0;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifyDone:) name:@"JLPSyncFileInfoThread_Done" object:nil];
		self.taskFswatch = nil;
		self.taskXargs = nil;
		self.threadFswatch = nil;
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
		self->_numTasksEnded = 0;
		params.thread = self;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifyDone:) name:@"JLPSyncFileInfoThread_Done" object:nil];
		self.taskFswatch = nil;
		self.taskXargs = nil;
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
 * @discussion Notifies this thread of a done state
 */
-(void) setDone
{
	[self notifyDone];
}

/**
 * @discussion Sets the done state to true
 */
-(void) setDoneState
{
	@synchronized( self )
	{
		self->_done = 1;
	}
}

/**
 * @discussion Notifies the thread of the done state
 */
-(void) notifyDone
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"JLPSyncFileInfoThread_Done" object:self];
}

/**
 * @discussion Performs the done state notification action.
 *             All associated tasks are terminated.
 */
-(void) handleNotifyDone:(NSNotification*)note
{
	[self.taskFswatch terminate];
	[self.taskXargs terminate];
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
	taskFswatch.terminationHandler = ^(NSTask* task){ [threadParams.thread taskTermination:task]; };
	threadParams.thread.taskFswatch = taskFswatch;
	
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
	taskXargs.terminationHandler = ^(NSTask* task){ [threadParams.thread taskTermination:task]; };
	threadParams.thread.taskXargs = taskXargs;
	
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
	JLPSyncFileInfoThread* threadLocal = threadParams.thread;
	while( ![threadLocal tasksEnded] && [myRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]] );
	[threadLocal setDoneState];
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
	return ![self isDone];
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

/**
 * @discussion Increments the number of tasks ended when a task ends
 * @param task Task which invoked this notification
 */
-(void) taskTermination:(NSTask*)task
{
	OSAtomicIncrement64Barrier( &self->_numTasksEnded );
}

/**
 * @discussion Determines if both tasks have ended
 */
-(BOOL) tasksEnded
{
	return OSAtomicCompareAndSwap64Barrier( 2, 2, &self->_numTasksEnded );
}

@end

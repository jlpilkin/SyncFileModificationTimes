//
//  JLPSyncFileInfoThread.h
//  SyncFileModificationTimes
//
//  Created by Joshua Pilkington on 4/17/16.
//  Copyright © 2016 Joshua Pilkington. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JLPSyncFileInfoThreadParams;

/**
 * @discussion Manages processes for running the fswatch command for the
 *             SyncFileModificationTimes daemon
 */
@interface JLPSyncFileInfoThread : NSObject
{
	volatile sig_atomic_t _done;
	volatile int64_t _numTasksEnded;
}

@property NSThread* threadFswatch;
@property NSTask* taskFswatch;
@property NSTask* taskXargs;

-(id) initWithParams:(JLPSyncFileInfoThreadParams*)params;
-(BOOL) isDone;
-(void) setDone;
-(void) setDoneState;
-(void) notifyDone;
-(void) handleNotifyDone:(NSNotification*)note;
-(BOOL) isRunning;
+(void) runFswatchThread:(NSObject*)params;
-(void) readPipe:(NSNotification*)notification;
-(void) taskTermination:(NSTask*)task;
-(BOOL) tasksEnded;

void runLoopObserver(
	CFRunLoopObserverRef observer,
	CFRunLoopActivity activity,
	void* info
);

@end

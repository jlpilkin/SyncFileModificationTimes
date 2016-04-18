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

@property NSThread* threadFswatch;

-(id) initWithParams:(JLPSyncFileInfoThreadParams*)params;
+(void) runFswatchThread:(NSObject*)params;

@end

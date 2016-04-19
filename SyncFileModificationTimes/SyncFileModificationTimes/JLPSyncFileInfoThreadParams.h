//
//  JLPSyncFileInfoThreadParams.h
//  SyncFileModificationTimes
//
//  Created by Joshua Pilkington on 4/17/16.
//  Copyright © 2016 Joshua Pilkington. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @discussion Parameters to pass to a SyncFileInfos daemon thread process
 */
@interface JLPSyncFileInfoThreadParams : NSObject

@property NSString* directoryFilesSource;
@property NSString* directoryFilesDestination;
@property NSString* fswatchPath;
@property NSString* syncFileModificationTimesPath;
@property NSString* shellPath;

-(id) initWithParams:(NSString*)directoryFilesSource
	directoryFilesDestination:(NSString*)directoryFilesDestination
	fswatchPath:(NSString*)fswatchPath
	syncFileModificationTimesPath:(NSString*)syncFileModificationTimesPath
	shellPath:(NSString*)shellPath;

@end

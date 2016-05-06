//
//  JLPSyncFileInfoThreadParams.m
//  SyncFileModificationTimes
//
//  Created by Joshua Pilkington on 4/17/16.
//  Copyright © 2016 Joshua Pilkington. All rights reserved.
//

#import "JLPSyncFileInfoThreadParams.h"

@implementation JLPSyncFileInfoThreadParams

/**
 * @discussion Initializes a new empty instance of a SyncFileInfos daemon thread parameters
 *             structure.
 * @return New empty instance
 */
-(id) init
{
	self = [super init];
	if( self != nil )
	{
		self.thread = nil;
		self.directoryFilesSource = nil;
		self.directoryFilesDestination = nil;
		self.fswatchPath = nil;
		self.xargsPath = nil;
		self.syncFileModificationTimesPath = nil;
		self.shellPath = nil;
	}
	return self;
}

/**
 * @discussion Initializes a new instance of a SyncFileInfos daemon thread parameters
 *             structure with the specified parameters
 * @param directoryFilesSource Source directory to watch
 * @param directoryFilesDestination Destination directory to watch
 * @param fswatchPath fswatch path
 * @param syncFileModificationTimesPath SyncFileModificationTimes executable path
 * @return New instance
 */
-(id) initWithParams:(NSString*)directoryFilesSource
	directoryFilesDestination:(NSString*)directoryFilesDestination
	fswatchPath:(NSString*)fswatchPath
	xargsPath:(NSString*)xargsPath
	syncFileModificationTimesPath:(NSString*)syncFileModificationTimesPath
	shellPath:(NSString*)shellPath
{
	self = [super init];
	if( self != nil )
	{
		self.thread = nil;
		self.directoryFilesSource = directoryFilesSource;
		self.directoryFilesDestination = directoryFilesDestination;
		self.fswatchPath = fswatchPath;
		self.xargsPath = xargsPath;
		self.syncFileModificationTimesPath = syncFileModificationTimesPath;
		self.shellPath = shellPath;
	}
	return self;
}

@end

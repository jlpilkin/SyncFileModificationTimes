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
		self.directoryFiles = nil;
	}
	return self;
}

/**
 * @discussion Initializes a new instance of a SyncFileInfos daemon thread parameters
 *             structure with the specified parameters
 * @param directoryFiles Directory to watch
 * @return New instance
 */
-(id) initWithParams:(NSString*)directoryFiles
{
	self = [super init];
	if( self != nil )
	{
		self.directoryFiles = directoryFiles;
	}
	return self;
}

@end

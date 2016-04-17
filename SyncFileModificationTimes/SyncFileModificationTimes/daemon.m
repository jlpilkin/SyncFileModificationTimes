//
//  daemon.m
//  SyncFileModificationTimes
//
//  Created by Joshua Pilkington on 4/16/16.
//  Copyright © 2016 Joshua Pilkington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPToolsStringUtils.h"
#import "JLPSyncFileInfoDaemonSettings.h"

/**
 * @discussion Main entry point for the daemon application
 *
 * @param argc Argument count
 * @param argv Arguments
 */
int main( int argc, const char * argv[] )
{
	@autoreleasepool
	{
		// Attempt to find the location of the SyncFileModificationTimes executable
		// Get the current directory
		NSFileManager *filemgr = [NSFileManager new];
		if( filemgr == nil )
		{
			printf( "[ERROR] Unable to initialize file manager\n" );
			return 1;
		}
		NSString* directoryCurrent = [filemgr currentDirectoryPath];
		if( [JPToolsStringUtils isNilOrWhitespace:directoryCurrent] )
		{
			printf( "[ERROR] Unable to determine the working directory\n" );
			return 1;
		}
		
		// Append SyncFileModificationTimes to the working directory
		BOOL bIsDirectory = false;
		NSString* pathSyncFileModificationTimes = [directoryCurrent
			stringByAppendingPathComponent:@"SyncFileModificationTimes"];
		if(
			[JPToolsStringUtils isNilOrWhitespace:pathSyncFileModificationTimes] ||
			![[NSFileManager defaultManager] fileExistsAtPath:pathSyncFileModificationTimes isDirectory:&bIsDirectory] ||
			bIsDirectory
		)
		{
			printf( "[ERROR] Unable to determine location of SyncFileModificationTimes\n" );
			return 1;
		}
		
		// Determine the location of fswatch
		// Obtain the path and find one which contains fswatch
		NSString* errorFswatch = @"[ERROR] Unable to determine location of fswatch";
		NSString* fswatchPath = nil;
		NSString* environmentPath = [[[NSProcessInfo processInfo] environment] objectForKey:@"PATH"];
		if( [JPToolsStringUtils isNilOrWhitespace:environmentPath] )
		{
			printf( "%s\n", [errorFswatch cStringUsingEncoding:[NSString defaultCStringEncoding]] );
			return 1;
		}
		NSArray* environmentPathArray = [environmentPath componentsSeparatedByString:@":"];
		if( environmentPathArray == nil || [environmentPathArray count] == 0U )
		{
			printf( "%s\n", [errorFswatch cStringUsingEncoding:[NSString defaultCStringEncoding]] );
			return 1;
		}
		for( NSString* pathComponent in environmentPathArray )
		{
			// Skip empty components
			if( [JPToolsStringUtils isNilOrWhitespace:pathComponent] )
			{
				continue;
			}
			
			// Append 'fswatch' to this path component
			NSString* fswatchPathPreliminary = [[JPToolsStringUtils trim:pathComponent] stringByAppendingPathComponent:@"fswatch"];
			
			// Determine if this file exists
			if(
				![JPToolsStringUtils isNilOrWhitespace:fswatchPathPreliminary] &&
				![[NSFileManager defaultManager] fileExistsAtPath:fswatchPathPreliminary isDirectory:&bIsDirectory] &&
				!bIsDirectory
			)
			{
				fswatchPath = fswatchPathPreliminary;
				break;
			}
		}
		if( [JPToolsStringUtils isNilOrWhitespace:fswatchPath] )
		{
			printf( "%s\n", [errorFswatch cStringUsingEncoding:[NSString defaultCStringEncoding]] );
			return 1;
		}
		
		// TODO: Create the NSTasks for each fswatch command
	}
	return 0;
}
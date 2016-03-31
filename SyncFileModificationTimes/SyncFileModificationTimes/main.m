//
//  main.m
//  SyncFileModificationTimes
//
//  Created by Joshua Pilkington on 2/23/16.
//  Copyright © 2016 Joshua Pilkington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPToolsStringUtils.h"
#import "JLPSyncFileInfo.h"

int main( int argc, const char * argv[] )
{
	@autoreleasepool
	{
		// Deal with invalid arguments
		if( argc < 4 )
		{
			printf( "Usage: %s <source root directory> <destination root directory> <source file>\n", argv[0] );
			return 1;
		}
		
		// Used for checking whether a path is a directory
		BOOL bIsDirectory = false;
		
		// Get and check the source directory
		NSString* strDirectorySource = [NSString stringWithCString:argv[1] encoding:[NSString defaultCStringEncoding]];
		if(
			[JPToolsStringUtils isNilOrWhitespace:strDirectorySource] ||
			![[NSFileManager defaultManager] fileExistsAtPath:strDirectorySource isDirectory:&bIsDirectory]
		)
		{
			printf( "[ERROR] Invalid source directory specified: %s\n", [strDirectorySource cStringUsingEncoding:[NSString defaultCStringEncoding]] );
			return 1;
		}
		if( !bIsDirectory )
		{
			printf( "[ERROR] Invalid source directory specified: %s\n", [strDirectorySource cStringUsingEncoding:[NSString defaultCStringEncoding]] );
			return 1;
		}
		
		// Get and check the destination directory
		NSString* strDirectoryDest = [NSString stringWithCString:argv[2] encoding:[NSString defaultCStringEncoding]];
		if(
			[JPToolsStringUtils isNilOrWhitespace:strDirectoryDest] ||
			![[NSFileManager defaultManager] fileExistsAtPath:strDirectoryDest isDirectory:&bIsDirectory]
		)
		{
			printf( "[ERROR] Invalid destination directory specified: %s\n", [strDirectoryDest cStringUsingEncoding:[NSString defaultCStringEncoding]] );
			return 1;
		}
		if( !bIsDirectory )
		{
			printf( "[ERROR] Invalid destination directory specified: %s\n", [strDirectoryDest cStringUsingEncoding:[NSString defaultCStringEncoding]] );
			return 1;
		}
		
		// Get and check the source file
		NSString* strFileSource = [NSString stringWithCString:argv[3] encoding:[NSString defaultCStringEncoding]];
		if(
			[JPToolsStringUtils isNilOrWhitespace:strFileSource] ||
			![[NSFileManager defaultManager] fileExistsAtPath:strFileSource isDirectory:&bIsDirectory]
		)
		{
			printf( "[ERROR] Invalid source file specified: %s\n", [strFileSource cStringUsingEncoding:[NSString defaultCStringEncoding]] );
			return 1;
		}
		if( bIsDirectory )
		{
			printf( "[ERROR] Invalid destination directory specified: %s\n", [strDirectoryDest cStringUsingEncoding:[NSString defaultCStringEncoding]] );
			return 1;
		}
		
		// Ensure the file is in the source directory
		if( ![JPToolsStringUtils startsWith:strFileSource stringFind:strDirectorySource] )
		{
			printf(
				"[ERROR] Source file, %s, is not in the source directory: %s\n",
				[strFileSource cStringUsingEncoding:[NSString defaultCStringEncoding]],
				[strDirectorySource cStringUsingEncoding:[NSString defaultCStringEncoding]]
			);
			return 1;
		}
		
		// Get the path of the final file
		NSString* strFileDest = [strDirectoryDest stringByAppendingPathComponent:[JPToolsStringUtils removeStart:strFileSource stringRemove:strDirectorySource]];
		
		// If the destination file does not exist, exit with a warning
		if(
			[JPToolsStringUtils isNilOrWhitespace:strFileSource] ||
			![[NSFileManager defaultManager] fileExistsAtPath:strFileDest isDirectory:&bIsDirectory]
		)
		{
			printf( "[WARNING] Destination file does not exist: %s\n", [strFileDest cStringUsingEncoding:[NSString defaultCStringEncoding]] );
			return 0;
		}
		if( bIsDirectory )
		{
			printf( "[WARNING] Destination file does not exist: %s\n", [strFileDest cStringUsingEncoding:[NSString defaultCStringEncoding]] );
			return 0;
		}
		
		// Gets a SyncFileInfo representation of this command
		JLPSyncFileInfo* syncFileInfoCmd = [[JLPSyncFileInfo alloc] initWithParams:strFileSource lastFileDest:strFileDest];
		
		// Get the path of the Sync File Infos file
		NSString* filePathLastSyncFileInfo = [@"~/.syncFileInfos" stringByExpandingTildeInPath];
		NSString* filePathLastSyncFileInfoLock = [filePathLastSyncFileInfo stringByAppendingString:@"_lock"];
		
		// Get a lock on the Sync File Infos file
		NSDistributedLock* lockSyncFileInfos = [NSDistributedLock lockWithPath:filePathLastSyncFileInfoLock];
		if( lockSyncFileInfos == nil )
		{
			printf( "[ERROR] Unable to create lock on: %s\n", [filePathLastSyncFileInfo cStringUsingEncoding:[NSString defaultCStringEncoding]] );
			return 1;
		}
		while( ![lockSyncFileInfos tryLock] )
		{
			// Keep trying every 5ms
			[NSThread sleepForTimeInterval:0.005];
		}
		
		// Gets all last SyncFileInfo representations
		NSError* error = nil;
		NSArray<JLPSyncFileInfo*>* lastSyncFileInfos = nil;
		if( [[NSFileManager defaultManager] fileExistsAtPath:filePathLastSyncFileInfo isDirectory:&bIsDirectory] )
		{
			if( !bIsDirectory )
			{
				NSString* strLastSyncFileInfosFileData = [NSString stringWithContentsOfFile:filePathLastSyncFileInfo encoding:NSUTF8StringEncoding error:&error];
				if( ![JPToolsStringUtils isNilOrWhitespace:strLastSyncFileInfosFileData] )
				{
					lastSyncFileInfos = [JLPSyncFileInfo initArrayFromString:strLastSyncFileInfosFileData];
					if( lastSyncFileInfos == nil || lastSyncFileInfos.count == 0U )
					{
						lastSyncFileInfos = nil;
					}
				}
			}
		}
		
		// Determine if the last sync was for the other file - if so, then exit
		if( lastSyncFileInfos != nil )
		{
			for( JLPSyncFileInfo* lastSyncFileInfo in lastSyncFileInfos )
			{
				if(
					(
						[JPToolsStringUtils compareStringsTrimToUpper:lastSyncFileInfo.lastFileSource stringSecond:syncFileInfoCmd.lastFileDest] &&
						[JPToolsStringUtils compareStringsTrimToUpper:lastSyncFileInfo.lastFileDest stringSecond:syncFileInfoCmd.lastFileSource] &&
						[syncFileInfoCmd.timestamp timeIntervalSinceDate:lastSyncFileInfo.timestamp] <= 3.0
					) ||
					(
						[JPToolsStringUtils compareStringsTrimToUpper:lastSyncFileInfo.lastFileDest stringSecond:syncFileInfoCmd.lastFileDest] &&
						[JPToolsStringUtils compareStringsTrimToUpper:lastSyncFileInfo.lastFileSource stringSecond:syncFileInfoCmd.lastFileSource] &&
						[syncFileInfoCmd.timestamp timeIntervalSinceDate:lastSyncFileInfo.timestamp] <= 3.0
					)
				)
				{
					[lockSyncFileInfos unlock];
					printf(
						"[INFO] File dates were already updated for: %s and %s\n",
						[strFileSource cStringUsingEncoding:[NSString defaultCStringEncoding]],
						[strFileDest cStringUsingEncoding:[NSString defaultCStringEncoding]]
					);
					return 0;
				}
			}
		}
		
		// Save the last SyncFileInfo representation
		NSMutableArray<JLPSyncFileInfo*>* lastSyncFileInfosSave = [NSMutableArray<JLPSyncFileInfo*> new];
		Boolean bUpdatedInArray = false;
		if( lastSyncFileInfos != nil )
		{
			[lastSyncFileInfosSave addObjectsFromArray:lastSyncFileInfos];
			
			for( JLPSyncFileInfo* lastSyncFileInfoSave in lastSyncFileInfosSave )
			{
				if(
					[JPToolsStringUtils compareStringsTrimToUpper:lastSyncFileInfoSave.lastFileSource stringSecond:syncFileInfoCmd.lastFileSource] &&
					[JPToolsStringUtils compareStringsTrimToUpper:lastSyncFileInfoSave.lastFileDest stringSecond:syncFileInfoCmd.lastFileDest]
				)
				{
					lastSyncFileInfoSave.timestamp = syncFileInfoCmd.timestamp;
					bUpdatedInArray = true;
				}
			}
		}
		if( !bUpdatedInArray )
		{
			[lastSyncFileInfosSave addObject:syncFileInfoCmd];
		}
		NSString* strSyncFileInfosSave = [JLPSyncFileInfo saveArray:[[NSArray<JLPSyncFileInfo*> alloc] initWithArray:lastSyncFileInfosSave]];
		if( ![JPToolsStringUtils isNilOrWhitespace:strSyncFileInfosSave] )
		{
			[strSyncFileInfosSave writeToFile:[@"~/.syncFileInfos" stringByExpandingTildeInPath] atomically:true encoding:NSUTF8StringEncoding error:&error];
		}
		[lockSyncFileInfos unlock];
		lockSyncFileInfos = nil;
		
		// Get the file times of the source and the destination files
		NSDictionary* attrsSource = [[NSFileManager defaultManager] attributesOfItemAtPath:strFileSource error:&error];
		if( attrsSource == nil )
		{
			printf( "[ERROR] Unable to get attributes for source file: %s\n", [strFileSource cStringUsingEncoding:[NSString defaultCStringEncoding]] );
			return 1;
		}
		NSDate* dtModificationSource = [attrsSource fileModificationDate];
		if( dtModificationSource == nil )
		{
			printf( "[ERROR] Unable to get attributes for source file: %s\n", [strFileSource cStringUsingEncoding:[NSString defaultCStringEncoding]] );
			return 1;
		}
		NSDictionary* attrsDest = [[NSFileManager defaultManager] attributesOfItemAtPath:strFileDest error:&error];
		if( attrsDest == nil )
		{
			printf( "[ERROR] Unable to get attributes for destination file: %s\n", [strFileDest cStringUsingEncoding:[NSString defaultCStringEncoding]] );
			return 1;
		}
		NSDate* dtModificationDest = [attrsDest fileModificationDate];
		if( dtModificationDest == nil )
		{
			printf( "[ERROR] Unable to get attributes for destination file: %s\n", [strFileDest cStringUsingEncoding:[NSString defaultCStringEncoding]] );
			return 1;
		}
		
		// If the file modification dates are not the same, update the destination to the source
		if( /*![dtModificationDest isEqualToDate:dtModificationSource]*/ true )
		{
			NSDictionary* attrsSet = [NSDictionary dictionaryWithObjectsAndKeys:dtModificationSource, NSFileModificationDate, NULL];
			[[NSFileManager defaultManager] setAttributes:attrsSet ofItemAtPath:strFileDest error:&error];
			
			printf(
				"[INFO] Updated %s with date of %s\n",
				[strFileDest cStringUsingEncoding:[NSString defaultCStringEncoding]],
				[strFileSource cStringUsingEncoding:[NSString defaultCStringEncoding]]
			);
		}
		else
		{
			printf(
				"[INFO] File dates are equivalent for: %s and %s\n",
				[strFileSource cStringUsingEncoding:[NSString defaultCStringEncoding]],
				[strFileDest cStringUsingEncoding:[NSString defaultCStringEncoding]]
			);
		}
	}
	return 0;
}

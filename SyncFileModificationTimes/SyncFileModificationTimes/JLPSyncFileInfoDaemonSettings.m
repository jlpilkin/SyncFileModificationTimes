//
//  JLPSyncFileInfoDaemonSettings.m
//  SyncFileModificationTimes
//
//  Created by Joshua Pilkington on 4/16/16.
//  Copyright © 2016 Joshua Pilkington. All rights reserved.
//

#import "JLPSyncFileInfoDaemonSettings.h"
#import "JPToolsStringUtils.h"

@implementation JLPSyncFileInfoDaemonSettings

/**
 * @discussion Initializes a new empty SyncFileInfoDaemonSettings instance
 * @return New empty instance
 */
-(id) init
{
	self = [super init];
	if( self != nil )
	{
		self.directoryFirst = nil;
		self.directorySecond = nil;
	}
	return self;
}

/**
 * @discussion Initializes a new SyncFileInfoDaemonSettings instance with the
 *             specified parameters
 * @param directoryFirst First sync directory
 * @param directorySecond Second sync directory
 * @return New instance
 */
-(id) initWithParams:(NSString*)directoryFirst lastFileDest:(NSString*)directorySecond
{
	self = [super init];
	if( self != nil )
	{
		self.directoryFirst = directoryFirst;
		self.directorySecond = directorySecond;
	}
	return self;
}

/**
 * @discussion Initializes a new SyncFileInfoDaemonSettings instance with the specified dictionary
 * @param dict Dictionary of values
 * @return New instance
 */
-(id) initWithDict:(NSDictionary*)dict
{
	self = [super init];
	if( self != nil )
	{
		@try
		{
			self.directoryFirst = [NSString stringWithString:dict[@"directoryFirst"]];
			self.directorySecond = [NSString stringWithString:dict[@"directorySecond"]];
		}
		@catch( NSException* ex )
		{
			self.directoryFirst = nil;
			self.directorySecond = nil;
		}
	}
	return self;
}

/**
 * @discussion Initializes a new instance of a SyncFileInfoDaemonSettings class with the specified JSON string
 * @param data JSON string representation
 * @return New instance
 */
-(id) initFromString:(NSString*)data
{
	self = [super init];
	if( self != nil )
	{
		self.directoryFirst = nil;
		self.directorySecond = nil;
	}
	
	// Convert from string
	@try
	{
		NSError* error = nil;
		NSData* dataJson = [data dataUsingEncoding:NSUTF8StringEncoding];
		NSDictionary* dictValues = [NSJSONSerialization JSONObjectWithData:dataJson options:0 error:&error];
		if( dictValues != nil )
		{
			self.directoryFirst = [NSString stringWithString:dictValues[@"directoryFirst"]];
			self.directorySecond = [NSString stringWithString:dictValues[@"directorySecond"]];
		}
	}
	@catch( NSException* ex )
	{
		self.directoryFirst = nil;
		self.directorySecond = nil;
	}
	
	return self;
}

/**
 * @discussion Gets a dictionary representation of this SyncFileInfoDaemonSettings
 * @return Dictionary of values
 */
-(NSDictionary*) getDict
{
	return @{
		@"directoryFirst": self.directoryFirst,
		@"directorySecond" : self.directorySecond
	};
}

/**
 * @discussion Gets a string representation of the data of this SyncFileInfoDaemonSettings structure
 * @return String data
 */
-(NSString*) save
{
	NSDictionary* dictValues = [self getDict];
	NSError* error = nil;
	NSData* dataJson = [NSJSONSerialization dataWithJSONObject:dictValues options:0 error:&error];
	return [[NSString alloc] initWithData:dataJson encoding:NSUTF8StringEncoding];
}

/**
 * @discussion Determines whether this configuration instance is empty
 * @return True if empty, false if fully set
 */
-(Boolean) isEmpty
{
	return (
		self == nil ||
		[JPToolsStringUtils isNilOrWhitespace:self.directoryFirst] ||
		[JPToolsStringUtils isNilOrWhitespace:self.directorySecond]
	);
}

@end

//
//  JLPSyncFileInfo.m
//  SyncFileModificationTimes
//
//  Created by Joshua Pilkington on 2/23/16.
//  Copyright © 2016 Joshua Pilkington. All rights reserved.
//

#import "JLPSyncFileInfo.h"
#import "JPToolsStringUtils.h"

@implementation JLPSyncFileInfo

/**
 * @discussion Initializes a new empty SyncFileInfo instance
 * @return New empty instance
 */
-(id) init
{
	self = [super init];
	if( self != nil )
	{
		self.lastFileSource = nil;
		self.lastFileDest = nil;
		self.timestamp = [[NSDate alloc] initWithTimeIntervalSinceNow:0.0];
	}
	return self;
}

/**
 * @discussion Initializes a new SyncFileInfo instance with the specified parameters
 * @param lastFileSource Last source file
 * @param lastFileDest Last destination file
 * @return New instance
 */
-(id) initWithParams:(NSString*)lastFileSource lastFileDest:(NSString*)lastFileDest
{
	self = [super init];
	if( self != nil )
	{
		self.lastFileSource = lastFileSource;
		self.lastFileDest = lastFileDest;
		self.timestamp = [[NSDate alloc] initWithTimeIntervalSinceNow:0.0];
	}
	return self;
}

/**
 * @discussion Initializes a new SyncFileInfo instance with the specified dictionary
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
			NSNumberFormatter* f = [[NSNumberFormatter alloc] init];
			f.numberStyle = NSNumberFormatterDecimalStyle;
			self.lastFileSource = [NSString stringWithString:dict[@"lastFileSource"]];
			self.lastFileDest = [NSString stringWithString:dict[@"lastFileDest"]];
			self.timestamp = [[NSDate alloc] initWithTimeIntervalSince1970:[f numberFromString:dict[@"timestamp"]].doubleValue];
		}
		@catch( NSException* ex )
		{
			self.lastFileSource = nil;
			self.lastFileDest = nil;
			self.timestamp = [[NSDate alloc] initWithTimeIntervalSinceNow:0.0];
		}
	}
	return self;
}

/**
 * @discussion Initializes a new instance of a SyncFileInfo class with the specified JSON string
 * @param data JSON string representation
 * @return New instance
 */
-(id) initFromString:(NSString*)data
{
	self = [super init];
	if( self != nil )
	{
		self.lastFileSource = nil;
		self.lastFileDest = nil;
	}
	
	// Convert from string
	@try
	{
		NSError* error = nil;
		NSData* dataJson = [data dataUsingEncoding:NSUTF8StringEncoding];
		NSDictionary* dictValues = [NSJSONSerialization JSONObjectWithData:dataJson options:0 error:&error];
		if( dictValues != nil )
		{
			NSNumberFormatter* f = [[NSNumberFormatter alloc] init];
			f.numberStyle = NSNumberFormatterDecimalStyle;
			self.lastFileSource = [NSString stringWithString:dictValues[@"lastFileSource"]];
			self.lastFileDest = [NSString stringWithString:dictValues[@"lastFileDest"]];
			self.timestamp = [[NSDate alloc] initWithTimeIntervalSince1970:[f numberFromString:dictValues[@"timestamp"]].doubleValue];
		}
	}
	@catch( NSException* ex )
	{
		self.lastFileSource = nil;
		self.lastFileDest = nil;
		self.timestamp = [[NSDate alloc] initWithTimeIntervalSinceNow:0.0];
	}
	
	return self;
}

/**
 * @discussion Gets a dictionary representation of this SyncFileInfo
 * @return Dictionary of values
 */
-(NSDictionary*) getDict
{
	return @{
		@"lastFileSource": self.lastFileSource,
		@"lastFileDest" : self.lastFileDest,
		@"timestamp" : [JPToolsStringUtils doubleToString:[self.timestamp timeIntervalSince1970]]
	};
}

/**
 * @discussion Gets a string representation of the data of this SyncFileInfo structure
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
 * @discussion Determines if this SyncFileInfo structure is empty
 * @return True if empty
 */
-(Boolean) isEmpty
{
	return (
		self == nil ||
		[JPToolsStringUtils isNilOrWhitespace:self.lastFileSource] ||
		[JPToolsStringUtils isNilOrWhitespace:self.lastFileDest]
	);
}

/**
 * @discussion Initializes a new array of SyncFileInfo values from an array
 * @param data JSON data
 * @return Array of SyncFileInfo structures
 */
+(NSArray<JLPSyncFileInfo*>*) initArrayFromString:(NSString*)data
{
	@try
	{
		NSMutableArray<JLPSyncFileInfo*>* arValues = [NSMutableArray new];
	
		NSError* error = nil;
		NSData* dataJson = [data dataUsingEncoding:NSUTF8StringEncoding];
		NSArray* arJsonValues = [NSJSONSerialization JSONObjectWithData:dataJson options:0 error:&error];
		if( arJsonValues != nil && arJsonValues.count > 0U )
		{
			for( NSDictionary* dictValues in arJsonValues )
			{
				if( dictValues != nil )
				{
					JLPSyncFileInfo* syncFileInfo = [[JLPSyncFileInfo alloc] initWithDict:dictValues];
					if( syncFileInfo != nil && ![syncFileInfo isEmpty] )
					{
						[arValues addObject:syncFileInfo];
					}
				}
			}
		}
		
		if( arValues != nil && arValues.count > 0U )
		{
			return [[NSArray<JLPSyncFileInfo*> alloc] initWithArray:arValues];
		}
		else
		{
			return nil;
		}
	}
	@catch( NSException* ex )
	{
		return nil;
	}
}

/**
 * @discussion Saves an array of SyncFileInfo structures to a JSON string
 * @param array Array of SyncFileInfo structures
 * @return JSON string
 */
+(NSString*) saveArray:(NSArray<JLPSyncFileInfo*>*)array
{
	NSMutableArray* arSyncFileInfoDicts = [NSMutableArray new];
	for( JLPSyncFileInfo* syncFileInfo in array )
	{
		if( ![syncFileInfo isEmpty] )
		{
			[arSyncFileInfoDicts addObject:[syncFileInfo getDict]];
		}
	}
	if( arSyncFileInfoDicts.count > 0U )
	{
		NSError* error = nil;
		NSData* dataJson = [NSJSONSerialization dataWithJSONObject:[NSArray arrayWithArray:arSyncFileInfoDicts] options:0 error:&error];
		return [[NSString alloc] initWithData:dataJson encoding:NSUTF8StringEncoding];
	}
	else
	{
		return nil;
	}
}

@end

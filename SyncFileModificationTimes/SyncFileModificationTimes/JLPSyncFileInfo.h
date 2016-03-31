//
//  JLPSyncFileInfo.h
//  SyncFileModificationTimes
//
//  Created by Joshua Pilkington on 2/23/16.
//  Copyright © 2016 Joshua Pilkington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JLPSyncFileInfo : NSObject

@property NSString* lastFileSource;
@property NSString* lastFileDest;
@property NSDate* timestamp;

-(id) initWithParams:(NSString*)lastFileSource lastFileDest:(NSString*)lastFileDest;
-(id) initWithDict:(NSDictionary*)dict;
-(id) initFromString:(NSString*)data;
-(NSDictionary*) getDict;
-(NSString*) save;
-(Boolean) isEmpty;

+(NSArray<JLPSyncFileInfo*>*) initArrayFromString:(NSString*)data;
+(NSString*) saveArray:(NSArray<JLPSyncFileInfo*>*)array;

@end

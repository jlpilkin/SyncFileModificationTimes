//
//  JLPSyncFileInfoDaemonSettings.h
//  SyncFileModificationTimes
//
//  Created by Joshua Pilkington on 4/16/16.
//  Copyright © 2016 Joshua Pilkington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JLPSyncFileInfoDaemonSettings : NSObject

@property NSString* directoryFirst;
@property NSString* directorySecond;

-(id) initWithParams:(NSString*)directoryFirst lastFileDest:(NSString*)directorySecond;
-(id) initWithDict:(NSDictionary*)dict;
-(id) initFromString:(NSString*)data;
-(NSDictionary*) getDict;
-(NSString*) save;
-(Boolean) isEmpty;

@end

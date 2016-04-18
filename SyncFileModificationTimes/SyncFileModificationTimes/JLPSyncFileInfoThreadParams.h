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

@property NSString* directoryFiles;

-(id) initWithParams:(NSString*)directoryFiles;

@end

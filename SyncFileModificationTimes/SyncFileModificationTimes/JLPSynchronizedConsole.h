//
//  JLPSynchronizedConsole.h
//  SyncFileModificationTimes
//
//  Created by Joshua Pilkington on 4/18/16.
//  Copyright © 2016 Joshua Pilkington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JLPSynchronizedConsole : NSObject

+(void) printString:(const char*)string;

@end

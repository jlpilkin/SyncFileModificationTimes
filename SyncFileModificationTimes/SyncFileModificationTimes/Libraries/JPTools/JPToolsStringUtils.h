//
//  JLPStringUtils.h
//  iSunCalc
//
//  Created by Joshua Pilkington on 12/20/14.
//  Copyright (c) 2014 Joshua Pilkington. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @discussion Provides various methods for dealing with strings
 */
@interface JPToolsStringUtils : NSObject

+(Boolean) isNilOrWhitespace:(NSString*)string;
+(NSString*) trim:(NSString*)stringOther;
+(NSString*) trimToUpper:(NSString*)stringOther;
+(Boolean) compareStrings:(NSString*)stringFirst stringSecond:(NSString*)stringSecond;
+(Boolean) compareStringsTrimToUpper:(NSString*)stringFirst stringSecond:(NSString*)stringSecond;
+(NSString*) keepOnlyAlphaNumeric:(NSString*)stringOther;
+(NSString*) boolToString:(bool)bValue;
+(NSString*) doubleToString:(double)fValue;
+(NSUInteger) getStringHash:(NSString*)string;
+(Boolean) stringMatchesRegex:(NSString*)string regex:(NSString*)regex;
+(Boolean) startsWith:(NSString*)string stringFind:(NSString*)stringFind;
+(NSString*) removeStart:(NSString*)string stringRemove:(NSString*)stringRemove;

@end

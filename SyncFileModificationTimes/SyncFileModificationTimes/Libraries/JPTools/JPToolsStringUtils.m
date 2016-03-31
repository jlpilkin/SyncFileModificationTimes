//
//  JLPStringUtils.m
//  iSunCalc
//
//  Created by Joshua Pilkington on 12/20/14.
//  Copyright (c) 2014 Joshua Pilkington. All rights reserved.
//

#import "JPToolsStringUtils.h"

@implementation JPToolsStringUtils

/**
 * @discussion Determines if the specified string is nil or all whitespace
 * @param string String to check
 * @return True if nil or all whitespace
 */
+(Boolean) isNilOrWhitespace:(NSString*)string
{
	return (
		string == nil ||
		[JPToolsStringUtils trim:string].length <= 0
	);
}

/**
 * @discussion Trims the specified string of all whitespace on both ends
 * @param stringOther String to trim
 * @return Trimmed string
 */
+(NSString*) trim:(NSString*)stringOther;
{
	if( stringOther != nil )
	{
		return [stringOther stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	}
	else
	{
		return nil;
	}
}

/**
 * @discussion Trims the specified string of all whitespace on both ends and
 *             converts the string to all uppercase characters
 * @param stringOther String to trim and convert to all uppercase
 * @return Trimmed and converted string
 */
+(NSString*) trimToUpper:(NSString*)stringOther
{
	if( stringOther != nil )
	{
		return [[stringOther stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
	}
	else
	{
		return nil;
	}
}

/**
 * @discussion Determines if the two specified strings are equal, case and end-whitespace sensitive
 * @param stringFirst First string to compare
 * @param stringSecond Second string to compare
 * @return True if both strings are equal
 */
+(Boolean) compareStrings:(NSString*)stringFirst stringSecond:(NSString*)stringSecond
{
	return (
		( stringFirst == nil && stringSecond == nil ) ||
		(
			( stringFirst != nil && stringSecond != nil ) &&
			[stringFirst isEqualToString:stringSecond]
		)
	);
}

/**
 * @discussion Determines if the two specified strings are equal, case and end-whitespace insensitive
 * @param stringFirst First string to compare
 * @param stringSecond Second string to compare
 * @return True if both strings are equal after performing the trimToUpper operation on each
 */
+(Boolean) compareStringsTrimToUpper:(NSString*)stringFirst stringSecond:(NSString*)stringSecond
{
	return (
		( stringFirst == nil && stringSecond == nil ) ||
		(
			( stringFirst != nil && stringSecond != nil ) &&
			[[JPToolsStringUtils trimToUpper:stringFirst] isEqualToString:[JPToolsStringUtils trimToUpper:stringSecond]]
		)
	);
}

/**
 * @discussion Strips the specified string of all non-alphanumeric characters
 * @param stringOther String to strip
 * @return Stripped string
 */
+(NSString*) keepOnlyAlphaNumeric:(NSString*)stringOther
{
	if( stringOther != nil )
	{
		NSCharacterSet *charactersToRemove = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
		return [[stringOther componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
	}
	else
	{
		return nil;
	}
}

/**
 * @discussion Converts a boolean to a string
 * @param bValue Boolean value
 * @return Boolean as a string
 */
+(NSString*) boolToString:(bool)bValue
{
	if( bValue )
	{
		return @"TRUE";
	}
	else
	{
		return @"FALSE";
	}
}

/**
 * @discussion Converts a double to a string
 * @param fValue Double value
 * @return Double as a string
 */
+(NSString*) doubleToString:(double)fValue
{
	return [NSString stringWithFormat:@"%f", fValue];
}

/**
 * @discussion Gets the hash of the specified string
 * @param string String to get the hash of, or nil
 * @return String hash, or 0 if the string is nil
 */
+(NSUInteger) getStringHash:(NSString*)string
{
	if( string == nil )
	{
		return 0U;
	}
	
	return [string hash];
}

/**
 * @discussion Determines if the specified string matches the specified regular expression
 * @param string String to match against
 * @param regex Regular expression used for matching
 * @return True if the string matches the regular expression
 */
+(Boolean) stringMatchesRegex:(NSString*)string regex:(NSString*)regex
{
	if(
		![JPToolsStringUtils isNilOrWhitespace:string] &&
		![JPToolsStringUtils isNilOrWhitespace:regex]
	)
	{
		NSRange range = [string rangeOfString:regex options:NSRegularExpressionSearch];
		return range.location != NSNotFound;
	}
	else
	{
		return false;
	}
}

/**
 * @discussion Determines if the specified string starts with another specified string
 * @param string String to find the other specified string in
 * @param stringFind String to find in the other string
 * @return True if the string starts with the other specified string
 */
+(Boolean) startsWith:(NSString*)string stringFind:(NSString*)stringFind
{
	// Deal with trivial cases
	if( string == nil )
		return false;
	if( stringFind == nil )
		return false;
	
	// Find the range of the string
	NSRange rngFind = [string rangeOfString:stringFind];
	
	// Return whether the range is at the beginning of the string
	return rngFind.location != NSNotFound && rngFind.location == 0U;
}

/**
 * @discussion Removes the other specified string from the start of the specified string
 * @param string String to remove the other string from
 * @param stringRemove Other string to remove from the specified string
 * @return String with the other string removed, if the string starts with the other string
 */
+(NSString*) removeStart:(NSString*)string stringRemove:(NSString*)stringRemove
{
	// Deal with trivial cases
	if( string == nil )
		return nil;
	if( stringRemove == nil )
		return string;

	// Find the range of the string
	NSRange rngFind = [string rangeOfString:stringRemove];
	
	// Return a string with the found string removed if the strings starts with the other string
	// Otherwise, return the original string
	if( rngFind.location != NSNotFound && rngFind.location == 0U )
	{
		return [string stringByReplacingCharactersInRange:rngFind withString:@""];
	}
	else
	{
		return string;
	}
}

@end

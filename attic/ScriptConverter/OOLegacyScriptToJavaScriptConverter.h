//
//  OOLegacyScriptToJavaScriptConverter.h
//  ScriptConverter
//
//  Created by Jens Ayton on 2007-11-24.
//  Copyright 2007 Jens Ayton. All rights reserved.
//

#import "OOCocoa.h"
#import "OOProblemReportManager.h"


extern NSString * const kOOScriptMetadataKeyName;
extern NSString * const kOOScriptMetadataKeyAuthor;
extern NSString * const kOOScriptMetadataKeyCopyright;
extern NSString * const kOOScriptMetadataKeyDescription;
extern NSString * const kOOScriptMetadataKeyVersion;
extern NSString * const kOOScriptMetadataKeyLicense;


@interface OOLegacyScriptToJavaScriptConverter: NSObject
{
	NSDictionary				*_metadata;
	id <OOProblemReportManager>	_problemReporter;
	unsigned					_indent;
	NSMutableString				*_result;
	NSMutableDictionary			*_legalizedVariableNames;
	NSMutableSet				*_usedLocalVariableNames;
	OOUInteger					_lastVariableUniqueTag;
	NSMutableDictionary			*_initializers;
	NSMutableDictionary			*_helperFunctions;
	OOUInteger					_initializerLocation;
	BOOL						_EOL;
	BOOL						_secondaryIndent;
	BOOL						_validConversion;
}

+ (NSString *) convertScript:(NSArray *)scriptActions
					metadata:(NSDictionary *)metadata
			 problemReporter:(id <OOProblemReportManager>)problemReporter;

+ (NSDictionary *) convertMultipleScripts:(NSDictionary *)scripts
								 metadata:(NSDictionary *)metadata
						  problemReporter:(id <OOProblemReportManager>)problemReporter;

@end


@interface NSString (OOScriptConverterUtilities)

// Add escape codes for string so that it's a valid JavaScript literal (if you put "" or '' around it).
- (NSString *)escapedForJavaScriptLiteral;

// Remove occurances of */
- (NSString *)escapedForJavaScriptBlockComment;

@end


BOOL OOScriptConverterIsNumberLiteral(NSString *string);

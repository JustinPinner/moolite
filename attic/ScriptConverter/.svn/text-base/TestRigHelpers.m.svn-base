//
//  TestRigHelpers.m
//  ScriptConverter
//
//  Created by Jens Ayton on 2009-03-13.
//  Copyright 2009 Jens Ayton. All rights reserved.
//

#import "TestRigHelpers.h"


@implementation NSString (TestRigHelpers)

- (NSString *)escapedForJavaScriptLiteral
{
	NSMutableString			*result = nil;
	unsigned				i, length;
	unichar					c;
	NSAutoreleasePool		*pool = nil;
	
	length = [self length];
	result = [NSMutableString stringWithCapacity:[self length]];
	
	// Not hugely efficient.
	pool = [[NSAutoreleasePool alloc] init];
	for (i = 0; i != length; ++i)
	{
		c = [self characterAtIndex:i];
		switch (c)
		{
			case '\\':
				[result appendString:@"\\\\"];
				break;
				
			case '\b':
				[result appendString:@"\\b"];
				break;
				
			case '\f':
				[result appendString:@"\\f"];
				break;
				
			case '\n':
				[result appendString:@"\\n"];
				break;
				
			case '\r':
				[result appendString:@"\\r"];
				break;
				
			case '\t':
				[result appendString:@"\\t"];
				break;
				
			case '\v':
				[result appendString:@"\\v"];
				break;
				
			case '\'':
				[result appendString:@"\\\'"];
				break;
				
			case '\"':
				[result appendString:@"\\\""];
				break;
				
			default:
				[result appendString:[NSString stringWithCharacters:&c length:1]];
		}
	}
	[pool release];
	return result;
}


- (BOOL) isJavaScriptIdentifier
{
	static NSCharacterSet		*notIdentifierCharSet = nil;
	unichar						first;
	
	if (notIdentifierCharSet == nil)
	{
		notIdentifierCharSet = [[NSCharacterSet characterSetWithCharactersInString:@"_0123456789QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm$"] invertedSet];
		[notIdentifierCharSet retain];
	}
	
	if ([self length] == 0)  return NO;
	
	// Identifiers may not start with a digit.
	first = [self characterAtIndex:0];
	if ('0' <= first && first <= '9')  return NO;
	
	// Look for any non-identifier char.
	if ([self rangeOfCharacterFromSet:notIdentifierCharSet].location != NSNotFound)  return NO;
	
	return YES;
}


static NSSet *KeywordList(void)
{
	NSString *kKeywords[] =
	{
		@"break",
		@"continue",
		@"do",
		@"for",
		@"import",
		@"new",
		@"this",
		@"void",
		@"case",
		@"default",
		@"else",
		@"function",
		@"in",
		@"return",
		@"typeof",
		@"while",
		@"comment",
		@"delete",
		@"export",
		@"if",
		@"label",
		@"switch",
		@"var",
		@"with",
		@"abstract",
		@"implements",
		@"protected",
		@"boolean",
		@"instanceof",
		@"public",
		@"byte",
		@"int",
		@"short",
		@"char",
		@"interface",
		@"static",
		@"double",
		@"long",
		@"synchronized",
		@"false",
		@"native",
		@"throws",
		@"final",
		@"null",
		@"transient",
		@"float",
		@"package",
		@"true",
		@"goto",
		@"private",
		@"catch",
		@"enum",
		@"throw",
		@"class",
		@"extends",
		@"try",
		@"const",
		@"finally",
		@"debugger",
		@"super"
	};
	
	return [NSSet setWithObjects:kKeywords count:sizeof kKeywords / sizeof *kKeywords];
}


- (BOOL) isJavaScriptKeyword
{
	static NSSet				*keywords = nil;
	
	if (keywords == nil)  keywords = [KeywordList() retain];
	
	return [keywords containsObject:self];
}

@end

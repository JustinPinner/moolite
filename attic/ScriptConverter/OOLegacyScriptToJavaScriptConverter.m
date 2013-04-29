//
//  OOLegacyScriptToJavaScriptConverter.m
//  ScriptConverter
//
//  Created by Jens Ayton on 2007-11-24.
//  Copyright 2007 Jens Ayton. All rights reserved.
//

#import "OOLegacyScriptToJavaScriptConverterCore.h"
#import "OOCollectionExtractors.h"
#import "OOIsNumberLiteral.h"
#import "OOJSExprNodeHelpers.h"


NSString * const kOOScriptMetadataKeyName			= @"name";
NSString * const kOOScriptMetadataKeyAuthor			= @"author";
NSString * const kOOScriptMetadataKeyCopyright		= @"copyright";
NSString * const kOOScriptMetadataKeyDescription	= @"description";
NSString * const kOOScriptMetadataKeyVersion		= @"version";
NSString * const kOOScriptMetadataKeyLicense		= @"license";

NSString * const kOOScriptConverterVersion			= @"0.1";


static NSString *IndentPrefixForLevel(unsigned level);
static NSCharacterSet *NewlineCharSet(void);
static NSCharacterSet *IdentifierCharSet(void);
static NSString *LegalizeIdentifier(NSString *identifier, BOOL willBePrefixed);


static BOOL StringContainsEscapes(NSString *string);
static BOOL IsIdentifier(NSString *string);


@interface NSObject (NSCharacterSetLeopard)

+ (id) newlineCharacterSet;

@end


@implementation OOLegacyScriptToJavaScriptConverter

+ (NSString *) convertScript:(NSArray *)scriptActions
					metadata:(NSDictionary *)metadata
			 problemReporter:(id <OOProblemReportManager>)problemReporter
{
	OOLegacyScriptToJavaScriptConverter	*converter = nil;
	NSAutoreleasePool					*pool = nil;
	NSString							*result = nil;
	
	pool = [[NSAutoreleasePool alloc] init];
	converter = [[[self alloc] init] autorelease];
	
	NS_DURING
		[converter setProblemReporter:problemReporter];
		[converter setMetadata:metadata];
		
		result = [converter convertScript:scriptActions];
	NS_HANDLER
		[problemReporter addIssueWithSeverity:kOOProblemSeverityBug
										  key:@"exception"
								  description:[NSString stringWithFormat:@"Script conversion could not be completed, because an exception of type %@ occurred (%@).",
																		 [localException name], [localException reason]]];
	NS_ENDHANDLER
	
	[result retain];
	[pool release];
	return [result autorelease];
}


+ (NSDictionary *) convertMultipleScripts:(NSDictionary *)scripts
								 metadata:(NSDictionary *)metadata
						  problemReporter:(id <OOProblemReportManager>)problemReporter
{
	NSDictionary			*metadataFromFile = nil;
	NSMutableDictionary		*mutableDict = nil;
	NSString				*name = nil;
	NSArray					*legacyScript = nil;
	NSString				*jsScript = nil;
	NSEnumerator			*scriptEnum = nil;
	NSMutableDictionary		*result = nil;
	
	metadataFromFile = [scripts objectForKey:@"!metadata!"];
	if (metadataFromFile != nil)
	{
		// Merge metadata if needed
		if (metadata != nil)
		{
			mutableDict = [metadataFromFile mutableCopy];
			[mutableDict addEntriesFromDictionary:metadata];
			metadata = [mutableDict autorelease];
		}
		else
		{
			metadata = metadataFromFile;
		}
		
		// Remove !metadata! from script dictionary
		mutableDict = [scripts mutableCopy];
		[mutableDict removeObjectForKey:@"!metadata!"];
		scripts = [mutableDict autorelease];
	}
	
	// Convert each script.
	result = [NSMutableDictionary dictionaryWithCapacity:[scripts count]];
	for (scriptEnum = [scripts keyEnumerator]; (name = [scriptEnum nextObject]); )
	{
		legacyScript = [scripts arrayForKey:name];
		if (legacyScript != nil)
		{
			mutableDict = (metadata != nil) ? [metadata mutableCopy] : [NSMutableDictionary dictionary];
			[mutableDict setObject:name forKey:kOOScriptMetadataKeyName];
			jsScript = [self convertScript:legacyScript
								  metadata:[mutableDict autorelease]
						   problemReporter:problemReporter];
			
			if (jsScript == nil)  break;
			[result setObject:jsScript forKey:name];
		}
	}
	
	return result;
}


- (id) init
{
	self = [super init];
	if (self != nil)
	{
		_result = [[NSMutableString alloc] init];
		_EOL = YES;
	}
	return self;
}


- (void) dealloc
{
	[_metadata release];
	[_problemReporter release];
	[_result release];
	[_legalizedVariableNames release];
	[_usedLocalVariableNames release];
	[_initializers release];
	[_helperFunctions release];
	
	[super dealloc];
}

@end


@implementation OOLegacyScriptToJavaScriptConverter (Private)

- (void) setMetadata:(NSDictionary *)metadata
{
	[_metadata autorelease];
	_metadata = [metadata retain];
}


- (void) setProblemReporter:(id <OOProblemReportManager>)problemReporter
{
	[_problemReporter autorelease];
	_problemReporter = [problemReporter retain];
}


- (NSString *) convertScript:(NSArray *)actions
{
	[self writeHeader];
	_initializerLocation = [_result length];
	
	_validConversion = YES;
	
	if ([actions count] > 0)
	{
		NSString *name = [_metadata objectForKey:kOOScriptMetadataKeyName];
		if (name != nil)  name = [@"tickle_" stringByAppendingString:LegalizeIdentifier(name, YES)];
		else  name = @"tickle";
		[self appendWithFormat:@"this.tickle = function %@ ()\n{\n", name];
		[self indent];
		[self convertActions:actions];
		[self outdent];
		[self append:@"}\n"];
	}
	
	if (!_EOL)  [_result appendString:@"\n"];
	
	// Insert initializers
	NSString *prefixString = @"";
	if (_initializers != nil)
	{
		NSArray *initializers = [_initializers allValues];
		initializers = [initializers sortedArrayUsingSelector:@selector(compare:)];
		prefixString = [prefixString stringByAppendingString:[initializers componentsJoinedByString:@"\n"]];
		prefixString = [prefixString stringByAppendingString:@"\n\n"];
	}
	if (_helperFunctions != nil)
	{
		NSArray *helpers = [_helperFunctions allValues];
		helpers = [helpers sortedArrayUsingSelector:@selector(compare:)];
		prefixString = [prefixString stringByAppendingString:[helpers componentsJoinedByString:@"\n\n"]];
		prefixString = [prefixString stringByAppendingString:@"\n\n"];
	}
	if ([prefixString length] > 0)
	{
		prefixString = [@"\n" stringByAppendingString:prefixString];
		[_result insertString:prefixString atIndex:_initializerLocation];
	}
	
	NSString *result = nil;
	// FIXME: how to report invalid conversions?
	//if (_validConversion)
	{
		result = [[_result copy] autorelease];
	}
	[_result release];
	_result = nil;
	return result;
}


- (void) writeHeader
{
	NSString				*name = nil;
	NSString				*author = nil;
	NSString				*copyright = nil;
	NSString				*description = nil;
	NSString				*version = nil;
	NSString				*license = nil;
	
	name = [_metadata stringForKey:kOOScriptMetadataKeyName];
	if (name == nil)  name = @"unnamed";
	author = [_metadata stringForKey:kOOScriptMetadataKeyAuthor];
	copyright = [_metadata stringForKey:kOOScriptMetadataKeyCopyright];
	description = [_metadata stringForKey:kOOScriptMetadataKeyDescription];
	version = [_metadata stringForKey:kOOScriptMetadataKeyVersion];
	license = [_metadata stringForKey:kOOScriptMetadataKeyLicense];
	
	// Write block comment at top
	if (version == nil)  [self appendWithFormat:@"/*\n\n%@.js\n", [name escapedForJavaScriptBlockComment]];
	else  [self appendWithFormat:@"/*\n\n%@.js version %@\n", [name escapedForJavaScriptBlockComment], [version escapedForJavaScriptBlockComment]];
	if (author != nil)  [self appendWithFormat:@"By %@\n", [author escapedForJavaScriptBlockComment]];
	if (copyright != nil)  [self appendWithFormat:@"@\n", [copyright escapedForJavaScriptBlockComment]];
	[self appendWithFormat:@"\nConverted by script converter %@\n", kOOScriptConverterVersion];
	if (description != nil) [self appendWithFormat:@"\n%@\n", [description escapedForJavaScriptBlockComment]];
	if (license != nil) [self appendWithFormat:@"\n\n%@\n", [license escapedForJavaScriptBlockComment]];
	[self append:@"\n*/\n\n\n"];
	
	// Write attribute definitions
	[self appendWithFormat:@"this.name =           \"%@\";\n", [name escapedForJavaScriptLiteral]];
	if (author != nil)  [self appendWithFormat:@"this.author         = \"%@\";\n", [author escapedForJavaScriptLiteral]];
	if (copyright != nil)  [self appendWithFormat:@"this.copyright      = \"%@\";\n", [copyright escapedForJavaScriptLiteral]];
	if (description != nil)  [self appendWithFormat:@"this.description =    \"%@\";\n", [description escapedForJavaScriptLiteral]];
	if (version != nil)  [self appendWithFormat:@"this.version =        \"%@\";\n", [version escapedForJavaScriptLiteral]];
	[self append:@"\n\n"];
}


- (void) append:(NSString *)string
{
	NSArray					*lines = nil;
	NSString				*indentString = nil;
	static NSCharacterSet	*newlines = nil;
	unsigned				i, count;
	BOOL					secondaryIndent;
	
	if (newlines == nil)  newlines = [NewlineCharSet() retain];
	
	// Needs to be reset before early exit
	secondaryIndent = _secondaryIndent;
	_secondaryIndent = NO;
	
	// Split into lines
	lines = [string componentsSeparatedByCharactersInSet:newlines];
	count = [lines count];
	if (count == 0)  return;
	
	indentString = [@"\n" stringByAppendingString:IndentPrefixForLevel(_indent)];
	
	// Don't indent first line if previous line was unterminated
	if (_EOL)  [_result appendString:indentString];
	[_result appendString:[lines objectAtIndex:0]];
	
	// Work out whether the last line is terminated this time
	_EOL = [[lines objectAtIndex:count - 1] length] == 0;
	if (_EOL)  count--;	// Don't print empty line (unless it was only line)
	
	if (count > 1)
	{
		if (secondaryIndent)  indentString = [@"\n" stringByAppendingString:IndentPrefixForLevel(_indent)];
		
		for (i = 1; i != count; ++i)
		{
			[_result appendString:indentString];
			[_result appendString:[lines objectAtIndex:i]];
		}
	}
}


- (void) appendWithFormat:(NSString *)format, ...
{
	va_list					args;
	
	va_start(args, format);
	[self appendWithFormat:format arguments:args];
	va_end(args);
}


- (void) appendWithFormat:(NSString *)format arguments:(va_list)args
{
	NSString				*message = nil;
	
	message = [[NSString alloc] initWithFormat:format arguments:args];
	[self append:message];
	[message release];
}


- (void) indent
{
	++_indent;
}


- (void) outdent
{
	if (_indent != 0)
	{
		--_indent;
		OOUInteger length = [_result length];
		if (length != 0 && [_result characterAtIndex:length - 1] == '\t')
		{
			[_result deleteCharactersInRange:NSMakeRange(length - 1, 1)];
		}
	}
}


- (NSString *) legalizedVariableName:(NSString *)rawName
{
	NSString				*result = nil;
	NSString				*baseName = nil;
	
	if (rawName == nil)  return nil;
	
	result = [_legalizedVariableNames objectForKey:rawName];
	if (result != nil)  return result;
	
	if ([rawName hasPrefix:@"mission_"])
	{
		NSString *name = [rawName substringFromIndex:8];
		if (IsIdentifier(name))
		{
			result = [@"missionVariables." stringByAppendingString:name];
		}
		else
		{
			result = [NSString stringWithFormat:@"missionVariables[\"%@\"]", [name escapedForJavaScriptLiteral]];
		}
	}
	else if ([rawName hasPrefix:@"local_"])
	{
		baseName = [@"this.local_" stringByAppendingString:LegalizeIdentifier([rawName substringFromIndex:6], NO)];
		result = baseName;
		while ([_usedLocalVariableNames containsObject:result])
		{
			result = [NSString stringWithFormat:@"%@_U%u", baseName, ++_lastVariableUniqueTag];
		}
		
		if (_usedLocalVariableNames == nil)  _usedLocalVariableNames = [[NSMutableSet alloc] init];
		[_usedLocalVariableNames addObject:result];
		[self setInitializer:[NSString stringWithFormat:@"%@ = null;", result] forKey:rawName];
	}
	else
	{
		[self addStopIssueWithKey:@"bad-variable-name"
						   format:@"Expected mission_variable or local_variable, got \"%@\".", rawName];
		return nil;
	}
	
	if (_legalizedVariableNames == nil)  _legalizedVariableNames = [[NSMutableDictionary alloc] init];
	[_legalizedVariableNames setObject:result forKey:rawName];
	return result;
}


- (OOJSExprNode *) convertVariableAccess:(NSString *)variableName
{
	NSString				*name = nil;
	
	if ([variableName hasPrefix:@"mission_"])
	{
		name = [variableName substringFromIndex:8];
		return EX_PROP(@"missionVariables", name);
	}
	else if ([variableName hasPrefix:@"local_"])
	{
		return EX_THIS_PROP(variableName);
	}
	else
	{
		[self addStopIssueWithKey:@"bad-variable-name"
						   format:@"Expected mission_variable or local_variable, got \"%@\".", variableName];
		return EX_ERROR(@"bad variable name");
	}
}


- (NSString *) expandStringWithLocalVariables:(NSString *)string
{
	/*	Strings with [local_foo] substitutions are handled by splitting
		at the first [local_foo], inserting the relevant local, then
		recursively calling expandString: for the prefix and suffix.
		
		Example:
			"foo [local_a] bar %R [local_b] baz" is split as:
				prefix: "foo "
				localName: local_a
				suffix: " bar %R [local_b] baz"
		
		Recursive processing should result in the JS expression:
		"foo " + this.local_a + expandDescription(" bar %R ") + this.local_b + " baz"
	*/
	
	NSRange					varStart, varEnd;
	OOUInteger				length, endOfTag;
	NSString				*prefix = nil, *suffix = nil;
	NSString				*varName = nil;
	NSString				*result = nil;
	
	length = [string length];
	
	varStart = [string rangeOfString:@"[local_"];
	assert(varStart.location != NSNotFound);
	
	endOfTag = varStart.location + varStart.length;
	varEnd = [string rangeOfString:@"]" options:0 range:NSMakeRange(endOfTag, length - endOfTag)];
	if (varEnd.location == NSNotFound)
	{
		/*	[local_ without closing ], not a substitution. To avoid infinite
			recursion, we split this into two parts after local and before _.
		*/
		
		prefix = [string substringToIndex:endOfTag - 1];
		suffix = [string substringFromIndex:endOfTag - 1];
		
		return [NSString stringWithFormat:@"%@ + %@", [self expandString:prefix], [self expandString:suffix]];
	}
	
	prefix = [string substringToIndex:varStart.location];
	suffix = [string substringFromIndex:varEnd.location + varEnd.length];
	varName = [string substringWithRange:NSMakeRange(varStart.location + 1, varEnd.location - varStart.location - 1)];
	
	result = [self legalizedVariableName:varName];
	
	if ([prefix length] > 0)
	{
		prefix = [self expandString:prefix];
		result = [NSString stringWithFormat:@"%@ + %@", prefix, result];
	}
	
	if ([suffix length] > 0)
	{
		suffix = [self expandString:suffix];
		result = [NSString stringWithFormat:@"%@ + %@", suffix, result];
	}
	
	return result;
}


- (NSString *) expandStringWithMissionVariables:(NSString *)string
{
	//	Same as above, but for mission variables.
	
	NSRange					varStart, varEnd;
	OOUInteger				length, endOfTag;
	NSString				*prefix = nil, *suffix = nil;
	NSString				*varName = nil;
	NSString				*result = nil;
	
	length = [string length];
	
	varStart = [string rangeOfString:@"[mission_"];
	assert(varStart.location != NSNotFound);
	
	endOfTag = varStart.location + varStart.length;
	varEnd = [string rangeOfString:@"]" options:0 range:NSMakeRange(endOfTag, length - endOfTag)];
	if (varEnd.location == NSNotFound)
	{
		/*	[mission_ without closing ], not a substitution. To avoid infinite
			recursion, we split this into two parts after mission and before _.
		*/
		
		prefix = [string substringToIndex:endOfTag - 1];
		suffix = [string substringFromIndex:endOfTag - 1];
		
		return [NSString stringWithFormat:@"%@ + %@", [self expandString:prefix], [self expandString:suffix]];
	}
	
	prefix = [string substringToIndex:varStart.location];
	suffix = [string substringFromIndex:varEnd.location + varEnd.length];
	varName = [string substringWithRange:NSMakeRange(varStart.location + 1, varEnd.location - varStart.location - 1)];
	
	result = [self legalizedVariableName:varName];
	
	if ([prefix length] > 0)
	{
		prefix = [self expandString:prefix];
		result = [NSString stringWithFormat:@"%@ + %@", prefix, result];
	}
	
	if ([suffix length] > 0)
	{
		suffix = [self expandString:suffix];
		result = [NSString stringWithFormat:@"%@ + %@", suffix, result];
	}
	
	return result;
}


- (NSString *) expandString:(NSString *)string
{
	if (!StringContainsEscapes(string))
	{
		// Simple case: just a literal string.
		return [NSString stringWithFormat:@"\"%@\"", [string escapedForJavaScriptLiteral]];
	}
	
	/*	Kludge: handle some common cases to make output code look less stupid.
		A better way might be to expand all brackets instead. A problem there
		is that in principle, descriptions.plist entries can override method
		call substitutions (but not local or mission variables), although it
		would be reasonable to consider that a bug.
	*/
	static NSDictionary *specialCases = nil;
	if (specialCases == nil)
	{
		specialCases = [[@"{"
			"\"[credits_number]\" = \"player.credits\";"
			"\"[score_number]\" = \"player.score\";"
			"\"-[credits_number]\" = \"-player.credits\";"
			"\"[legalStatus_number]\" = \"player.bounty\";"
			"\"[commanderLegalStatus_number]\" = \"player.bounty\";"
			"\"[commander_legal_status]\" = \"player.bounty\";"
			"\"[d100_number]\" = \"system.psuedoRandom100\";"
			"\"[d256_number]\" = \"system.psuedoRandom256\";"
		"}" propertyList] retain];
	}
	NSString *special = [specialCases objectForKey:string];
	if (special != nil)  return special;
	
	if ([string rangeOfString:@"[local_"].location != NSNotFound)
	{
		return [self expandStringWithLocalVariables:string];
	}
	else if ([string rangeOfString:@"[mission_"].location != NSNotFound)
	{
		return [self expandStringWithMissionVariables:string];
	}
	
	return [NSString stringWithFormat:@"expandDescription(\"%@\")", [string escapedForJavaScriptLiteral]];
}


- (NSString *) expandStringOrNumber:(NSString *)string;
{
	if (OOScriptConverterIsNumberLiteral(string))  return string;
	else  return [self expandString:string];
}


- (NSString *) expandIntegerExpression:(NSString *)string
{
	if (OOScriptConverterIsNumberLiteral(string))  return string;
	
	[self setParseIntOrZeroHelper];
	return [NSString stringWithFormat:@"this.parseIntOrZero(%@)", [self expandString:string]];
}


- (NSString *) expandFloatExpression:(NSString *)string
{
	if (OOScriptConverterIsNumberLiteral(string))  return string;
	
	[self setParseFloatOrZeroHelper];
	return [NSString stringWithFormat:@"this.parseFloatOrZero(%@)", [self expandString:string]];
}


- (NSString *) expandPropertyReference:(NSString *)string
{
	string = [self expandString:string];
	NSString *substr = [string substringWithRange:NSMakeRange(1, [string length] - 2)];	// unquoted string
	if (IsIdentifier(substr))  return [@"." stringByAppendingString:substr];
	else  return [NSString stringWithFormat:@"[%@]", string];
}


- (void) addRange:(NSRange)range fromString:(NSString *)string toResultList:(NSMutableArray *)results
{
	NSString			*subStr = nil;
	OOJSExprNode		*node = nil;
	
	subStr = [string substringWithRange:range];
	node = EX_STR(subStr);
	
	if (StringContainsEscapes(subStr))
	{
		node = EX_CALL(@"expandDescription", node);
	}
	
	[results addObject:node];
}


- (OOJSExprNode *) expandRightHandSide:(NSString *)rhs
{
	if (OOScriptConverterIsNumberLiteral(rhs))  return OOJSExprNumberFromLiteral(rhs);
	
	if (!StringContainsEscapes(rhs))  return EX_STR(rhs);
	
	OOUInteger			length = [rhs length];
	NSRange				remaining = {0, length};
	OOUInteger			start, end;
	NSRange				subrange;
	NSString			*token = nil;
	OOJSExprNode		*expansion = nil;
	NSMutableArray		*components = nil;
	OOJSExprNode		*result = nil;
	OOUInteger			i, count;
	static NSDictionary *specialCases = nil;
	
	if (specialCases == nil)
	{
	/*	Kludge: handle some common cases to make output code look less stupid.
		A better way might be to expand all brackets instead. A problem there
		is that in principle, descriptions.plist entries can override method
		call substitutions (but not local or mission variables), although it
		would be reasonable to consider that a bug.
	*/
		specialCases = [[NSDictionary alloc] initWithObjectsAndKeys:
						EX_PROP(@"player", @"credits"), @"credits_number",
						EX_PROP(@"player", @"score"), @"score_number",
						EX_PROP(@"player", @"bounty"), @"legalStatus_number",
						EX_PROP(@"player", @"bounty"), @"commanderLegalStatus_number",
						EX_PROP(@"player", @"bounty"), @"commander_legal_status",
						EX_PROP(@"system", @"psuedoRandom100"), @"d100_number",
						EX_PROP(@"system", @"psuedoRandom256"), @"d256_number",
						nil];
	}
		
	components = [[NSMutableArray alloc] init];
	
	for (;;)
	{
		start = [rhs rangeOfString:@"[" options:NSLiteralSearch range:remaining].location;
		if (start == NSNotFound)  break;
		
		end = [rhs rangeOfString:@"]" options:NSLiteralSearch range:NSMakeRange(start + 1, length - start  - 1)].location + 1;
		if (end == NSNotFound)  break;
		
		token = [rhs substringWithRange:NSMakeRange(start + 1, end - start - 2)];
		expansion = nil;
		
		if ([token hasPrefix:@"local_"] || [token hasPrefix:@"mission_"])
		{
			expansion = [self convertVariableAccess:token];
		}
		else
		{
			expansion = [specialCases objectForKey:token];
		}
		
		if (expansion != nil)
		{
			// Get segment to left
			subrange = NSMakeRange(remaining.location, start - remaining.location);
			if (subrange.length > 0)
			{
				[self addRange:subrange fromString:rhs toResultList:components];
			}
			
			// Add expansion
			[components addObject:expansion];
		}
		// Else skip and expand at runtime.
		
		remaining.location = end;
		remaining.length = length - end;
	}
	
	if (remaining.length != 0)
	{
		[self addRange:remaining fromString:rhs toResultList:components];
	}
	
	count = [components count];
	if (count == 0)
	{
		result = EX_STR(@"");
	}
	else
	{
		// Join components with + operator.
		result = [components objectAtIndex:0];
		
		for (i = 1; i < count; i++)
		{
			result = EX_ADD(result, [components objectAtIndex:1]);
		}
	}
	
	[components release];
	return result;
}


- (void) setInitializer:(NSString *)initializerStatement forKey:(NSString *)key
{
	if (initializerStatement == nil || key == nil)  return;
	
	if (_initializers == nil)  _initializers = [[NSMutableDictionary alloc] init];
	
	[_initializers setObject:initializerStatement forKey:key];
}


- (void) setHelperFunction:(NSString *)function forKey:(NSString *)key
{
	if (function == nil || key == nil)  return;
	
	if (_helperFunctions == nil)  _helperFunctions = [[NSMutableDictionary alloc] init];
	
	[_helperFunctions setObject:[NSString stringWithFormat:@"this.%@ = %@", key, function] forKey:key];
}


- (void) setParseFloatOrZeroHelper
{
	[self setHelperFunction:
			@"function (string)\n{\n"
			"\tlet value = parseFloat(string);\n"
			"\tif (isNaN(value))  return 0;\n"
			"\telse  return value;\n}"
		forKey:@"parseFloatOrZero"];
}


- (void) setParseIntOrZeroHelper
{
	[self setHelperFunction:
			@"function (string)\n{\n"
			"\tlet value = parseInt(string);\n"
			"\tif (isNaN(value))  return 0;\n"
			"\telse  return value;\n}"
		forKey:@"parseIntOrZero"];
}


- (void) addIssueWithSeverity:(OOProblemSeverity)severity key:(NSString *)key format:(NSString *)format args:(va_list)args
{
	NSString			*description = nil;
	
	description = [[[NSString alloc] initWithFormat:format arguments:args] autorelease];
	[_problemReporter addIssueWithSeverity:severity key:key description:description];
}


- (void) addNoteIssueWithKey:(NSString *)key format:(NSString *)format, ...
{
	va_list				args;
	
	va_start(args, format);
	[self addIssueWithSeverity:kOOProblemSeverityNote key:key format:format args:args];
	va_end(args);
}


- (void) addWarningIssueWithKey:(NSString *)key format:(NSString *)format, ...
{
	va_list				args;
	
	va_start(args, format);
	[self addIssueWithSeverity:kOOProblemSeverityWarning key:key format:format args:args];
	va_end(args);
}


- (void) addUnknownSelectorIssueWithKey:(NSString *)key format:(NSString *)format, ...
{
	va_list				args;
	
	_validConversion = NO;
	va_start(args, format);
	[self addIssueWithSeverity:kOOProblemSeverityUnknownSelector key:key format:format args:args];
	va_end(args);
}


- (void) addStopIssueWithKey:(NSString *)key format:(NSString *)format, ...
{
	va_list				args;
	
	_validConversion = NO;
	va_start(args, format);
	[self addIssueWithSeverity:kOOProblemSeverityStop key:key format:format args:args];
	va_end(args);
}


- (void) addBugIssueWithKey:(NSString *)key format:(NSString *)format, ...
{
	va_list				args;
	
	_validConversion = NO;
	va_start(args, format);
	[self addIssueWithSeverity:kOOProblemSeverityBug key:key format:format args:args];
	va_end(args);
}

@end


@implementation NSString (OOScriptConverterUtilities)


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


- (NSString *)escapedForJavaScriptBlockComment
{
	return [[self componentsSeparatedByString:@"*/"] componentsJoinedByString:@"* /"];
}

@end


static NSString *IndentPrefixForLevel(unsigned level)
{
	// 32
	const unichar tabs[] = { '\t', '\t', '\t', '\t', '\t', '\t', '\t', '\t', '\t', '\t', '\t', '\t', '\t', '\t', '\t', '\t', '\t', '\t', '\t', '\t', '\t', '\t', '\t', '\t', '\t', '\t', '\t', '\t', '\t', '\t', '\t', '\t' };
	const size_t max = sizeof tabs / sizeof tabs[0];
	
	if (level > max)  level = max;
	return [NSString stringWithCharacters:tabs length:level];
}


static NSCharacterSet *NewlineCharSet(void)
{
	// Unicode code points to treat as line breaks.
	// CRLF pairs are treated as two line breaks.
	// Line breaks inside strings are not special-cased.
	const unichar newlineSet[] =
		{
			0x000A,		// LF
			0x000C,		// FF
			0x000D,		// CR
			0x0085,		// NEL
			0x2028,		// LS
			0x2029		// PS
		};
	const size_t count = sizeof newlineSet / sizeof newlineSet[0];
	
	return [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithCharacters:newlineSet length:count]];
}


static NSCharacterSet *IdentifierCharSet(void)
{
	return [NSCharacterSet characterSetWithCharactersInString:@"_0123456789QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm$"];
}


static inline BOOL IsSpaceOrTab(int value)
{
	return value == ' ' || value == '\t';
}


BOOL OOScriptConverterIsNumberLiteral(NSString *string)
{
	return OOIsNumberLiteral(string, NO);
}


static BOOL StringContainsEscapes(NSString *string)
{
	if ([string rangeOfString:@"["].location != NSNotFound && [string rangeOfString:@"]"].location != NSNotFound)  return YES;
	if ([string rangeOfString:@"%H"].location != NSNotFound)  return YES;
	if ([string rangeOfString:@"%I"].location != NSNotFound)  return YES;
	if ([string rangeOfString:@"%R"].location != NSNotFound)  return YES;
	if ([string rangeOfString:@"%X"].location != NSNotFound)  return YES;
	
	return NO;
}


static BOOL IsIdentifier(NSString *string)
{
	if ([string length] == 0)  return NO;
	if ([string rangeOfCharacterFromSet:[IdentifierCharSet() invertedSet]].location != NSNotFound)  return NO;
	unichar first = [string characterAtIndex:0];
	if (first >= '0' && first <= '9')  return NO;
	
	return YES;
}


static NSString *LegalizeIdentifier(NSString *identifier, BOOL willBePrefixed)
{
	OOUInteger				i, count;
	unichar					curr;
	BOOL					lastIsUnderscore = NO;
	unsigned				rCount = 0;
	unichar					result[64];
	
	count = [identifier length];
	
	if (!willBePrefixed)
	{
		// If first char is digit, prefix with underscore
		if (count > 0)
		{
			curr = [identifier characterAtIndex:0];
			if (curr >= '0' && curr <= '9')  identifier = [@"_" stringByAppendingString:identifier];
		}
	}
	
	for (i = 0; i != count && rCount < 64; ++i)
	{
		curr = [identifier characterAtIndex:i];
		if (curr == '_')  lastIsUnderscore = NO;
		if (curr != '_' &&
			!(curr >= 'A' && curr <= 'Z') &&
			!(curr >= 'a' && curr <= 'z') &&
			!(curr >= '0' && curr <= '9' && i != 0))
		{
			curr = '_';
		}
		
		if (!lastIsUnderscore || curr != '_')
		{
			result[rCount++] = curr;
		}
		lastIsUnderscore = (curr == '_');
	}
	
	if (rCount == 0)  return @"";
	
	return [NSString stringWithCharacters:result length:rCount];
}

//
//  OOJSExprNode.m
//  ScriptConverter
//
//  Created by Jens Ayton on 2009-03-11.
//  Copyright 2009 Jens Ayton. All rights reserved.
//

#import "OOJSExprNode.h"
#import "OOLogging.h"
#import "TestRigHelpers.h"	// FIXME
#import "OOIsNumberLiteral.h"


enum
{
	kAtomPrecedence = 0
};


#if OOLITE_64_BIT
#define ROT(x, y) ({OOUInteger _x = (x), _y = (y); (_x << _y) | (_x >> (64 - _y)); })
#else
#define ROT(x, y) ({OOUInteger _x = (x), _y = (y); (_x << _y) | (_x >> (32 - _y)); })
#endif


void OOJSExprClearCache(void)
{
	// No cache implemented yet.
}


@implementation OOJSExprNode

- (NSString *) jsCodeRepresentation
{
	OOLogGenericSubclassResponsibility();
	return nil;
}


- (NSString *) jsCodeRepresentationForPrecedence:(uint8_t)parentPrecedence
{
	NSString *code = [self jsCodeRepresentation];
	if (parentPrecedence < [self precedence])
	{
		code = [NSString stringWithFormat:@"(%@)", code];
	}
	return code;
}


- (uint8_t) precedence
{
	OOLogGenericSubclassResponsibility();
	return 0;
}


- (OOUInteger) hash
{
	return [self shallowHash];
}


- (OOUInteger) shallowHash
{
	return 0;
}


- (id) copyWithZone:(NSZone *)zone
{
	// Subclasses are required to be immutable.
	return [self retain];
}


- (BOOL) isIntLiteral
{
	return NO;
}


- (BOOL) isDoubleLiteral
{
	return NO;
}


- (BOOL) isNumberLiteral
{
	return [self isIntLiteral] || [self isDoubleLiteral];
}


- (BOOL) isBooleanLiteral
{
	return NO;
}


- (BOOL) isStringLiteral
{
	return NO;
}


- (BOOL) isIdentifier
{
	return NO;
}


- (BOOL) isOperator
{
	return NO;
}


- (BOOL) isBinaryOperator
{
	return NO;
}

@end


@implementation OOJSIntLiteralExprNode

- (id) initWithIntValue:(int64_t)value
{
	if ((self = [super init]))
	{
		_value = value;
	}
	return self;
}


+ (id) nodeWithIntValue:(int64_t)value
{
	// FIXME: a cache for common values like 0 and 1 would probably be beneficial.
	// If done, a way to clean up all cached values would be good.
	return [[[self alloc] initWithIntValue:value] autorelease];
}


- (int64_t) int64Value
{
	return _value;
}


- (NSString *) jsCodeRepresentation
{
	return [NSString stringWithFormat:@"%lli", (long long)[self int64Value]];
}


- (uint8_t) precedence
{
	return kAtomPrecedence;
}


- (BOOL) isEqual:(id)other
{
	if ([other isKindOfClass:[OOJSIntLiteralExprNode class]])
	{
		return [other int64Value] == [self int64Value];
	}
	else  return NO;
}


- (OOUInteger) shallowHash
{
	return _value;
}


- (BOOL) isIntLiteral
{
	return YES;
}

@end


@implementation OOJSDoubleLiteralExprNode

- (id) initWithDoubleValue:(double)value
{
	if ((self = [super init]))
	{
		_value = value;
	}
	return self;
}


+ (id) nodeWithDoubleValue:(double)value
{
	// FIXME: a cache for common values like 0 and 1 would probably be beneficial.
	// If done, a way to clean up all cached values would be good.
	return [[[self alloc] initWithDoubleValue:value] autorelease];
}

- (double) doubleValue
{
	return _value;
}


- (NSString *) jsCodeRepresentation
{
	return [NSString stringWithFormat:@"%g", [self doubleValue]];
}


- (uint8_t) precedence
{
	return kAtomPrecedence;
}


- (BOOL) isEqual:(id)other
{
	if ([other isKindOfClass:[OOJSDoubleLiteralExprNode class]])
	{
		return [other doubleValue] == [self doubleValue];
	}
	else  return NO;
}


- (OOUInteger) shallowHash
{
	double value = [self doubleValue];
	OOUInteger h = value * 1009;
	h ^= (OOUInteger)value;
	
	return h;
}


- (BOOL) isDoubleLiteral
{
	return YES;
}

@end


@implementation OOJSBoolLiteralExprNode

static OOJSBoolLiteralExprNode *sYesNode = nil, *sNoNode = nil;


- (id) initWithBoolValue:(BOOL)value
{
	if ((self = [super init]))
	{
		_value = value;
	}
	return self;
}


+ (id) nodeWithBoolValue:(BOOL)value
{
	OOJSBoolLiteralExprNode **cache = value ? &sYesNode : &sNoNode;
	
	if (*cache == nil)
	{
		*cache = [[self alloc] initWithBoolValue:value];
	}
	
	return *cache;
}


- (BOOL) boolValue
{
	return _value;
}


- (NSString *) jsCodeRepresentation
{
	return [self boolValue] ? @"true" : @"false";
}


- (uint8_t) precedence
{
	return kAtomPrecedence;
}


- (BOOL) isEqual:(id)other
{
	if ([other isKindOfClass:[OOJSBoolLiteralExprNode class]])
	{
		return [other boolValue] == [self boolValue];
	}
	else  return NO;
}


- (OOUInteger) shallowHash
{
	return _value;
}


- (BOOL) isBooleanLiteral
{
	return YES;
}

@end


@implementation OOJSStringLiteralExprNode


- (id) initWithStringValue:(NSString *)value
{
	if ((self = [super init]))
	{
		_value = [value copy];
		NSString *escaped = [_value escapedForJavaScriptLiteral];
		if ([escaped isEqual:_value])  escaped = _value;
		_escaped = [escaped retain];
	}
	return self;
}


- (void) dealloc
{
	[_value release];
	[_escaped release];
	
	[super dealloc];
}


+ (id) nodeWithStringValue:(NSString *)value
{
	return [[[self alloc] initWithStringValue:value] autorelease];
}


- (NSString *) stringValue
{
	return _value;
}


- (NSString *) escapedStringValue
{
	return _escaped;
}


- (NSString *) jsCodeRepresentation
{
	return [NSString stringWithFormat:@"\"%@\"", _escaped];
}


- (uint8_t) precedence
{
	return kAtomPrecedence;
}


- (BOOL) isEqual:(id)other
{
	if ([other isKindOfClass:[OOJSStringLiteralExprNode class]])
	{
		return [[other stringValue] isEqual:[self stringValue]];
	}
	else  return NO;
}


- (OOUInteger) shallowHash
{
	return [_value hash];
}


- (BOOL) isStringLiteral
{
	return YES;
}

@end


@implementation OOJSIdentifierExprNode


- (id) initWithIdentifier:(NSString *)value
{
	if (![value isJavaScriptIdentifier])
	{
		[self release];
		return nil;
	}
	
	if ((self = [super init]))
	{
		_value = [value copy];
	}
	return self;
}


- (void) dealloc
{
	[_value release];
	
	[super dealloc];
}


+ (id) nodeWithIdentifier:(NSString *)value
{
	return [[[self alloc] initWithIdentifier:value] autorelease];
}


- (NSString *) identifier
{
	return _value;
}


- (NSString *) jsCodeRepresentation
{
	return [self identifier];
}


- (uint8_t) precedence
{
	return kAtomPrecedence;
}


- (BOOL) isEqual:(id)other
{
	if ([other isKindOfClass:[OOJSIdentifierExprNode class]])
	{
		return [[other identifier] isEqual:[self identifier]];
	}
	else  return NO;
}


- (OOUInteger) shallowHash
{
	return [_value hash];
}


- (BOOL) isIdentifierLiteral
{
	return YES;
}

@end


@implementation OOJSOperatorExprNode

- (NSString *) operatorToken
{
	OOLogGenericSubclassResponsibility();
	return nil;
}


- (OOUInteger) shallowHash
{
	return [[self operatorToken] hash];
}


- (BOOL) isOperator
{
	return YES;
}

@end


@implementation OOJSUnaryOperatorExprNode: OOJSOperatorExprNode

- (id) initWithSubExpression:(OOJSExprNode *)subExpression
{
	if ((self = [super init]))
	{
		_subExpr = [subExpression retain];
	}
	return self;
}


- (void) dealloc
{
	[_subExpr release];
	
	[super dealloc];
}


+ (id) nodeWithSubExpression:(OOJSExprNode *)subExpression
{
	return [[[self alloc] initWithSubExpression:subExpression] autorelease];
}


- (OOJSExprNode *) subExpression
{
	return _subExpr;
}


- (NSString *) subExpressionJSCode
{
	return [[self subExpression] jsCodeRepresentationForPrecedence:[self precedence]];
}


- (OOUInteger) hash
{
	return [self shallowHash] ^ ROT([[self subExpression] shallowHash], 13);
}


- (BOOL) isEqual:(id)other
{
	if (![other isMemberOfClass:[self class]])  return NO;
	
	return	[[other subExpression] isEqual:[self subExpression]];
}

@end


@implementation OOJSBinaryOperatorExprNode: OOJSOperatorExprNode

- (id) initWithLeftHandSide:(OOJSExprNode *)lhsExpression rightHandSide:(OOJSExprNode *)rhsExpression
{
	if ((self = [super init]))
	{
		_lhs = [lhsExpression retain];
		_rhs = [rhsExpression retain];
	}
	return self;
}


- (void) dealloc
{
	[_lhs release];
	[_rhs release];
	
	[super dealloc];
}


+ (id) nodeWithLeftHandSide:(OOJSExprNode *)lhsExpression rightHandSide:(OOJSExprNode *)rhsExpression
{
	return [[[self alloc] initWithLeftHandSide:lhsExpression rightHandSide:rhsExpression] autorelease];
}


- (NSString *) jsCodeRepresentation
{
	return [NSString stringWithFormat:@"%@ %@ %@", [self leftHandSideJSCode], [self operatorToken], [self rightHandSideJSCode]];
}


- (OOJSExprNode *) leftHandSideExpression
{
	return _lhs;
}


- (OOJSExprNode *) rightHandSideExpression
{
	return _rhs;
}


- (NSString *) leftHandSideJSCode
{
	return [_lhs jsCodeRepresentationForPrecedence:[self precedence] - [self rightAssociative] ? 1 : 0];
}


- (NSString *) rightHandSideJSCode
{
	return [_rhs jsCodeRepresentationForPrecedence:[self precedence] - [self rightAssociative] ? 0 : 1];
}


- (BOOL) rightAssociative
{
	return NO;
}


- (OOUInteger) hash
{
	return [self shallowHash] ^ ROT([[self leftHandSideExpression] shallowHash], 7) ^ ROT([[self rightHandSideExpression] shallowHash], 11);
}


- (BOOL) isEqual:(id)other
{
	if (![other isMemberOfClass:[self class]])  return NO;
	
	return	[[other leftHandSideExpression] isEqual:[self leftHandSideExpression]] &&
			[[other rightHandSideExpression] isEqual:[self rightHandSideExpression]];
}


- (BOOL) isBinaryOperator
{
	return YES;
}

@end


@implementation OOJSPropertyAccessExprNode

- (id) initWithObject:(id)objectExpression property:(id)propertyExpression
{
	if ([objectExpression isKindOfClass:[NSString class]])
	{
		// Note: nil if not valid identifier.
		objectExpression = [OOJSIdentifierExprNode nodeWithIdentifier:objectExpression];
	}
	
	if (objectExpression == nil || propertyExpression == nil)
	{
		[self release];
		return nil;
	}
	
	if ([propertyExpression isKindOfClass:[NSString class]])
	{
		if ([propertyExpression isJavaScriptIdentifier] && ![propertyExpression isJavaScriptKeyword])
		{
			propertyExpression = [OOJSIdentifierExprNode nodeWithIdentifier:propertyExpression];
		}
		else
		{
			propertyExpression = [OOJSStringLiteralExprNode nodeWithStringValue:propertyExpression];
		}
	}
	else if ([propertyExpression isKindOfClass:[OOJSStringLiteralExprNode class]])
	{
		NSString *stringValue = [(OOJSStringLiteralExprNode *)propertyExpression stringValue];
		if ([stringValue isJavaScriptIdentifier] && ![stringValue isJavaScriptKeyword])
		{
			propertyExpression = [OOJSIdentifierExprNode nodeWithIdentifier:stringValue];
		}
	}
	
	if ((self = [super init]))
	{
		_object = [objectExpression retain];
		_property = [propertyExpression retain];
		_isDot = [_property isKindOfClass:[OOJSIdentifierExprNode class]];
	}
	
	return self;
}


- (void) dealloc
{
	[_object release];
	[_property release];
	
	[super dealloc];
}


+ (id) nodeWithObject:(id)objectExpression property:(id)propertyExpression
{
	return [[[self alloc] initWithObject:objectExpression property:propertyExpression] autorelease];
}


- (OOJSExprNode *) objectExpression
{
	return _object;
}


- (OOJSExprNode *) propertyExpression
{
	return _property;
}

- (NSString *) jsCodeRepresentation
{
	if (_isDot)
	{
		return [NSString stringWithFormat:@"%@.%@", [_object jsCodeRepresentationForPrecedence:1], [(OOJSIdentifierExprNode *)_property identifier]];
	}
	else
	{
		return [NSString stringWithFormat:@"%@[%@]", [_object jsCodeRepresentationForPrecedence:1], [_property jsCodeRepresentationForPrecedence:1]];
	}
}


- (uint8_t) precedence
{
	return 1;
}


- (BOOL) isEqual:(id)other
{
	if (![other isKindOfClass:[OOJSPropertyAccessExprNode class]])  return NO;
	
	return	[[other objectExpression] isEqual:[self objectExpression]] &&
			[[other propertyExpression] isEqual:[self propertyExpression]];
}


- (NSString *) operatorToken
{
	return @"[]";
}

@end


@implementation OOJSNewOpExprNode

- (NSString *) jsCodeRepresentation
{
	return [NSString stringWithFormat:@"new %@", [self subExpressionJSCode]];
}


- (NSString *) operatorToken
{
	return @"new";
}


- (uint8_t) precedence
{
	return 1;
}

@end


@implementation OOJSFunctionCallExprNode

- (id) initWithFunction:(id)functionExpression arguments:(NSArray *)arguments
{
	if ([functionExpression isKindOfClass:[NSString class]])
	{
		// Note: nil if not valid identifier.
		functionExpression = [OOJSIdentifierExprNode nodeWithIdentifier:functionExpression];
	}
	
	if (functionExpression == nil)
	{
		[self release];
		return nil;
	}
	
	if (arguments == nil)
	{
		[arguments release];
		arguments = nil;
	}
	
	if ((self = [super init]))
	{
		_function = [functionExpression retain];
		_arguments = [arguments copy];
	}
	
	return self;
}


- (void) dealloc
{
	[_function release];
	[_arguments release];
	
	[super dealloc];
}


+ (id) nodeWithFunction:(id)functionExpression arguments:(NSArray *)arguments
{
	return [[[self alloc] initWithFunction:functionExpression arguments:arguments] autorelease];
}


- (NSString *) jsCodeRepresentation
{
	OOUInteger			i, count;
	NSMutableArray		*args = nil;
	NSString			*func = nil;
	NSString			*result = nil;
	
	func = [[self functionExpression] jsCodeRepresentationForPrecedence:2];
	
	count = [_arguments count];
	if (count != 0)
	{
		args = [[NSMutableArray alloc] initWithCapacity:count];
		for (i = 0; i < count; i++)
		{
			[args addObject:[[_arguments objectAtIndex:i] jsCodeRepresentationForPrecedence:16]];
		}
		result = [NSString stringWithFormat:@"%@(%@)", func, [args componentsJoinedByString:@", "]];
		[args release];
	}
	else
	{
		result = [NSString stringWithFormat:@"%@()", func];
	}
	return result;
}


- (OOJSExprNode *) functionExpression
{
	return _function;
}


- (NSArray *) arguments
{
	return _arguments;
}


- (NSString *) operatorToken
{
	return @"f()";
}


- (uint8_t) precedence
{
	return 2;
}


- (OOUInteger) hash
{
	return [_function hash] ^ [_arguments hash];
}


- (OOUInteger) shallowHash
{
	return [_function shallowHash] ^ 982856247; // just a random number
}

@end


@implementation OOJSPostfixIncrementOpExprNode

- (NSString *) jsCodeRepresentation
{
	return [NSString stringWithFormat:@"%@++", [self subExpressionJSCode]];
}


- (NSString *) operatorToken
{
	return @"x++";
}


- (uint8_t) precedence
{
	return 3;
}

@end


@implementation OOJSPostfixDecrementOpExprNode

- (NSString *) jsCodeRepresentation
{
	return [NSString stringWithFormat:@"%@--", [self subExpressionJSCode]];
}


- (NSString *) operatorToken
{
	return @"x--";
}


- (uint8_t) precedence
{
	return 3;
}

@end


@implementation OOJSPrefixIncrementOpExprNode

- (NSString *) jsCodeRepresentation
{
	return [NSString stringWithFormat:@"++%@", [self subExpressionJSCode]];
}


- (NSString *) operatorToken
{
	return @"++x";
}


- (uint8_t) precedence
{
	return 4;
}

@end


@implementation OOJSPrefixDecrementOpExprNode

- (NSString *) jsCodeRepresentation
{
	return [NSString stringWithFormat:@"--%@", [self subExpressionJSCode]];
}


- (NSString *) operatorToken
{
	return @"--x";
}


- (uint8_t) precedence
{
	return 4;
}

@end


@implementation OOJSDeleteOpExprNode

- (NSString *) jsCodeRepresentation
{
	return [NSString stringWithFormat:@"delete %@", [self subExpressionJSCode]];
}


- (NSString *) operatorToken
{
	return @"delete";
}


- (uint8_t) precedence
{
	return 4;
}

@end


@implementation OOJSVoidOpExprNode

- (NSString *) jsCodeRepresentation
{
	return [NSString stringWithFormat:@"void %@", [self subExpressionJSCode]];
}


- (NSString *) operatorToken
{
	return @"void";
}


- (uint8_t) precedence
{
	return 4;
}

@end


@implementation OOJSTypeofOpExprNode

- (NSString *) jsCodeRepresentation
{
	return [NSString stringWithFormat:@"typeof %@", [self subExpressionJSCode]];
}


- (NSString *) operatorToken
{
	return @"typeof";
}


- (uint8_t) precedence
{
	return 4;
}

@end


@implementation OOJSUnaryPlusOpExprNode

- (NSString *) jsCodeRepresentation
{
	return [NSString stringWithFormat:@"+%@", [self subExpressionJSCode]];
}


- (NSString *) operatorToken
{
	return @"+x";
}


- (uint8_t) precedence
{
	return 4;
}

@end


@implementation OOJSUnaryMinusOpExprNode

- (NSString *) jsCodeRepresentation
{
	return [NSString stringWithFormat:@"-%@", [self subExpressionJSCode]];
}


- (NSString *) operatorToken
{
	return @"-x";
}


- (uint8_t) precedence
{
	return 4;
}

@end


@implementation OOJSBitwiseNotOpExprNode

- (NSString *) jsCodeRepresentation
{
	return [NSString stringWithFormat:@"~%@", [self subExpressionJSCode]];
}


- (NSString *) operatorToken
{
	return @"~";
}


- (uint8_t) precedence
{
	return 4;
}

@end


@implementation OOJSLogicalNotOpExprNode

- (NSString *) jsCodeRepresentation
{
	return [NSString stringWithFormat:@"!%@", [self subExpressionJSCode]];
}


- (NSString *) operatorToken
{
	return @"!";
}


- (uint8_t) precedence
{
	return 4;
}

@end


@implementation OOJSMultiplyOpExprNode

- (NSString *) operatorToken
{
	return @"*";
}


- (uint8_t) precedence
{
	return 5;
}

@end


@implementation OOJSDivideOpExprNode

- (NSString *) operatorToken
{
	return @"/";
}


- (uint8_t) precedence
{
	return 5;
}

@end


@implementation OOJSRemainderOpExprNode

- (NSString *) operatorToken
{
	return @"%";
}


- (uint8_t) precedence
{
	return 5;
}

@end


@implementation OOJSAddOpExprNode

- (NSString *) operatorToken
{
	return @"+";
}


- (uint8_t) precedence
{
	return 6;
}

@end


@implementation OOJSSubtractOpExprNode

- (NSString *) operatorToken
{
	return @"-";
}


- (uint8_t) precedence
{
	return 6;
}

@end


@implementation OOJSLeftShiftOpExprNode

- (NSString *) operatorToken
{
	return @"<<";
}


- (uint8_t) precedence
{
	return 7;
}

@end


@implementation OOJSRightShiftOpExprNode

- (NSString *) operatorToken
{
	return @">>";
}


- (uint8_t) precedence
{
	return 7;
}

@end


@implementation OOJSUnsignedRightShiftOpExprNode

- (NSString *) operatorToken
{
	return @">>>";
}


- (uint8_t) precedence
{
	return 7;
}

@end


@implementation OOJSLessThanOpExprNode

- (NSString *) operatorToken
{
	return @"<";
}


- (uint8_t) precedence
{
	return 8;
}

@end


@implementation OOJSGreaterThanOpExprNode

- (NSString *) operatorToken
{
	return @">";
}


- (uint8_t) precedence
{
	return 8;
}

@end


@implementation OOJSLessThanOrEqualOpExprNode

- (NSString *) operatorToken
{
	return @"<=";
}


- (uint8_t) precedence
{
	return 8;
}

@end


@implementation OOJSGreaterThanOrEqualOpExprNode

- (NSString *) operatorToken
{
	return @">=";
}


- (uint8_t) precedence
{
	return 8;
}

@end


@implementation OOJSInstanceOfOpExprNode

- (NSString *) operatorToken
{
	return @"instanceof";
}


- (uint8_t) precedence
{
	return 8;
}

@end


@implementation OOJSInOpExprNode

- (NSString *) operatorToken
{
	return @"in";
}


- (uint8_t) precedence
{
	return 8;
}

@end


@implementation OOJSEqualOpExprNode

- (NSString *) operatorToken
{
	return @"==";
}


- (uint8_t) precedence
{
	return 9;
}

@end


@implementation OOJSNotEqualOpExprNode

- (NSString *) operatorToken
{
	return @"!=";
}


- (uint8_t) precedence
{
	return 9;
}

@end


@implementation OOJSStrictlyEqualOpExprNode

- (NSString *) operatorToken
{
	return @"===";
}


- (uint8_t) precedence
{
	return 9;
}

@end


@implementation OOJSNotStrictlyEqualOpExprNode

- (NSString *) operatorToken
{
	return @"!==";
}


- (uint8_t) precedence
{
	return 9;
}

@end


@implementation OOJSBitwiseAndExprNode

- (NSString *) operatorToken
{
	return @"&";
}


- (uint8_t) precedence
{
	return 10;
}

@end


@implementation OOJSBitwiseXorExprNode

- (NSString *) operatorToken
{
	return @"^";
}


- (uint8_t) precedence
{
	return 11;
}

@end


@implementation OOJSBitwiseOrExprNode

- (NSString *) operatorToken
{
	return @"|";
}


- (uint8_t) precedence
{
	return 12;
}

@end


@implementation OOJSLogicalAndExprNode

- (NSString *) operatorToken
{
	return @"&&";
}


- (uint8_t) precedence
{
	return 13;
}

@end


@implementation OOJSLogicalOrExprNode

- (NSString *) operatorToken
{
	return @"||";
}


- (uint8_t) precedence
{
	return 14;
}

@end


@implementation OOJSConditionalExprNode

- (id) initWithCondition:(OOJSExprNode *)condition
		  trueExpression:(OOJSExprNode *)trueExpression
		 falseExpression:(OOJSExprNode *)falseExpression
{
	if ((self = [super init]))
	{
		_condition = [condition retain];
		_trueExpr = [trueExpression retain];
		_falseExpr = [falseExpression retain];
	}
	return self;
}


- (void) dealloc
{
	[_condition release];
	[_trueExpr release];
	[_falseExpr release];
	
	[super dealloc];
}


+ (id) nodeWithCondition:(OOJSExprNode *)condition
		  trueExpression:(OOJSExprNode *)trueExpression
		 falseExpression:(OOJSExprNode *)falseExpression
{
	return [[[self alloc] initWithCondition:condition
							 trueExpression:trueExpression
							falseExpression:falseExpression] autorelease];
}


- (NSString *) jsCodeRepresentation
{
	return [NSString stringWithFormat:@"%@ ? %@ : %@", [self conditionJSCode], [self trueExpressionJSCode], [self falseExpressionJSCode]];
}

- (NSString *) operatorToken
{
	return @"?:";
}


- (uint8_t) precedence
{
	return 15;
}


- (OOJSExprNode *) conditionExpression
{
	return _condition;
}


- (OOJSExprNode *) trueExpression
{
	return _trueExpr;
}


- (OOJSExprNode *) falseExpression
{
	return _falseExpr;
}


- (NSString *) conditionJSCode
{
	// 4 is an arbitrary stylistic choice - it results in binary ops being bracketed even if not strictly necessary.
	return [_condition jsCodeRepresentationForPrecedence:4];
}


- (NSString *) trueExpressionJSCode
{
	return [_trueExpr jsCodeRepresentationForPrecedence:[self precedence]];
}


- (NSString *) falseExpressionJSCode
{
	return [_falseExpr jsCodeRepresentationForPrecedence:[self precedence]];
}


- (OOUInteger) hash
{
	return	[self shallowHash] ^ 
			ROT([[self conditionExpression] shallowHash], 5) ^
			ROT([[self trueExpression] shallowHash], 19) ^
			ROT([[self falseExpression] shallowHash], 23);
}


- (BOOL) isEqual:(id)other
{
	if (![other isMemberOfClass:[self class]])  return NO;
	
	return	[[other conditionExpression] isEqual:[self conditionExpression]] &&
			[[other trueExpression] isEqual:[self trueExpression]] &&
			[[other falseExpression] isEqual:[self falseExpression]];
}

@end


@implementation OOJSAssignExprNode

- (NSString *) operatorToken
{
	return @"=";
}


- (uint8_t) precedence
{
	return 16;
}


- (BOOL) rightAssociative
{
	return YES;
}

@end


@implementation OOJSMultiplyAssignExprNode

- (NSString *) operatorToken
{
	return @"*=";
}

@end


@implementation OOJSDivideAssignExprNode

- (NSString *) operatorToken
{
	return @"/=";
}

@end


@implementation OOJSRemainderAssignExprNode

- (NSString *) operatorToken
{
	return @"%=";
}

@end


@implementation OOJSAddAssignExprNode

- (NSString *) operatorToken
{
	return @"+=";
}

@end


@implementation OOJSSubtractAssignExprNode

- (NSString *) operatorToken
{
	return @"-=";
}

@end


@implementation OOJSLeftShiftAssignExprNode

- (NSString *) operatorToken
{
	return @"<<=";
}

@end


@implementation OOJSRightShiftAssignExprNode

- (NSString *) operatorToken
{
	return @">>=";
}

@end


@implementation OOJSUnsignedRightShiftAssignExprNode

- (NSString *) operatorToken
{
	return @">>>=";
}

@end


@implementation OOJSBitwiseAndAssignExprNode

- (NSString *) operatorToken
{
	return @"&=";
}

@end


@implementation OOJSBitwiseXorAssignExprNode

- (NSString *) operatorToken
{
	return @"^=";
}

@end


@implementation OOJSBitwiseOrAssignExprNode

- (NSString *) operatorToken
{
	return @"|=";
}

@end


@implementation OOJSSequentialEvaluationExprNode

- (NSString *) jsCodeRepresentation
{
	return [NSString stringWithFormat:@"%@, %@", [self leftHandSideJSCode], [self rightHandSideJSCode]];
}


- (NSString *) operatorToken
{
	return @",";
}


- (uint8_t) precedence
{
	return 17;
}

@end


// Marker for errors
@implementation OOJSErrorExprNode

- (id) initWithMessage:(NSString *)message
{
	if ((self = [super init]))
	{
		_message = [message copy];
	}
	return self;
}


- (void) dealloc
{
	[_message release];
	
	[super dealloc];
}


+ (id) nodeWithMessage:(NSString *)message
{
	return [[[self alloc] initWithMessage:message] autorelease];
}


- (NSString *)message
{
	return _message;
}


- (NSString *) jsCodeRepresentation
{
	// Deliberately invalid code.
	return [NSString stringWithFormat:@"<** %@ **>", [self message]];
}


- (OOUInteger) shallowHash
{
	return [[self message] hash];
}


- (BOOL) isEqual:(id)other
{
	if (![other isKindOfClass:[OOJSErrorExprNode class]])  return NO;
	
	return [[self message] isEqual:[other message]];
}


- (uint8_t) precedence
{
	return 0;
}

@end


OOJSExprNode *OOJSExprNumberFromLiteral(NSString *literal)
{
	if (literal == nil)  return nil;
	if (!OOIsNumberLiteral(literal, YES))  return nil;
	
	if ([literal rangeOfString:@"."].location != NSNotFound ||
		[literal rangeOfString:@"e"].location != NSNotFound ||
		[literal rangeOfString:@"E"].location != NSNotFound)
	{
		return [OOJSDoubleLiteralExprNode nodeWithDoubleValue:[literal doubleValue]];
	}
	else
	{
		return [OOJSDoubleLiteralExprNode nodeWithDoubleValue:[literal intValue]];
	}
}

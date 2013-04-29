//
//  OOLegacyScriptToJavaScriptConverterCore.m
//  ScriptConverter
//
//  Created by Jens Ayton on 2008-08-30.
//  Copyright 2008 Jens Ayton. All rights reserved.
//

#import "OOLegacyScriptToJavaScriptConverterCore.h"
#import "NSScannerOOExtensions.h"
#import "OOCollectionExtractors.h"
#import "OOJSExprNodeHelpers.h"


#define COMMENT_SELECTOR		0


typedef enum
{
	kComparisonEqual,
	kComparisonNotEqual,
	kComparisonLessThan,
	kComparisonGreaterThan,
	kComparisonOneOf,
	kComparisonUndefined
} OOComparisonType;


typedef enum
{
	kTypeInvalid,
	kTypeString,
	kTypeNumber,
	kTypeBool
} OOOperandType;


static NSMutableArray *ScanTokensFromString(NSString *values);


@interface OOLegacyScriptToJavaScriptConverter (ConverterCorePrivate)

- (void) convertConditional:(NSDictionary *)conditional;

- (void) convertOneAction:(NSString *)action;

- (NSString *) convertOneCondition:(NSString *)condition;
- (OOJSExprNode *) convertQuery:(NSString *)query gettingType:(OOOperandType *)outType;
- (OOJSExprNode *) convertStringCondition:(OOComparisonType)comparator comparatorString:(NSString *)comparatorString lhs:(OOJSExprNode *)lhs rhs:(OOJSExprNode *)rhs rawCondition:(NSString *)rawCondition;
- (OOJSExprNode *) convertNumberCondition:(OOComparisonType)comparator comparatorString:(NSString *)comparatorString lhs:(OOJSExprNode *)lhs rhs:(OOJSExprNode *)rhs rawCondition:(NSString *)rawCondition;
- (OOJSExprNode *) convertBoolCondition:(OOComparisonType)comparator comparatorString:(NSString *)comparatorString lhs:(OOJSExprNode *)lhs rhs:(OOJSExprNode *)rhs rawCondition:(NSString *)rawCondition;

#if OBSOLETE
- (NSString *) stringifyBooleanExpression:(NSString *)expr;
#endif

@end


@implementation OOLegacyScriptToJavaScriptConverter (ConverterCore)

- (void) convertActions:(NSArray *)actions
{
	OOUInteger				i, count;
	id						action;
	NSAutoreleasePool		*pool = nil;
	
	count = [actions count];
	
	NS_DURING
		for (i = 0; i != count; ++i)
		{
			pool = [[NSAutoreleasePool alloc] init];
			
			action = [actions objectAtIndex:i];
			
			if ([action isKindOfClass:[NSString class]])
			{
				[self convertOneAction:action];
			}
			else if ([action isKindOfClass:[NSDictionary class]])
			{
				[self convertConditional:action];
			}
			else
			{
				[self addStopIssueWithKey:@"invalid-type"
								   format:@"Expected string (action) or dictionary (conditional), but found %@.", [action class]];
				[self appendWithFormat:@"<** Invalid object of class %@ **>", [action class]];
			}
			
			[pool release];
			pool = nil;
		}
	NS_HANDLER
		[pool release];
		[localException raise];
	NS_ENDHANDLER
}

@end


@implementation OOLegacyScriptToJavaScriptConverter (ConverterCorePrivate)

- (void) convertConditional:(NSDictionary *)conditional
{
	NSArray					*conditions = nil;
	NSArray					*ifTrue = nil;
	NSArray					*ifFalse = nil;
	OOUInteger				i, count;
	NSString				*cond = nil;
	BOOL					flipCondition = NO;
	
	conditions = [conditional arrayForKey:@"conditions"];
	ifTrue = [conditional arrayForKey:@"do"];
	ifFalse = [conditional arrayForKey:@"else"];
	
	if (ifTrue == nil && ifFalse == nil)
	{
		[self addWarningIssueWithKey:@"empty-conditional-action"
							  format:@"Conditional expression with neither \"do\" clause nor \"else\" clause, ignoring."];
		return;
	}
	
	if ([ifTrue count] == 0)
	{
		flipCondition = YES;
		ifTrue = ifFalse;
		ifFalse = nil;
	}
	
	count = [conditions count];
	if (count == 0)
	{
		[self addWarningIssueWithKey:@"empty-conditions"
							  format:@"Empty or invalid conditions array, treating as always true."];
		ifFalse = nil;
		// Treat as always-true for backwards-compatibility
	}
	else
	{
		[self append:@"if ("];
		if (flipCondition)  [self append:@"!("];
		
		for (i = 0; i != count; ++i)
		{
			if (i != 0)
			{
				[self append:@" &&\n\t"];
				if (flipCondition)  [self append:@"  "];
			}
			
			cond = [self convertOneCondition:[conditions objectAtIndex:i]];
			if (cond == nil)
			{
				if (_validConversion)
				{
					[self addBugIssueWithKey:@"unreported-error"
									  format:@"An error occurred while converting a condition, but no appropriate message was generated."];
				}
				cond = @"<** invalid **>";
			}
			
			if (count != 1)  cond = [NSString stringWithFormat:@"(%@)", cond];
			
			[self append:cond];
		}
		
		if (flipCondition)  [self append:@")"];
		[self append:@")\n{\n"];
	}
	
	[self indent];
	[self convertActions:ifTrue];
	[self outdent];
	[self append:@"}\n"];
	if (ifFalse != nil)
	{
		[self append:@"else\n{\n"];
		[self indent];
		[self convertActions:ifFalse];
		[self outdent];
		[self append:@"}\n"];
	}
}


- (void) convertOneAction:(NSString *)action
{
	NSMutableArray		*tokens = nil;
	NSString			*selectorString = nil;
	unsigned			tokenCount;
	BOOL				takesParam;
	NSString			*valueString = nil;
	SEL					selector = NULL;
	NSString			*converted = nil;
	
	// Work around one of Eric's evil hacks
	if ([action hasPrefix:@"/*"] && [action hasSuffix:@"*/"])
	{
		[self append:[action stringByAppendingString:@"\n"]];
		return;
	}
	
	tokens = ScanTokensFromString(action);
	
	tokenCount = [tokens count];
	if (tokenCount < 1)
	{
		// This is a hard error in the interpreter, so it's a failure here.
		[self addStopIssueWithKey:@"no-tokens"
						   format:@"Invalid or empty script action \"%@\"", action];
	}
	
	selectorString = [tokens objectAtIndex:0];
	takesParam = [selectorString hasSuffix:@":"];
	
	if (takesParam && tokenCount > 1)
	{
		if (tokenCount == 2) valueString = [tokens objectAtIndex:1];
		else
		{
			[tokens removeObjectAtIndex:0];
			valueString = [tokens componentsJoinedByString:@" "];
		}
	}
	
	selector = NSSelectorFromString([@"convertAction_" stringByAppendingString:selectorString]);
	if ([self respondsToSelector:selector])
	{
		if (takesParam)
		{
			converted = [self performSelector:selector withObject:valueString];
		}
		else
		{
			converted = [self performSelector:selector];
		}
		
		if (converted == nil)
		{
			if (_validConversion)
			{
				[self addBugIssueWithKey:@"unreported-error"
								  format:@"An error occurred while converting an action, but no appropriate message was generated (selector: \"%@\").", selectorString];
			}
			converted = [NSString stringWithFormat:@"<** bad %@ **>", selectorString];
		}
		
#if COMMENT_SELECTOR
		converted = [NSString stringWithFormat:@"%@\t\t// %@", converted, selectorString];
#endif
	}
	else
	{
		converted = [NSString stringWithFormat:@"<** %@ **>\t\t// *** UNKNOWN ***", action];
		[self addUnknownSelectorIssueWithKey:@"unknown-selector"
									  format:@"Could not convert unknown action selector \"%@\".", selectorString];
	}
	
	if ([converted length] > 0)  [self appendWithFormat:@"%@\n", converted];
}


- (NSString *) convertOneCondition:(NSString *)condition
{
	NSArray				*tokens = nil;
	NSString			*comparisonString = nil;
	OOComparisonType	comparator = kComparisonUndefined;
	unsigned			tokenCount;
	OOJSExprNode		*lhs = nil;
	OOOperandType		lhsType = kTypeInvalid;
	NSString			*rhsString = nil;
	OOJSExprNode		*rhs = nil;
	OOJSExprNode		*result = nil;
	
	if (![condition isKindOfClass:[NSString class]])
	{
		[self addStopIssueWithKey:@"invalid-condition"
						   format:@"Condition should be string, but found %@.", [condition class]];
		return [NSString stringWithFormat:@"<** Invalid object of class %@ **>", [condition class]];
	}
	
	tokens = ScanTokensFromString(condition);
	tokenCount = [tokens count];
	if (tokenCount == 0)
	{
		// This is a hard error in the interpreter, so it's a failure here.
		[self addStopIssueWithKey:@"no-tokens"
						   format:@"Invalid or empty script condition \"%@\"", condition];
		return @"<** invalid/empty condition **>";
	}
	
	lhs = [self convertQuery:[tokens objectAtIndex:0] gettingType:&lhsType];
	
	if (tokenCount > 1)
	{
		comparisonString = [tokens objectAtIndex:1];
		
		if ([comparisonString isEqualToString:@"equal"])  comparator = kComparisonEqual;
		else if ([comparisonString isEqualToString:@"notequal"])  comparator = kComparisonNotEqual;
		else if ([comparisonString isEqualToString:@"lessthan"])  comparator = kComparisonLessThan;
		else if ([comparisonString isEqualToString:@"greaterthan"])  comparator = kComparisonGreaterThan;
		else if ([comparisonString isEqualToString:@"morethan"])  comparator = kComparisonGreaterThan;
		else if ([comparisonString isEqualToString:@"oneof"])  comparator = kComparisonOneOf;
		else if ([comparisonString isEqualToString:@"undefined"])  comparator = kComparisonUndefined;
		else
		{
			[self addStopIssueWithKey:@"invalid-comparator"
							   format:@"Unknown comparison operator \"%@\" in condition \"%@\".", comparisonString, condition];
			return [NSString stringWithFormat:@"<** unknown comparison operator \"%@\" **>", comparisonString];
		}
	}
	
	if (tokenCount > 2)
	{
		rhsString = [[tokens subarrayWithRange:NSMakeRange(2, tokenCount - 2)] componentsJoinedByString:@" "];
		rhs = [self expandRightHandSide:rhsString];
	}
	
	if (lhsType == kTypeString)  result = [self convertStringCondition:comparator comparatorString:comparisonString lhs:lhs rhs:rhs rawCondition:condition];
	else if (lhsType == kTypeNumber)  result = [self convertNumberCondition:comparator comparatorString:comparisonString lhs:lhs rhs:rhs rawCondition:condition];
	else if (lhsType == kTypeBool)  result = [self convertBoolCondition:comparator comparatorString:comparisonString lhs:lhs rhs:rhs rawCondition:condition];
	
	if (result == nil)
	{
		[self addBugIssueWithKey:@"condition-conversion-failed"
						  format:@"Conversion of condition \"%@\" failed for unknown reasons.", condition];
		result = EX_ERROR(@"condition conversion failed");
	}
	return [result jsCodeRepresentation];
}


- (OOJSExprNode *) convertStringCondition:(OOComparisonType)comparator comparatorString:(NSString *)comparatorString lhs:(OOJSExprNode *)lhs rhs:(OOJSExprNode *)rhs rawCondition:(NSString *)rawCondition
{
	OOJSExprNode			*parseFloatOrZero = nil;
	
	switch (comparator)
	{
		case kComparisonEqual:
			return EX_EQUAL(lhs, rhs);
			
		case kComparisonNotEqual:
			return EX_NOT_EQUAL(lhs, rhs);
			
		case kComparisonLessThan:
			[self setParseFloatOrZeroHelper];
			parseFloatOrZero = EX_THIS_PROP(@"parseFloatOrZero");
			
			if (![rhs isNumberLiteral])
			{
				rhs = EX_CALL(parseFloatOrZero, rhs);
			}
			// this.parseFloatOrZero(lhs) < rhs
			return EX_LESS(EX_CALL(parseFloatOrZero, lhs), rhs);
			
		case kComparisonGreaterThan:
			[self setParseFloatOrZeroHelper];
			parseFloatOrZero = EX_THIS_PROP(@"parseFloatOrZero");
			
			if (![rhs isNumberLiteral])
			{
				rhs = EX_CALL(parseFloatOrZero, rhs);
			}
			// this.parseFloatOrZero(lhs) > rhs
			return EX_GRTR(EX_CALL(parseFloatOrZero, lhs), rhs);
			
		case kComparisonOneOf:
			[self setHelperFunction:
					@"function (string, list)\n{\n"
					"\tlet items = list.split(\",\");\n"
					"\treturn items.indexOf(string) != -1;\n}"
				forKey:@"oneOf"];
			// this.oneOf(lhs, rhs)
			return EX_CALL(EX_THIS_PROP(@"oneOf"), lhs, rhs);
			
		case kComparisonUndefined:
			[self setHelperFunction:
					@"function (value)\n{\n"
					"\treturn value == undefined || value == null;\n}"
				forKey:@"isUndefined"];
			// this.isUndefined(lhs)
			return EX_CALL(EX_THIS_PROP(@"isUndefined"), lhs);
	}
	
	return nil;
}


- (OOJSExprNode *) convertNumberCondition:(OOComparisonType)comparator comparatorString:(NSString *)comparatorString lhs:(OOJSExprNode *)lhs rhs:(OOJSExprNode *)rhs rawCondition:(NSString *)rawCondition
{
	switch (comparator)
	{
		case kComparisonEqual:
			return EX_EQUAL(lhs, rhs);
			
		case kComparisonNotEqual:
			return EX_NOT_EQUAL(lhs, rhs);
			
		case kComparisonLessThan:
			return EX_LESS(lhs, rhs);
			
		case kComparisonGreaterThan:
			return EX_GRTR(lhs, rhs);
			
		case kComparisonOneOf:
			[self setParseFloatOrZeroHelper];
			[self setHelperFunction:
					 @"function (number, list)\n{\n"
					 "\tlet items = list.split(\",\");\n"
					 "\tfor (let i = 0; i < items.length; ++i)  if (number == parseFloatOrZero(list[i]))  return true;\n"
					 "\treturn false;\n}"
				 forKey:@"oneOfNumber"];
			return EX_CALL(EX_THIS_PROP(@"oneOfNumber"), lhs, rhs);
			
		case kComparisonUndefined:
			[self addBugIssueWithKey:@"invalid-comparator"
							  format:@"Operator %@ is not valid for number expressions (condition: %@).", comparatorString, rawCondition];
			return EX_ERROR_FMT(@"invalid operator %@", comparatorString);
	}
	
	return nil;
}


- (OOJSExprNode *) convertBoolCondition:(OOComparisonType)comparator comparatorString:(NSString *)comparatorString lhs:(OOJSExprNode *)lhs rhs:(OOJSExprNode *)rhs rawCondition:(NSString *)rawCondition
{
	BOOL					convertedRHS = NO;
	
	if ([rhs isStringLiteral])
	{
		NSString *rhsString = [(OOJSStringLiteralExprNode *)rhs stringValue];
		if ([rhsString isEqual:@"YES"])
		{
			rhs = EX_TRUE;
			convertedRHS = YES;
		}
		else if ([rhsString isEqual:@"NO"])
		{
			rhs = EX_FALSE;
			convertedRHS = YES;
		}
	}
	if (!convertedRHS)
	{
		[self setHelperFunction:
		 @"function (flag)\n{\n"
		 "\t// Convert booleans to YES/NO for comparisons.\n"
		 "\treturn flag ? \"YES\" : \"NO\";\n}"
						 forKey:@"boolToString"];
		
		lhs = EX_CALL(EX_THIS_PROP(@"boolToString"), lhs);
	}
	
	switch (comparator)
	{
		case kComparisonEqual:
			if ([rhs isBooleanLiteral])
			{
				if ([(OOJSBoolLiteralExprNode *)rhs boolValue])  return lhs;
				else  return EX_NOT(lhs);
			}
			else
			{
				return EX_EQUAL(lhs, rhs);
			}
			
		case kComparisonNotEqual:
			if ([rhs isBooleanLiteral])
			{
				if ([(OOJSBoolLiteralExprNode *)rhs boolValue])  return EX_NOT(lhs);
				else  return lhs;
			}
			else
			{
				return EX_NOT_EQUAL(lhs, rhs);
			}
			
		case kComparisonLessThan:
		case kComparisonGreaterThan:
		case kComparisonOneOf:
		case kComparisonUndefined:
			[self addBugIssueWithKey:@"invalid-comparator"
							  format:@"Operator %@ is not valid for boolean expressions (condition: %@).", comparatorString, rawCondition];
			return EX_ERROR_FMT(@"invalid operator %@", comparatorString);
	}
	
	return nil;
}


- (OOJSExprNode *) convertQuery:(NSString *)query gettingType:(OOOperandType *)outType
{
	SEL					selector;
	OOJSExprNode		*converted = nil;
	
	assert(outType != NULL);
	
	if ([query hasPrefix:@"mission_"] || [query hasPrefix:@"local_"])
	{
		// Variables in legacy engine are always considered strings.
		*outType = kTypeString;
		return [self convertVariableAccess:query];
	}
	
	if ([query hasSuffix:@"_string"])  *outType = kTypeString;
	else if ([query hasSuffix:@"_number"])  *outType = kTypeNumber;
	else if ([query hasSuffix:@"_bool"])  *outType = kTypeBool;
	else  *outType = kTypeInvalid;
	
	selector = NSSelectorFromString([@"convertQuery_" stringByAppendingString:query]);
	if ([self respondsToSelector:selector])
	{
		converted = [self performSelector:selector];
		if (converted == nil)
		{
			if (_validConversion)
			{
				[self addBugIssueWithKey:@"unreported-error"
								  format:@"An error occurred while converting a condition, but no appropriate message was generated (selector: \"%@\").", query];
			}
			converted = EX_ERROR(@"unknown error");
		}
	}
	else	
	{
		[self addUnknownSelectorIssueWithKey:@"unknown-selector"
									  format:@"Could not convert unknown conditional selector \"%@\".", query];
		converted = EX_ERROR(query);
	}
	
	return converted;
}


#if OBSOLETE
- (NSString *) stringifyBooleanExpression:(NSString *)expr
{
	[self setHelperFunction:
			@"function (flag)\n{\n"
			"\t// Convert booleans to YES/NO for comparisons.\n"
			"\treturn flag ? \"YES\" : \"NO\";\n}"
		forKey:@"boolToString"];
	return [NSString stringWithFormat:@"this.boolToString(%@)", expr];
}
#endif


/*** Action handlers ***/

- (NSString *) convertAction_set:(NSString *)params
{
	NSMutableArray		*tokens = nil;
	NSString			*missionVariableString = nil;
	NSString			*valueString = nil;
	
	tokens = ScanTokensFromString(params);
	
	if ([tokens count] < 2)
	{
		[self addStopIssueWithKey:@"set-syntax-error"
						   format:@"Bad syntax for set: -- expected mission_variable or local_variable followed by value expression, got \"%@\".", params];
		return nil;
	}
	
	missionVariableString = [tokens objectAtIndex:0];
	[tokens removeObjectAtIndex:0];
	valueString = [tokens componentsJoinedByString:@" "];
	
	if ([missionVariableString hasPrefix:@"mission_"] || [missionVariableString hasPrefix:@"local_"])
	{
		return [NSString stringWithFormat:@"%@ = %@;", [self legalizedVariableName:missionVariableString], [self expandStringOrNumber:valueString]];
	}
	else
	{
		[self addStopIssueWithKey:@"set-syntax-error"
						   format:@"Bad syntax for set: -- expected mission_variable or local_variable, got \"%@\".", missionVariableString];
		return nil;
	}
}


- (NSString *) convertAction_reset:(NSString *)variable
{
	NSString *legalized = [self legalizedVariableName:variable];
	if (legalized == nil)  return nil;
	
	return [NSString stringWithFormat:@"%@ = null;", legalized];
}


- (NSString *) convertAction_add:(NSString *)params
{
	NSMutableArray		*tokens = nil;
	NSString			*missionVariableString = nil;
	NSString			*valueString = nil;
	
	tokens = ScanTokensFromString(params);
	
	if ([tokens count] < 2)
	{
		[self addStopIssueWithKey:@"add-syntax-error"
						   format:@"Bad syntax for add: -- expected mission_variable or local_variable followed by value expression, got \"%@\".", params];
		return nil;
	}
	
	missionVariableString = [tokens objectAtIndex:0];
	[tokens removeObjectAtIndex:0];
	valueString = [tokens componentsJoinedByString:@" "];
	
	if ([missionVariableString hasPrefix:@"mission_"] || [missionVariableString hasPrefix:@"local_"])
	{
		[self setParseFloatOrZeroHelper];
		missionVariableString = [self legalizedVariableName:missionVariableString];
		return [NSString stringWithFormat:@"%@ = this.parseFloatOrZero(%@) + %@;", missionVariableString, missionVariableString, [self expandFloatExpression:valueString]];
	}
	else
	{
		[self addStopIssueWithKey:@"add-syntax-error"
						   format:@"Bad syntax for add: -- expected mission_variable or local_variable, got \"%@\".", missionVariableString];
		return nil;
	}
}


- (NSString *) convertAction_subtract:(NSString *)params
{
	NSMutableArray		*tokens = nil;
	NSString			*missionVariableString = nil;
	NSString			*valueString = nil;
	
	tokens = ScanTokensFromString(params);
	
	if ([tokens count] < 2)
	{
		[self addStopIssueWithKey:@"subtract-syntax-error"
						   format:@"Bad syntax for subtract: -- expected mission_variable or local_variable followed by value expression, got \"%@\".", params];
		return nil;
	}
	
	missionVariableString = [tokens objectAtIndex:0];
	[tokens removeObjectAtIndex:0];
	valueString = [tokens componentsJoinedByString:@" "];
	
	if ([missionVariableString hasPrefix:@"mission_"] || [missionVariableString hasPrefix:@"local_"])
	{
		[self setParseFloatOrZeroHelper];
		missionVariableString = [self legalizedVariableName:missionVariableString];
		return [NSString stringWithFormat:@"%@ = this.parseFloatOrZero(%@) - %@;", missionVariableString, missionVariableString, [self expandFloatExpression:valueString]];
	}
	else
	{
		[self addStopIssueWithKey:@"subtract-syntax-error"
						   format:@"Bad syntax for subtract: -- expected mission_variable or local_variable, got \"%@\".", missionVariableString];
		return nil;
	}
}


- (NSString *) convertAction_increment:(NSString *)string
{
	[self setParseIntOrZeroHelper];
	NSString *varStr = [self legalizedVariableName:string];
	return [NSString stringWithFormat:@"%@ = this.parseIntOrZero(%@) + 1;", varStr, varStr];
}


- (NSString *) convertAction_decrement:(NSString *)string
{
	[self setParseIntOrZeroHelper];
	NSString *varStr = [self legalizedVariableName:string];
	return [NSString stringWithFormat:@"%@ = this.parseIntOrZero(%@) - 1;", varStr, varStr];
}


- (NSString *) convertAction_commsMessage:(NSString *)string
{
	return [NSString stringWithFormat:@"player.commsMessage(%@);", [self expandString:string]];
}


- (NSString *) convertAction_setMissionImage:(NSString *)string
{
	return [NSString stringWithFormat:@"mission.setBackgroundImage(%@);", [self expandString:string]];
}


- (NSString *) convertAction_showShipModel:(NSString *)string
{
	return [NSString stringWithFormat:@"mission.showShipModel(%@);", [self expandString:string]];
}


- (NSString *) convertAction_checkForShips:(NSString *)string
{
	[self setInitializer:@"this.shipsFound = 0;" forKey:@"shipsFound"];
	return [NSString stringWithFormat:@"this.shipsFound = system.countShipsWithPrimaryRole(%@);", [self expandString:string]];
}


- (NSString *) convertAction_awardCredits:(NSString *)string
{
	return [NSString stringWithFormat:@"player.credits += %@;", [self expandIntegerExpression:string]];
}


- (NSString *) convertAction_awardShipKills:(NSString *)string
{
	return [NSString stringWithFormat:@"player.score += %@;", [self expandIntegerExpression:string]];
}


- (NSString *) convertAction_awardFuel:(NSString *)string
{
	return [NSString stringWithFormat:@"player.ship.fuel += %@;", [self expandFloatExpression:string]];
}


- (NSString *) convertAction_addFuel:(NSString *)string
{
	return [NSString stringWithFormat:@"player.ship.fuel += %@;", [self expandFloatExpression:string]];
}


- (NSString *) convertAction_setLegalStatus:(NSString *)string
{
	return [NSString stringWithFormat:@"player.bounty = %@;", [self expandIntegerExpression:string]];
}


- (NSString *) convertAction_addMissionText:(NSString *)string
{
	return [NSString stringWithFormat:@"mission.addMessageTextKey(%@);", [self expandString:string]];
}


- (NSString *) convertAction_setMissionChoices:(NSString *)string
{
	return [NSString stringWithFormat:@"mission.setChoicesKey(%@);", [self expandString:string]];
}


- (NSString *) convertAction_useSpecialCargo:(NSString *)string
{
	return [NSString stringWithFormat:@"mission.useSpecialCargo(%@);", [self expandString:string]];
}


- (NSString *) convertAction_consoleMessage3s:(NSString *)string
{
	return [NSString stringWithFormat:@"player.consoleMessage(%@);", [self expandString:string]];
}


- (NSString *) convertAction_consoleMessage6s:(NSString *)string
{
	return [NSString stringWithFormat:@"player.consoleMessage(%@, 6.0);", [self expandString:string]];
}


- (NSString *) convertAction_testForEquipment:(NSString *)string
{
	[self setInitializer:@"this.foundEqipment = false;" forKey:@"foundEqipment"];
	return [NSString stringWithFormat:@"this.foundEqipment = player.ship.hasEquipment(%@);", [self expandString:string]];
}


- (NSString *) convertAction_awardEquipment:(NSString *)string
{
	return [NSString stringWithFormat:@"player.ship.awardEquipment(%@);", [self expandString:string]];
}


- (NSString *) convertAction_removeEquipment:(NSString *)string
{
	return [NSString stringWithFormat:@"player.ship.removeEquipment(%@);", [self expandString:string]];
}


- (NSString *) convertAction_setFuelLeak:(NSString *)string
{
	return [NSString stringWithFormat:@"player.ship.fuelLeakRate = %@;", [self expandFloatExpression:string]];
}


- (NSString *) convertAction_setSunNovaIn:(NSString *)string
{
	return [NSString stringWithFormat:@"system.sun.goNova(%@);", [self expandFloatExpression:string]];
}


- (NSString *) convertAction_setMissionDescription:(NSString *)string
{
	return [NSString stringWithFormat:@"mission.setInstructionsKey(%@);", [self expandString:string]];
}


- (NSString *) convertAction_clearMissionDescription
{
	return [NSString stringWithFormat:@"mission.setInstructionsKey(null);"];
}


- (NSString *) convertAction_setMissionMusic:(NSString *)string
{
	return [NSString stringWithFormat:@"mission.setMusic(%@);", [self expandString:string]];
}


- (NSString *) convertAction_addMissionDestination:(NSString *)string
{
	/*	expandStringOrNumber: is used because more than one destination can be
		specified, as a space-separated list. mission.markSystem() supports
		this format, as well as comma-separated lists.
	*/
	return [NSString stringWithFormat:@"mission.markSystem(%@);", [self expandStringOrNumber:string]];
}


- (NSString *) convertAction_removeMissionDestination:(NSString *)string
{
	/*	expandStringOrNumber: is used because more than one destination can be
		specified, as a space-separated list. mission.unmarkSystem() supports
		this format, as well as comma-separated lists.
	*/
	return [NSString stringWithFormat:@"mission.unmarkSystem(%@);", [self expandStringOrNumber:string]];
}


- (NSString *) convertAction_addShips:(NSString *)params
{
	NSMutableArray		*tokens = nil;
	NSString			*roleString = nil;
	NSString			*countString = nil;
	
	tokens = ScanTokensFromString(params);
	if ([tokens count] != 2)
	{
		[self addStopIssueWithKey:@"addShips-syntax-error"
						   format:@"Bad syntax for addShips: -- expected role followed by count, got \"%@\".", params];
		return nil;
	}
	
	roleString = [tokens objectAtIndex:0];
	countString = [tokens objectAtIndex:1];
	
	return [NSString stringWithFormat:@"system.legacy_addShips(%@, %@);",
			[self expandString:roleString],
			[self expandIntegerExpression:countString]];
}


- (NSString *) convertAction_addSystemShips:(NSString *)params
{
	NSMutableArray		*tokens = nil;
	NSString			*roleString = nil;
	NSString			*countString = nil;
	NSString			*positionString = nil;
	
	tokens = ScanTokensFromString(params);
	if ([tokens count] != 3)
	{
		[self addStopIssueWithKey:@"addSystemShips-syntax-error"
						   format:@"Bad syntax for addSystemShips: -- expected <role> <count> <position>, got \"%@\".", params];
		return nil;
	}
	
	roleString = [tokens objectAtIndex:0];
	countString = [tokens objectAtIndex:1];
	positionString = [tokens objectAtIndex:2];
	
	return [NSString stringWithFormat:@"system.legacy_addSystemShips(%@, %@, %@);",
			[self expandString:roleString],
			[self expandIntegerExpression:countString],
			[self expandFloatExpression:positionString]];
}


- (NSString *) convertAction_addShipsAt:(NSString *)params
{
	NSMutableArray		*tokens = nil;
	NSString			*roleString = nil;
	NSString			*countString = nil;
	NSString			*systemString = nil;
	NSString			*xString = nil;
	NSString			*yString = nil;
	NSString			*zString = nil;
	
	tokens = ScanTokensFromString(params);
	if ([tokens count] != 6)
	{
		[self addStopIssueWithKey:@"addShipsAt-syntax-error"
						   format:@"Bad syntax for addShipsAt: -- expected <role> <count> <coordinate-system> <x> <y> <z>, got \"%@\".", params];
		return nil;
	}
	
	roleString = [tokens objectAtIndex:0];
	countString = [tokens objectAtIndex:1];
	systemString = [tokens objectAtIndex:2];
	xString = [tokens objectAtIndex:3];
	yString = [tokens objectAtIndex:4];
	zString = [tokens objectAtIndex:5];
	
	return [NSString stringWithFormat:@"system.legacy_addShipsAt(%@, %@, %@, [%@, %@, %@]);",
			[self expandString:roleString],
			[self expandIntegerExpression:countString],
			[self expandString:systemString],
			[self expandFloatExpression:xString],
			[self expandFloatExpression:yString],
			[self expandFloatExpression:zString]];
}


- (NSString *) convertAction_addShipsAtPrecisely:(NSString *)params
{
	NSMutableArray		*tokens = nil;
	NSString			*roleString = nil;
	NSString			*countString = nil;
	NSString			*systemString = nil;
	NSString			*xString = nil;
	NSString			*yString = nil;
	NSString			*zString = nil;
	
	tokens = ScanTokensFromString(params);
	if ([tokens count] != 6)
	{
		[self addStopIssueWithKey:@"addShipsAtPrecisely-syntax-error"
						   format:@"Bad syntax for addShipsAtPrecisely: -- expected <role> <count> <coordinate-system> <x> <y> <z>, got \"%@\".", params];
		return nil;
	}
	
	roleString = [tokens objectAtIndex:0];
	countString = [tokens objectAtIndex:1];
	systemString = [tokens objectAtIndex:2];
	xString = [tokens objectAtIndex:3];
	yString = [tokens objectAtIndex:4];
	zString = [tokens objectAtIndex:5];
	
	return [NSString stringWithFormat:@"system.legacy_addShipsAtPrecisely(%@, %@, %@, [%@, %@, %@]);",
			[self expandString:roleString],
			[self expandIntegerExpression:countString],
			[self expandString:systemString],
			[self expandFloatExpression:xString],
			[self expandFloatExpression:yString],
			[self expandFloatExpression:zString]];
}


- (NSString *) convertAction_addShipsWithinRadius:(NSString *)params
{
	NSMutableArray		*tokens = nil;
	NSString			*roleString = nil;
	NSString			*countString = nil;
	NSString			*systemString = nil;
	NSString			*xString = nil;
	NSString			*yString = nil;
	NSString			*zString = nil;
	NSString			*radiusString = nil;
	
	tokens = ScanTokensFromString(params);
	if ([tokens count] != 7)
	{
		[self addStopIssueWithKey:@"addShipsWithinRadius-syntax-error"
						   format:@"Bad syntax for addShipsWithinRadius: -- expected <role> <count> <coordinate-system> <x> <y> <z> <radius>, got \"%@\".", params];
		return nil;
	}
	
	roleString = [tokens objectAtIndex:0];
	countString = [tokens objectAtIndex:1];
	systemString = [tokens objectAtIndex:2];
	xString = [tokens objectAtIndex:3];
	yString = [tokens objectAtIndex:4];
	zString = [tokens objectAtIndex:5];
	radiusString = [tokens objectAtIndex:6];
	
	return [NSString stringWithFormat:@"system.legacy_addShipsWithinRadius(%@, %@, %@, [%@, %@, %@], %@);",
			[self expandString:roleString],
			[self expandIntegerExpression:countString],
			[self expandString:systemString],
			[self expandFloatExpression:xString],
			[self expandFloatExpression:yString],
			[self expandFloatExpression:zString],
			[self expandFloatExpression:radiusString]];
}


- (NSString *) convertAction_awardCargo:(NSString *)params
{
	NSMutableArray		*tokens = nil;
	NSString			*quantityString = nil;
	NSString			*typeString = nil;
	
	tokens = ScanTokensFromString(params);
	if ([tokens count] != 2)
	{
		[self addStopIssueWithKey:@"awardCargo-syntax-error"
						   format:@"Bad syntax for awardCargo: -- expected count followed by type, got \"%@\".", params];
		return nil;
	}
	
	quantityString = [tokens objectAtIndex:0];
	typeString = [tokens objectAtIndex:1];
	
	if ([quantityString isEqualToString:@"1"])
	{
		return [NSString stringWithFormat:@"player.ship.awardCargo(%@);", [self expandString:typeString]];
	}
	else
	{
		return [NSString stringWithFormat:@"player.ship.awardCargo(%@, %@);", [self expandString:typeString], [self expandIntegerExpression:quantityString]];
	}
}


- (NSString *) convertAction_setPlanetinfo:(NSString *)params
{
	NSArray				*tokens = nil;
	NSString			*keyString = nil;
	NSString			*valueString = nil;
	
	tokens = [params componentsSeparatedByString:@"="];
	if ([tokens count] != 2)
	{
		[self addStopIssueWithKey:@"setPlanetinfo-syntax-error"
						   format:@"Bad syntax for setPlanetinfo: -- expected key=value, got \"%@\".", params];
		return nil;
	}
	
	keyString = [[tokens objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	valueString = [[tokens objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	return [NSString stringWithFormat:@"system.info%@ = %@;", [self expandPropertyReference:keyString], [self expandString:valueString]];
}


- (NSString *) convertAction_setSpecificPlanetInfo:(NSString *)params
{
	NSArray				*tokens = nil;
	NSString			*galaxyString = nil;
	NSString			*systemString = nil;
	NSString			*keyString = nil;
	NSString			*valueString = nil;
	
	tokens = [params componentsSeparatedByString:@"="];
	if ([tokens count] != 4)
	{
		[self addStopIssueWithKey:@"setPlanetinfo-syntax-error"
						   format:@"Bad syntax for setSpecificPlanetInfo: -- expected galaxy=system=key=value, got \"%@\".", params];
		return nil;
	}
	
	galaxyString = [[tokens objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	systemString = [[tokens objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	keyString = [[tokens objectAtIndex:2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	valueString = [[tokens objectAtIndex:3] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	return [NSString stringWithFormat:@"System.infoForSystem(%@, %@)%@ = %@;", [self expandIntegerExpression:galaxyString], [self expandIntegerExpression:systemString], [self expandPropertyReference:keyString], [self expandString:valueString]];
}


- (NSString *) convertAction_sendAllShipsAway
{
	return @"system.sendAllShipsAway();";
}


- (NSString *) convertAction_launchFromStation
{
	return @"player.ship.launch();";
}


- (NSString *) convertAction_blowUpStation
{
	return @"system.mainStation.explode();";
}


- (NSString *) convertAction_removeAllCargo
{
	return @"player.ship.removeAllCargo();";
}


- (NSString *) convertAction_clearMissionScreen
{
	return @"mission.clearMissionScreen();";
}


- (NSString *) convertAction_setGuiToMissionScreen
{
	return @"mission.showMissionScreen();";
}


- (NSString *) convertAction_resetMissionChoice
{
	return @"mission.choice = null;";
}


- (NSString *) convertAction_setGuiToStatusScreen
{
	// FIXME: is this OK in general?
	return @"";
}


- (NSString *) convertAction_debugOn
{
	return @"if (debugConsole)  debugConsole.setDisplayMessagesInClass(\"$scriptDebugOn\", true);";
}


- (NSString *) convertAction_debugOff
{
	return @"if (debugConsole)  debugConsole.setDisplayMessagesInClass(\"$scriptDebugOn\", false);";
}


/*** Query handlers ***/

- (OOJSExprNode *) convertQuery_dockedAtMainStation_bool
{
	/*	player.ship.docked && player.ship.dockedStation == system.mainStation
		(player.ship.docked is required, because player.ship.dockedStation ==
		system.mainStation is true in interstellar space.)
	*/
	return EX_AND(EX_PROP(EX_PROP(@"player", @"ship"), @"docked"), EX_EQUAL(EX_PROP(EX_PROP(@"player", @"ship"), @"dockedStation"), EX_PROP(@"system", @"mainStation")));
}


- (OOJSExprNode *) convertQuery_galaxy_number
{
	return EX_ID(@"galaxyNumber");
}


- (OOJSExprNode *) convertQuery_planet_number
{
	return EX_PROP(@"system", @"ID");
}


- (OOJSExprNode *) convertQuery_score_number
{
	return EX_PROP(@"player", @"score");
}


- (OOJSExprNode *) convertQuery_d100_number
{
	// Math.floor(Math.random() * 256)
	return EX_CALL(EX_PROP(@"Math", @"floor"), EX_MULTIPLY(EX_VOID_CALL(EX_PROP(@"Math", @"random")), EX_INT(100)));
}


- (OOJSExprNode *) convertQuery_d256_number
{
	// Math.floor(Math.random() * 256)
	return EX_CALL(EX_PROP(@"Math", @"floor"), EX_MULTIPLY(EX_VOID_CALL(EX_PROP(@"Math", @"random")), EX_INT(256)));
}


- (OOJSExprNode *) convertQuery_sunWillGoNova_bool
{
	return EX_PROP(EX_PROP(@"system", @"sun"), @"isGoingNova");
}


- (OOJSExprNode *) convertQuery_sunGoneNova_bool
{
	return EX_PROP(EX_PROP(@"system", @"sun"), @"hasGoneNova");
}


- (OOJSExprNode *) convertQuery_status_string
{
	return EX_PROP(EX_PROP(@"player", @"ship"), @"status");
}


- (OOJSExprNode *) convertQuery_shipsFound_number
{
	[self setInitializer:@"this.shipsFound = 0;" forKey:@"shipsFound"];
	return EX_THIS_PROP(@"shipsFound");
}


- (OOJSExprNode *) convertQuery_foundEquipment_bool
{
	[self setInitializer:@"this.foundEqipment = false;" forKey:@"foundEqipment"];
	return EX_THIS_PROP(@"foundEqipment");
}


- (OOJSExprNode *) convertQuery_missionChoice_string
{
	return EX_PROP(@"mission", @"choice");
}


- (OOJSExprNode *) convertQuery_scriptTimer_number
{
	return EX_PROP(@"clock", @"legacy_scriptTimer");
}


- (OOJSExprNode *) convertQuery_gui_screen_string
{
	return EX_ID(@"guiScreen");
}


- (OOJSExprNode *) convertQuery_credits_number
{
	return EX_PROP(@"player", @"credits");
}


- (OOJSExprNode *) convertQuery_dockedStationName_string
{
	/*
		this.dockedStationName = function ()
		{
			if (player.ship.docked)
			{
				var result = player.ship.dockedStation.name;
				if (!result)  result = "UNKNOWN";
					
			}
			else
			{
				var result = "NONE";
			}
			return result;
		}
	*/
	[self setHelperFunction:
			@"function ()\n{\n"
			"\tif (player.ship.docked)\n\t{\n"
			"\t\tvar result = player.ship.dockedStation.name;\n"
			"\t\tif (!result)  result = \"UNKNOWN\";\n"
			"\t}\n\telse\n\t{\n"
			"\t\tvar result = \"NONE\";\n\t}\n"
			"\treturn result;\n}"
		forKey:@"dockedStationName"];
	
	return EX_VOID_CALL(EX_THIS_PROP(@"dockedStationName"));
}


- (OOJSExprNode *) convertQuery_systemGovernment_string
{
	return EX_PROP(@"system", @"governmentDescription");
}


- (OOJSExprNode *) convertQuery_systemGovernment_number
{
	return EX_PROP(@"system", @"government");
}


- (OOJSExprNode *) convertQuery_systemEconomy_string
{
	return EX_PROP(@"system", @"economyDescription");
}


- (OOJSExprNode *) convertQuery_systemEconomy_number
{
	return EX_PROP(@"system", @"economy");
}


- (OOJSExprNode *) convertQuery_systemTechLevel_number
{
	return EX_PROP(@"system", @"techLevel");
}


- (OOJSExprNode *) convertQuery_systemPopulation_number
{
	return EX_PROP(@"system", @"population");
}


- (OOJSExprNode *) convertQuery_systemProductivity_number
{
	return EX_PROP(@"system", @"productivity");
}


- (OOJSExprNode *) convertQuery_commanderName_string
{
	return EX_PROP(@"player", @"name");
}


- (OOJSExprNode *) convertQuery_commanderRank_string
{
	return EX_PROP(@"player", @"rank");
}


- (OOJSExprNode *) convertQuery_commanderShip_string
{
	return EX_PROP(EX_PROP(@"player", @"ship"), @"name");
}


- (OOJSExprNode *) convertQuery_commanderShipDisplayName_string
{
	return EX_PROP(EX_PROP(@"player", @"ship"), @"displayName");
}



- (OOJSExprNode *) convertQuery_commanderLegalStatus_string
{
	return EX_PROP(@"player", @"legalStatus");
}


- (OOJSExprNode *) convertQuery_commanderLegalStatus_number
{
	return EX_PROP(@"player", @"bounty");
}


- (OOJSExprNode *) convertQuery_legalStatus_number
{
	return EX_PROP(@"player", @"bounty");
}


- (OOJSExprNode *) convertQuery_pseudoFixedD100_number
{
	return EX_PROP(@"system", @"psuedoRandom100");
}


- (OOJSExprNode *) convertQuery_pseudoFixedD256_number
{
	return EX_PROP(@"system", @"psuedoRandom256");
}

@end


static NSMutableArray *ScanTokensFromString(NSString *values)
{
	NSMutableArray			*result = nil;
	NSScanner				*scanner = nil;
	NSString				*token = nil;
	static NSCharacterSet	*space_set = nil;
	
	if (values == nil)  return [NSArray array];
	if (space_set == nil) space_set = [[NSCharacterSet whitespaceAndNewlineCharacterSet] retain];
	
	result = [NSMutableArray array];
	scanner = [NSScanner scannerWithString:values];
	
	while (![scanner isAtEnd])
	{
		[scanner ooliteScanCharactersFromSet:space_set intoString:NULL];
		if ([scanner ooliteScanUpToCharactersFromSet:space_set intoString:&token])
		{
			[result addObject:token];
		}
	}
	
	return result;
}

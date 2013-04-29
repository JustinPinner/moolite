/*	OOJSExprNode.h
	
	Classes for representing JavaScript expressions as an abstract syntax tree.
	General notes:
	  * All OOJSExprNodes are immutable.
	  * OOJSExprNode can be compared using isEqual:.
	  * No guarantees are given as to the pointer-equality of equivalent nodes;
		that is, internal caching is permitted but not guranteed.
	
	See also: OOJSExprNodeHelpers.h.
*/

#import "OOCocoa.h"


// Empty any internal node cache.
void OOJSExprClearCache(void);


// Abstract classes
@interface OOJSExprNode: NSObject <NSCopying>

// Calls jsCodeRepresentation, and parenthesizes it if precedence is lower than jsCodeRepresentation.
- (NSString *) jsCodeRepresentationForPrecedence:(uint8_t)parentPrecedence;

// Subclass responsibilities
- (NSString *) jsCodeRepresentation;
- (uint8_t) precedence;

- (OOUInteger) shallowHash;	// Hash without evaluating subnode hashes.
- (OOUInteger) hash;		// Default: calls shallowHash.

@end


@interface OOJSExprNode (Conveniences)

- (BOOL) isIntLiteral;
- (BOOL) isDoubleLiteral;
- (BOOL) isNumberLiteral;
- (BOOL) isBooleanLiteral;
- (BOOL) isStringLiteral;
- (BOOL) isIdentifier;
- (BOOL) isOperator;
- (BOOL) isBinaryOperator;

@end


@interface OOJSOperatorExprNode: OOJSExprNode

/*	Subclass responsibility - used for comparisons and for default rendering
	of binary ops. Except for binary ops using this feature, the token is not
	required to be valid code but is required to be unique per operator.
*/
- (NSString *) operatorToken;

@end


@interface OOJSUnaryOperatorExprNode: OOJSOperatorExprNode
{
@private
	OOJSExprNode		*_subExpr;
}

+ (id) nodeWithSubExpression:(OOJSExprNode *)subExpression;

- (OOJSExprNode *) subExpression;

- (NSString *) subExpressionJSCode;

@end


@interface OOJSBinaryOperatorExprNode: OOJSOperatorExprNode
{
@private
	OOJSExprNode		*_lhs;
	OOJSExprNode		*_rhs;
}

+ (id) nodeWithLeftHandSide:(OOJSExprNode *)lhsExpression rightHandSide:(OOJSExprNode *)rhsExpression;

- (OOJSExprNode *) leftHandSideExpression;
- (OOJSExprNode *) rightHandSideExpression;

- (NSString *) leftHandSideJSCode;
- (NSString *) rightHandSideJSCode;

// Default: false.
- (BOOL) rightAssociative;

@end


// Literals (precedence 0)
@interface OOJSIntLiteralExprNode: OOJSExprNode
{
@private
	int64_t				_value;
}

+ (id) nodeWithIntValue:(int64_t)value;

- (int64_t) int64Value;

@end


@interface OOJSDoubleLiteralExprNode: OOJSExprNode
{
@private
	double				_value;
}

+ (id) nodeWithDoubleValue:(double)value;

- (double) doubleValue;

@end


@interface OOJSBoolLiteralExprNode: OOJSExprNode
{
@private
	BOOL				_value;
}

+ (id) nodeWithBoolValue:(BOOL)value;

- (BOOL) boolValue;

@end


@interface OOJSStringLiteralExprNode: OOJSExprNode
{
@private
	NSString			*_value;
	NSString			*_escaped;
}

+ (id) nodeWithStringValue:(NSString *)value;

- (NSString *) stringValue;
- (NSString *) escapedStringValue;

@end


@interface OOJSIdentifierExprNode: OOJSExprNode
{
@private
	NSString			*_value;
}

// NOTE: returns nil if passed a non-identifier string.
+ (id) nodeWithIdentifier:(NSString *)value;

- (NSString *) identifier;

@end


// Precedence 1 operators
@interface OOJSPropertyAccessExprNode: OOJSOperatorExprNode
{
@private
	OOJSExprNode		*_object;
	OOJSExprNode		*_property;
	BOOL				_isDot;
}

/*	An OOJSPropertyAccessExprNode represents either an object[property]
	expression or an object.property expression. If the propertyExpression
	is an identifier, the . operator is used. If the propertyExpression is
	a string literal whose value qualifies as an identifier (and isn't a
	keyword), it is replaced with the corresponding identifier and the .
	operator is used. Otherwise, the [] operator is used.
	
	As a convenience, NSStrings may be passed instead of expressions. For
	objectExpression, the string must be a valid identifier.
 */
+ (id) nodeWithObject:(id)objectExpression property:(id)propertyExpression;

- (OOJSExprNode *) objectExpression;
- (OOJSExprNode *) propertyExpression;

@end


@interface OOJSNewOpExprNode: OOJSUnaryOperatorExprNode
@end


// Precendence 2 operator
@interface OOJSFunctionCallExprNode: OOJSOperatorExprNode
{
@private
	OOJSExprNode		*_function;
	NSArray				*_arguments;
}

// functionExpression may be NSString or OOJSExprNode.
+ (id) nodeWithFunction:(id)functionExpression arguments:(NSArray *)arguments;

- (OOJSExprNode *) functionExpression;
- (NSArray *) arguments;

@end


// Precedence 3 operators
@interface OOJSPostfixIncrementOpExprNode: OOJSUnaryOperatorExprNode
@end


@interface OOJSPostfixDecrementOpExprNode: OOJSUnaryOperatorExprNode
@end


// Precedence 4 operators
@interface OOJSPrefixIncrementOpExprNode: OOJSUnaryOperatorExprNode
@end


@interface OOJSPrefixDecrementOpExprNode: OOJSUnaryOperatorExprNode
@end


@interface OOJSDeleteOpExprNode: OOJSUnaryOperatorExprNode
@end


@interface OOJSVoidOpExprNode: OOJSUnaryOperatorExprNode
@end


@interface OOJSTypeofOpExprNode: OOJSUnaryOperatorExprNode
@end


@interface OOJSUnaryPlusOpExprNode: OOJSUnaryOperatorExprNode
@end


@interface OOJSUnaryMinusOpExprNode: OOJSUnaryOperatorExprNode
@end


@interface OOJSBitwiseNotOpExprNode: OOJSUnaryOperatorExprNode
@end


@interface OOJSLogicalNotOpExprNode: OOJSUnaryOperatorExprNode
@end


// Precedence 5 operators
@interface OOJSMultiplyOpExprNode: OOJSBinaryOperatorExprNode
@end


@interface OOJSDivideOpExprNode: OOJSBinaryOperatorExprNode
@end


@interface OOJSRemainderOpExprNode: OOJSBinaryOperatorExprNode
@end


// Precedence 6 operators
@interface OOJSAddOpExprNode: OOJSBinaryOperatorExprNode
@end


@interface OOJSSubtractOpExprNode: OOJSBinaryOperatorExprNode
@end


// Precedence 7 operators
@interface OOJSLeftShiftOpExprNode: OOJSBinaryOperatorExprNode
@end


@interface OOJSRightShiftOpExprNode: OOJSBinaryOperatorExprNode
@end


@interface OOJSUnsignedRightShiftOpExprNode: OOJSBinaryOperatorExprNode
@end


// Precedence 8 operators
@interface OOJSLessThanOpExprNode: OOJSBinaryOperatorExprNode
@end


@interface OOJSGreaterThanOpExprNode: OOJSBinaryOperatorExprNode
@end


@interface OOJSLessThanOrEqualOpExprNode: OOJSBinaryOperatorExprNode
@end


@interface OOJSGreaterThanOrEqualOpExprNode: OOJSBinaryOperatorExprNode
@end


@interface OOJSInstanceOfOpExprNode: OOJSBinaryOperatorExprNode
@end


@interface OOJSInOpExprNode: OOJSBinaryOperatorExprNode
@end


// Precedence 9 operators
@interface OOJSEqualOpExprNode: OOJSBinaryOperatorExprNode
@end


@interface OOJSNotEqualOpExprNode: OOJSBinaryOperatorExprNode
@end


@interface OOJSStrictlyEqualOpExprNode: OOJSBinaryOperatorExprNode
@end


@interface OOJSNotStrictlyEqualOpExprNode: OOJSBinaryOperatorExprNode
@end


// Precedence 10 operator
@interface OOJSBitwiseAndExprNode: OOJSBinaryOperatorExprNode
@end


// Precedence 11 operator
@interface OOJSBitwiseXorExprNode: OOJSBinaryOperatorExprNode
@end


// Precedence 12 operator
@interface OOJSBitwiseOrExprNode: OOJSBinaryOperatorExprNode
@end


// Precedence 13 operator
@interface OOJSLogicalAndExprNode: OOJSBinaryOperatorExprNode
@end


// Precedence 14 operator
@interface OOJSLogicalOrExprNode: OOJSBinaryOperatorExprNode
@end


// Precedence 15 operator
@interface OOJSConditionalExprNode: OOJSOperatorExprNode
{
@private
	OOJSExprNode		*_condition;
	OOJSExprNode		*_trueExpr;
	OOJSExprNode		*_falseExpr;
}

+ (id) nodeWithCondition:(OOJSExprNode *)condition
		  trueExpression:(OOJSExprNode *)trueExpression
		 falseExpression:(OOJSExprNode *)falseExpression;

- (OOJSExprNode *) conditionExpression;
- (OOJSExprNode *) trueExpression;
- (OOJSExprNode *) falseExpression;

- (NSString *) conditionJSCode;
- (NSString *) trueExpressionJSCode;
- (NSString *) falseExpressionJSCode;

@end


// Precedence 16 operators
@interface OOJSAssignExprNode: OOJSBinaryOperatorExprNode
@end

@interface OOJSMultiplyAssignExprNode: OOJSAssignExprNode
@end

@interface OOJSDivideAssignExprNode: OOJSAssignExprNode
@end

@interface OOJSRemainderAssignExprNode: OOJSAssignExprNode
@end

@interface OOJSAddAssignExprNode: OOJSAssignExprNode
@end

@interface OOJSSubtractAssignExprNode: OOJSAssignExprNode
@end

@interface OOJSLeftShiftAssignExprNode: OOJSAssignExprNode
@end

@interface OOJSRightShiftAssignExprNode: OOJSAssignExprNode
@end

@interface OOJSUnsignedRightShiftAssignExprNode: OOJSAssignExprNode
@end

@interface OOJSBitwiseAndAssignExprNode: OOJSAssignExprNode
@end

@interface OOJSBitwiseXorAssignExprNode: OOJSAssignExprNode
@end

@interface OOJSBitwiseOrAssignExprNode: OOJSAssignExprNode
@end


// Precedence 17 operator
@interface OOJSSequentialEvaluationExprNode: OOJSBinaryOperatorExprNode
@end


// Marker for errors
@interface OOJSErrorExprNode: OOJSExprNode
{
@private
	NSString			*_message;
}

+ (id) nodeWithMessage:(NSString *)message;

- (NSString *)message;

@end

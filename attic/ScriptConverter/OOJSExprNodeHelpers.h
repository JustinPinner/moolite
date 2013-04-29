#import "OOJSExprNode.h"
#import "OOFunctionAttributes.h"


// Tokens
// Identifier
#define EX_ID(x)				[OOJSIdentifierExprNode nodeWithIdentifier:(x)]
// String
#define EX_STR(x)				[OOJSStringLiteralExprNode nodeWithStringValue:(x)]
// Integer
#define EX_INT(x)				[OOJSIntLiteralExprNode nodeWithIntValue:(x)]
// Double
#define EX_DOUBLE(x)			[OOJSDoubleLiteralExprNode nodeWithDoubleValue:(x)]

// Returns int or double literal, or nil if invalid.
OOJSExprNode *OOJSExprNumberFromLiteral(NSString *literal);

// Keywords
// true
#define EX_TRUE					[OOJSBoolLiteralExprNode nodeWithBoolValue:YES]
// false
#define EX_FALSE				[OOJSBoolLiteralExprNode nodeWithBoolValue:NO]
// undefined
#define EX_UNDEFINED			EX_ID(@"undefined")
// null
#define EX_NULL					EX_ID(@"null")

// Precedence 1 operators
// x.y or x[y]
#define EX_PROP(x, y)			[OOJSPropertyAccessExprNode nodeWithObject:(x) property:(y)]
#define EX_THIS_PROP(y)			[OOJSPropertyAccessExprNode nodeWithObject:@"this" property:(y)]
// new x
#define EX_NEW(x)				[OOJSNewOpExprNode nodeWithSubExpression:(x)]

// Precedence 2 operator
// f(...)
#define EX_CALL(f, ...)			[OOJSFunctionCallExprNode nodeWithFunction:(f) arguments:[NSArray arrayWithObjects: __VA_ARGS__, nil]]
// f()
#define EX_VOID_CALL(f)			[OOJSFunctionCallExprNode nodeWithFunction:(f) arguments:nil]

// Precedence 3 operators
// x++
#define EX_POST_INCR(x)			[OOJSPostfixIncrementOpExprNode nodeWithSubExpression:(x)]
// x--
#define EX_POST_DECR(x)			[OOJSPostfixDecrementOpExprNode nodeWithSubExpression:(x)]

// Precedence 4 operators
// ++x
#define EX_PRE_INCR(x)			[OOJSPrefixIncrementOpExprNode nodeWithSubExpression:(x)]
// --x
#define EX_PRE_DECR(x)			[OOJSPrefixDecrementOpExprNode nodeWithSubExpression:(x)]
// delete x
#define EX_DELETE(x)			[OOJSDeleteOpExprNode nodeWithSubExpression:(x)]
// void x
#define EX_VOID(x)				[OOJSVoidOpExprNode nodeWithSubExpression:(x)]
// typeof x
#define EX_TYPEOF(x)			[OOJSTypeofOpExprNode nodeWithSubExpression:(x)]
// +x
#define EX_UNRY_PLUS(x)			[OOJSUnaryPlusOpExprNode nodeWithSubExpression:(x)]
// -x
#define EX_UNRY_MINUS(x)		[OOJSUnaryMinusOpExprNode nodeWithSubExpression:(x)]
// ~x
#define EX_BITNOT(x)			[OOJSBitwiseNotOpExprNode nodeWithSubExpression:(x)]
// !x
#define EX_NOT(x)				[OOJSLogicalNotOpExprNode nodeWithSubExpression:(x)]

// Precedence 5 operators
// x * y
#define EX_MULTIPLY(x, y)		[OOJSMultiplyOpExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]
// x / y
#define EX_DIVIDE(x, y)			[OOJSDivideOpExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]
// x % y
#define EX_REMAINDER(x, y)		[OOJSRemainderOpExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]

// Precedence 6 operators
// x + y
#define EX_ADD(x, y)			[OOJSAddOpExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]
// x - y
#define EX_SUBTRACT(x, y)		[OOJSSubtractOpExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]

// Precedence 7 operators
// x << y
#define EX_SH_LEFT(x, y)		[OOJSLeftShiftOpExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]
// x >> y
#define EX_SH_RIGHT(x, y)		[OOJSRightShiftOpExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]
// x >>> y
#define EX_SH_RIGHT_U(x, y)		[OOJSUnsignedRightShiftOpExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]

// Precedence 8 operators
// x < y
#define EX_LESS(x, y)			[OOJSLessThanOpExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]
// x > y
#define EX_GRTR(x, y)			[OOJSGreaterThanOpExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]
// x <= y
#define EX_LESS_EQ(x, y)		[OOJSLessThanOrEqualOpExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]
// x >= y
#define EX_GRTR_EQ(x, y)		[OOJSGreaterThanOrEqualOpExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]
// x instanceof y
#define EX_INSTANCEOF(x, y)		[OOJSInstanceOfOpExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]
// x in y
#define EX_IN(x, y)				[OOJSInOpExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]

// Precedence 9 operators
// x == y
#define EX_EQUAL(x, y)			[OOJSEqualOpExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]
// x != y
#define EX_NOT_EQUAL(x, y)		[OOJSNotEqualOpExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]
// x === y
#define EX_STRICT_EQUAL(x, y)	[OOJSStrictlyEqualOpExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]
// x !== y
#define EX_NOT_STRICT_EQUAL(x, y) [OOJSNotStrictlyEqualOpExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]

// Precedence 10 operator
// x & y
#define EX_BITAND(x, y)			[OOJSBitwiseAndExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]

// Precedence 11 operator
// x ^ y
#define EX_BITXOR(x, y)			[OOJSBitwiseXorExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]

// Precedence 12 operator
// x | y
#define EX_BITOR(x, y)			[OOJSBitwiseOrExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]

// Precedence 13 operator
// x && y
#define EX_AND(x, y)			[OOJSLogicalAndExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]

// Precedence 14 operator
// x || y
#define EX_OR(x, y)				[OOJSLogicalOrExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]

// Precedence 15 operator
// x ? y : z
#define EX_CONDTIONAL(x, y, z)	[OOJSConditionalExprNode nodeWithCondition:(x) trueExpression:(y) falseExpression:(z)]

// Precedence 16 operators
// x = y
#define EX_ASSIGN(x, y)			[OOJSAssignExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]
// x *= y
#define EX_MULTIPLY_ASGN(x, y)	[OOJSMultiplyAssignExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]
// x /= y
#define EX_DIVIDE_ASGN(x, y)	[OOJSDivideAssignExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]
// x %= y
#define EX_REMAINDER_ASGN(x, y)	[OOJSRemainderAssignExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]
// x += y
#define EX_ADD_ASGN(x, y)		[OOJSAddAssignExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]
// x -= y
#define EX__SUBTRACT_ASGN(x, y)	[OOJSSubtractAssignExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]
// x <<= y
#define EX_SH_LEFT_ASGN(x, y)	[OOJSLeftShiftAssignExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]
// x >>= y
#define EX_SH_RIGHT_ASGN(x, y)	[OOJSRightShiftAssignExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]
// x >>>= y
#define EX_SH_RIGHT_U_ASGN(x, y) [OOJSUnsignedRightShiftAssignExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]
// x &= y
#define EX_BITAND_ASGN(x, y)	[OOJSBitwiseAndAssignExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]
// x ^= y
#define EX_BITXOR_ASGN(x, y)	[OOJSBitwiseXorAssignExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]
// x |= y
#define EX_BITOR_ASGN(x, y)		[OOJSBitwiseOrAssignExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]


// Precedence 17 operator
// x, y
#define EX_COMMA(x, y)			[OOJSSequentialEvaluationExprNode nodeWithLeftHandSide:(x) rightHandSide:(y)]


// Inline error message
#define EX_ERROR(x)				[OOJSErrorExprNode nodeWithMessage:(x)]
#define EX_ERROR_FMT(x, ...)	[OOJSErrorExprNode nodeWithMessage:[NSString stringWithFormat:(x), __VA_ARGS__]]

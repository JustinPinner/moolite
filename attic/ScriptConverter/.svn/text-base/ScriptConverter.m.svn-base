#import <Foundation/Foundation.h>
#import <stdlib.h>
#import "OOLegacyScriptToJavaScriptConverter.h"
#import "OOLogging.h"
#import "OOJSExprNodeHelpers.h"
#import "OOJSExprNode+Graphviz.h"


@interface SimpleProblemReporter: NSObject <OOProblemReportManager>
{
	OOProblemSeverity			_highest;
}
@end


static void TestExprNode();


int main (int argc, const char * argv[])
{
	NSString				*path = nil;
	NSDictionary			*scripts = nil;
	SimpleProblemReporter	*problemReporter = nil;
	NSDictionary			*result = nil;
	NSEnumerator			*scriptEnum = nil;
	NSString				*name = nil;
	
	[[NSAutoreleasePool alloc] init];
	
	if (0)  TestExprNode();
	
	if (argc < 2)
	{
		printf("No file specified.\n");
		return EXIT_FAILURE;
	}
	
	path = [[NSString stringWithUTF8String:argv[1]] stringByStandardizingPath];
	scripts = [NSDictionary dictionaryWithContentsOfFile:path];
	if (scripts == nil)
	{
		printf("Could not open file %s.\n", [path UTF8String]);
		return EXIT_FAILURE;
	}
	
	problemReporter = [[[SimpleProblemReporter alloc] init] autorelease];
	
	result = [OOLegacyScriptToJavaScriptConverter convertMultipleScripts:scripts
																metadata:nil
														 problemReporter:problemReporter];
	
	if (result != nil)
	{
		for (scriptEnum = [result keyEnumerator]; (name = [scriptEnum nextObject]); )
		{
			printf("%s.js:\n\n%s\n-----\n", [name UTF8String], [[result objectForKey:name] UTF8String]);
		}
		return EXIT_SUCCESS;
	}
	else
	{
		printf("Conversion failed.\n");
		return EXIT_FAILURE;
	}
}


@implementation SimpleProblemReporter

- (void) addIssueWithSeverity:(OOProblemSeverity)severity key:(NSString *)key description:(NSString *)description
{
	if (_highest < severity)  _highest = severity;
	
	static const char * const prefixes[] = { "Note", "Note", "Warning", "Unknown selector", "Error", "Bug" };
	if (severity > kOOProblemSeverityBug)  severity = kOOProblemSeverityBug;
	const char *prefix = prefixes[severity];
	
	printf("%s: %s\n", prefix, [description UTF8String]);
}

- (OOProblemSeverity) highestSeverity
{
	return _highest;
}

@end


void OOLogGenericSubclassResponsibilityForFunction(const char *inFunction)
{
	fprintf(stderr, "%s is a subclass responsibility.\n", inFunction);
	abort();
}


#undef NSLog
static void TestExprNode()
{
	OOJSExprNode *node, *x;
	
	x = EX_ID(@"x");
	
	// ~(x--) == ~x--
	node = EX_BITNOT(EX_POST_DECR(x));
	NSLog(@"%@", [node jsCodeRepresentation]);
	
	// (~x)-- (nonsense, just for comparison)
	node = EX_POST_DECR(EX_BITNOT(x));
	NSLog(@"%@", [node jsCodeRepresentation]);
	
	// (~x)-- * y
	node = EX_MULTIPLY(node, EX_ID(@"y"));
	NSLog(@"%@", [node jsCodeRepresentation]);
	
	//x.y["a property"]
	node = EX_PROP(EX_PROP(x, @"y"), @"a property");
	NSLog(@"%@", [node jsCodeRepresentation]);
	
	// value == undefined || value == null
	x = EX_ID(@"value");
	node = EX_OR(EX_EQUAL(x, EX_UNDEFINED), EX_EQUAL(x, EX_NULL));
	NSLog(@"%@", [node jsCodeRepresentation]);
	
	// ((5 + 3) * 5 + 3) ? true : "\tbananas!"
	node = EX_ADD(EX_MULTIPLY(EX_ADD(EX_INT(5), EX_INT(3)), EX_INT(5)), EX_INT(3));
	node = EX_CONDTIONAL(node, EX_TRUE, EX_STR(@"\tbananas!"));
	NSLog(@"%@", [node jsCodeRepresentation]);
	
	node = EX_CALL(EX_PROP(@"foo", @"bar"), node, EX_INT(42), EX_ADD(EX_INT(1), EX_INT(1)));
	NSLog(@"%@", [node jsCodeRepresentation]);
	
	node = EX_CALL(EX_PROP(@"Math", @"floor"), EX_MULTIPLY(EX_VOID_CALL(EX_PROP(@"Math", @"random")), EX_INT(256)));
	NSLog(@"%@", [node jsCodeRepresentation]);
	
	// (1 - 2) + 3 == 1 - 2 + 3
	node = EX_ADD(EX_SUBTRACT(EX_INT(1), EX_INT(2)), EX_INT(3));
	NSLog(@"%@", [node jsCodeRepresentation]);
	
	// 1 - (2 + 3) (the interesting bit is that - and + have same precedence)
	node = EX_SUBTRACT(EX_INT(1), EX_ADD(EX_INT(2), EX_INT(3)));
	NSLog(@"%@", [node jsCodeRepresentation]);
}

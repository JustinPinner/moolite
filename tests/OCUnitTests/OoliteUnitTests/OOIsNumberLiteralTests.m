#import "OOIsNumberLiteralTests.h"
#import "OOIsNumberLiteral.h"


#define COUNT(x)	(sizeof x / sizeof *x)


@implementation OOIsNumberLiteralTests

- (void) testValidLiterals
{
	NSString *testStrings[] =
	{
		@"0",
		@"1",
		@"-1",
		@"0.1",
		@"-0.1",
		@"1e1",
		@"1e10",
		@"1e-10",
		@"-1e10",
		@"-1e-10",
		@"0.01E3"
	};
	
	for (size_t i = 0; i < COUNT(testStrings); i++)
	{
		STAssertTrue(OOIsNumberLiteral(testStrings[i], NO), @"String \"%@\" should be considered a number literal (without allowing for spaces).", testStrings[i]);
	}
}


- (void) testValidWithSpaceLiterals
{
	NSString *testStrings[] =
	{
		@"  1e1",
		@"1e1  ",
		@"  1e1  "
	};
	
	for (size_t i = 0; i < COUNT(testStrings); i++)
	{
		STAssertTrue(OOIsNumberLiteral(testStrings[i], YES), @"String \"%@\" should be considered a number literal (when allowing for spaces).", testStrings[i]);
		STAssertFalse(OOIsNumberLiteral(testStrings[i], NO), @"String \"%@\" should not be considered a number literal (without allowing for spaces).", testStrings[i]);
	}
}


- (void) testInvalidLiterals
{
	NSString *testStrings[] =
	{
		@"1 2",
		@"a",
		@"1a",
		@"1e",
		nil,
		@"",
		@" "
	};
	
	for (size_t i = 0; i < COUNT(testStrings); i++)
	{
		STAssertFalse(OOIsNumberLiteral(testStrings[i], YES), @"String \"%@\" should not be considered a number literal.", testStrings[i]);
	}
}

@end

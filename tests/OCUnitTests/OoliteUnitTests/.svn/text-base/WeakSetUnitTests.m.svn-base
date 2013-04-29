/*

weakSetUnitTests.m

Unit tests for OOWeakSet.


Written by Jens Ayton in 2012 for Oolite.
This code is hereby placed in the public domain.

*/

#import "weaksetUnitTests.h"
#import "OOWeakSet.h"
#import "OOWeakTestObject.h"


@implementation weaksetUnitTests

- (void) testAddAndCount
{
    OOWeakTestObject *three = [OOWeakTestObject objectWithValue:3];
    OOWeakTestObject *seven = [OOWeakTestObject objectWithValue:7];
	
	OOWeakSet *ws = [OOWeakSet set];
	STAssertNotNil(ws, @"Creating a weak set should produce a set.");
	
	STAssertEquals(ws.count, (NSUInteger)0, @"A newly created weak set should be empty.");
	
	[ws addObject:three];
	[ws addObject:seven];
	
	STAssertEquals(ws.count, (NSUInteger)2, @"After adding two distinct objects, weak set's count should be 2.");
	
	[ws addObject:three];
	[ws addObject:three];
	
	STAssertEquals(ws.count, (NSUInteger)2, @"Adding duplicate objects should not increase weak set's count.");
}


- (void) testContainsObject
{
    OOWeakTestObject *three = [OOWeakTestObject objectWithValue:3];
    OOWeakTestObject *seven = [OOWeakTestObject objectWithValue:7];
	OOWeakSet *ws = [OOWeakSet set];
	
	[ws addObject:three];
	
	STAssertTrue([ws containsObject:three], @"Weak set should contain object that was added.");
	STAssertFalse([ws containsObject:seven], @"Weak set should not contain object that wasn't added.");
}


- (void) testRemoveObject
{
    OOWeakTestObject *three = [OOWeakTestObject objectWithValue:3];
    OOWeakTestObject *seven = [OOWeakTestObject objectWithValue:7];
	OOWeakSet *ws = [OOWeakSet set];
	
	[ws addObject:three];
	[ws addObject:seven];
	
	STAssertEquals(ws.count, (NSUInteger)2, @"After adding two distinct objects, weak set's count should be 2.");
	
	STAssertTrue([ws containsObject:three], @"Weak set should contain object that was added.");
	STAssertTrue([ws containsObject:seven], @"Weak set should contain object that was added.");
	
	[ws removeObject:three];
	
	STAssertEquals(ws.count, (NSUInteger)1, @"After adding two distinct objects and removing one, weak set's count should be 1.");
	
	STAssertFalse([ws containsObject:three], @"Weak set should not contain object that was removed.");
	STAssertTrue([ws containsObject:seven], @"Weak set should contain object that was not removed.");
}


- (void) testEquality
{
    OOWeakTestObject *three = [OOWeakTestObject objectWithValue:3];
    OOWeakTestObject *seven = [OOWeakTestObject objectWithValue:7];
	OOWeakSet *ws1 = [OOWeakSet set];
	OOWeakSet *ws2 = [OOWeakSet set];
	
	STAssertTrue([ws1 isEqual:ws2], @"Two empty weak sets should be equal.");
	
	[ws1 addObject:three];
	[ws2 addObject:seven];
	STAssertFalse([ws1 isEqual:ws2], @"Two weak sets containing different objects should not be equal.");
	
	[ws2 addObject:three];
	[ws1 addObject:seven];
	
	STAssertTrue([ws1 isEqual:ws2], @"Two weak sets containing the same objects should be equal.");
}


- (void) testWeakness
{
    OOWeakTestObject *three = [OOWeakTestObject objectWithValue:3];
	OOWeakSet *ws = [OOWeakSet set];
	
	@autoreleasepool
	{
		OOWeakTestObject *seven = [OOWeakTestObject objectWithValue:7];
		
		[ws addObject:three];
		[ws addObject:seven];
		
		STAssertEquals(ws.count, (NSUInteger)2, @"After adding two distinct objects, weak set's count should be 2.");
	}
	
	STAssertEquals(ws.count, (NSUInteger)1, @"After one object's lifetime expired, weak set's count should be 1.");
	STAssertTrue([ws containsObject:three], @"Weak set should contain object which has not expired.");
}


- (void) testPerformSelector
{
    OOWeakTestObject *three = [OOWeakTestObject objectWithValue:3];
    OOWeakTestObject *seven = [OOWeakTestObject objectWithValue:7];
    OOWeakTestObject *nine = [OOWeakTestObject objectWithValue:9];
	OOWeakSet *ws = [OOWeakSet set];
	
	[ws addObject:three];
	[ws addObject:seven];
	
	NSMutableSet *set = [NSMutableSet set];
	
	[ws makeObjectsPerformSelector:@selector(addSelfToSet:) withObject:set];
	
	STAssertEquals(set.count, ws.count, @"After after having objects from weak set add themselves to a strong set, the two sets' counts should match.");
	STAssertTrue([set containsObject:three], @"Strong set should contain object copied from weak set.");
	STAssertTrue([set containsObject:seven], @"Strong set should contain object copied from weak set.");
	
	[ws addObject:nine];
	
	STAssertFalse([set containsObject:nine], @"Strong set should not contain object not copied from weak set.");
}

@end

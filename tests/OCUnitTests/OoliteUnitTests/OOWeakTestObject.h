/*

OOWeakTestObject.h

A simple object which implements OOWeakReferenceSupport for use in testing.


Written by Jens Ayton in 2012 for Oolite.
This code is hereby placed in the public domain.

*/

#import "OOWeakReference.h"

@interface OOWeakTestObject: OOWeakRefObject
{
@private
	NSUInteger			_value;
}

- (id) initWithValue:(NSUInteger)value;
+ (instancetype) objectWithValue:(NSUInteger)value;

@property (readonly) NSUInteger value;

// For testing makeObjectsPerformSelector:withObject:.
- (void) addSelfToSet:(NSMutableSet *)set;

@end

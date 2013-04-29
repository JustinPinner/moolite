#import "OOWeakTestObject.h"


@implementation OOWeakTestObject

@synthesize value = _value;


- (id) initWithValue:(NSUInteger)value
{
	if ((self = [super init]))
	{
		_value = value;
	}
	return self;
}


- (NSString *) description
{
	return [NSString stringWithFormat:@"<%@ %p>{%lu}", [self class], self, (unsigned long)[self value]];
}


+ (instancetype) objectWithValue:(NSUInteger)value;
{
	return [[[self alloc] initWithValue:value] autorelease];
}


- (void) addSelfToSet:(NSMutableSet *)set
{
	[set addObject:self];
}

@end

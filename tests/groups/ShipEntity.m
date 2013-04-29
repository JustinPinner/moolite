#import "ShipEntity.h"


@implementation ShipEntity

- (id) initWithName:(NSString *)name
{
	if ((self = [super init]))
	{
		_name = [name retain];
	}
	return self;
}


- (NSString *) description
{
	return _name;
}


- (void) dealloc
{
	NSLog(@"%@ iz ded.", self);
	[_name release];
	
	[super dealloc];
}


- (BOOL) isEqual:(id)other
{
	if (![other isKindOfClass:[ShipEntity class]])  return NO;
	
	return [[other description] isEqual:_name];
}

@end

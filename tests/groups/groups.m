#define OOLOG_NO_HIJACK_NSLOG 1

#import "OOCocoa.h"
#import "OOShipGroup.h"
#import "ShipEntity.h"


static void LogGroup(OOShipGroup *group);


int main (int argc, const char * argv[])
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	ShipEntity		*a = [[ShipEntity alloc] initWithName:@"A"];
	ShipEntity		*b = [[ShipEntity alloc] initWithName:@"B"];
	ShipEntity		*c = [[ShipEntity alloc] initWithName:@"C"];
	
	OOShipGroup		*testGroup = [[OOShipGroup alloc] initWithName:@"test group"];
	
	// Test basic adding, removing and auto-removing of stale references.
	[testGroup addShip:a];
	[testGroup addShip:b];
	[testGroup addShip:c];
	
	LogGroup(testGroup);
	NSLog(@"Removing A.");
	[testGroup removeShip:a];
	LogGroup(testGroup);
	NSLog(@"Releasing C.");
	[c release];
	LogGroup(testGroup);
	NSLog(@"Releasing A.");
	[a release];
	LogGroup(testGroup);
	
	NSLog(@"Releasing group.");
	[testGroup release];
	
	NSLog(@"Releasing B.");
	[b release];
	
	// Test growing and shrinking.
	unsigned i;
	for (i = 0; i < 300; i++)
	{
		ShipEntity *s = [[ShipEntity alloc] initWithName:[NSString stringWithFormat:@"%u", i]];
		[testGroup addShip:s];
	}
	LogGroup(testGroup);
	
	for (i = 0; i < 127; i++)
	{
		ShipEntity *s = [[ShipEntity alloc] initWithName:[NSString stringWithFormat:@"%u", i]];
		[testGroup removeShip:s];
	}
	LogGroup(testGroup);
	for (i = 0; i < 300; i++)
	{
		ShipEntity *s = [[ShipEntity alloc] initWithName:[NSString stringWithFormat:@"%u", i]];
		[testGroup addShip:s];
	}
	LogGroup(testGroup);
	
	NSLog(@"Testing fast iteration.");
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:300];
	for (ShipEntity *x in testGroup)
	{
		[array addObject:x];
	}
	NSLog(@"Fast iteration result: %@", [array componentsJoinedByString:@", "]);
	
	NSLog(@"Releasing pool.");
	[pool release];
}


static void LogGroup(OOShipGroup *group)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSArray *ships = [group memberArray];
	NSLog(@"Group contains: %@", [ships componentsJoinedByString:@", "]);
	[pool release];
}

#import <Foundation/Foundation.h>
#import "OOPriorityQueue.h"


#if 0
#define DumpQueueState(queue)  NSLog(@"%@", [queue debugDescription])
#else
#define DumpQueueState(queue) do {} while (0)
#endif


#ifdef DEBUG_GRAPHVIZ
@interface OOPriorityQueue (DebugGraphViz)
- (void) writeGraphVizToPath:(NSString *)path;
@end
#endif


static void PutNumbersInQueue(unsigned count, OOPriorityQueue *queue);
static void PutStringsInQueue(OOPriorityQueue *queue);
static void DumpQueue(OOPriorityQueue *queue);
static void TestEquality(void);


int main (int argc, const char * argv[])
{
    NSAutoreleasePool	*pool = [[NSAutoreleasePool alloc] init];
	OOPriorityQueue		*queue = nil;
	unsigned			i;
	
	srandomdev();
	queue = [[OOPriorityQueue alloc] init];
	
	for (i = 0; i != 25; ++i)
	{
		NSLog(@"%u numbers:", i);
		PutNumbersInQueue(i, queue);
#ifdef DEBUG_GRAPHVIZ
		[queue writeGraphVizToPath:[NSString stringWithFormat:@"pqtest_int_%u.dot", i]];
#endif
		DumpQueue(queue);
		NSLog(@"\n");
	}
	
	PutStringsInQueue(queue);
#ifdef DEBUG_GRAPHVIZ
	[queue writeGraphVizToPath:@"pqtest_string.dot"];
#endif
	DumpQueue(queue);
	
	TestEquality();
	
    [pool release];
    return 0;
}


static void DumpQueue(OOPriorityQueue *queue)
{
#if 0
	id					value = nil;
	
	while ((value = [queue nextObject]))
	{
		DumpQueueState(queue);
		NSLog(@"%@", value);
	}
#else
	NSArray				*values = nil;
	NSArray				*resorted = nil;
	
	values = [queue sortedObjects];
	NSLog(@"%@", values);
	
	resorted = [values sortedArrayUsingSelector:@selector(compare:)];
	if (![values isEqual:resorted])
	{
		NSLog(@"FAILED - out of order. Correct order is: %@", resorted);
	}
#endif
}


static void PutNumbersInQueue(unsigned count, OOPriorityQueue *queue)
{
	while (count--)
	{
		[queue addObject:[NSNumber numberWithLong:random() % 100]];
		DumpQueueState(queue);
	}
}


static void PutStringsInQueue(OOPriorityQueue *queue)
{
	NSArray *array = [NSArray arrayWithObjects: @"dog", @"cat", @"apple", @"zebra", @"spanner", @"cat", nil];
	[queue addObjects:array];
	DumpQueueState(queue);
}


static void TestEquality(void)
{
	BOOL		OK = YES;
	
	// Note: permuations of the same objects.
	NSArray *array1 = [NSArray arrayWithObjects: @"dog", @"cat", @"apple", @"zebra", @"spanner", @"cat", nil];
	NSArray *array2 = [NSArray arrayWithObjects: @"apple", @"cat", @"dog", @"zebra", @"cat", @"spanner", nil];
	OOPriorityQueue	*q1 = [[OOPriorityQueue alloc] init];
	OOPriorityQueue	*q2 = [[OOPriorityQueue alloc] init];
	
	[q1 addObjects:array1];
	[q2 addObjects:array2];
	if (![q1 isEqual:q2])  OK = NO;
	
	[q2 addObject:@"snake"];
	if ([q1 isEqual:q2])  OK = NO;
	
	[q2 removeObject:@"snake"];
	if (![q1 isEqual:q2])  OK = NO;
	
	NSLog(@"Equality test %@", OK ? @"passed" : @"FAILED");
	
	[q1 release];
	[q2 release];
}

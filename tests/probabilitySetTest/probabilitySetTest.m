#import <Foundation/Foundation.h>
#import "OOProbabilitySet.h"
#import "legacy_random.h"
#undef NSLog
#undef NSLogv


static OOProbabilitySet *SetUpTestSet1(void);
static OOProbabilitySet *SetUpTestSet2(void);
static OOProbabilitySet *SetUpTestSet3(void);
static void PresentHistogram(NSCountedSet *histogram);


@interface OOProbabilitySet (SekritInternalStuff)

- (id) privObjectForWeight:(float)target;

@end


int main (int argc, const char * argv[])
{
	srandomdev();
	ranrot_srand(random());
	
	OOProbabilitySet *pset = nil;
	
#if 0
	// Test basic lookup
	pset = SetUpTestSet1();
	float f;
	
	for (f = -1; f <= [pset count] + 1; f += 0.25)
	{
		NSLog(@"%f: %@", f, [pset privObjectForWeight:f]);
	}
#endif
	
	// Test probabilities
	pset = SetUpTestSet2();
	NSLog(@"%@", pset);
	unsigned count = 1000000;
	NSCountedSet *histogram = [[NSCountedSet alloc] init];
	while (count--)
	{
		id object = [pset randomObject];
		if (object == nil)  object = [NSNull null];
		[histogram addObject:object];
	}
	
	// Test non-empty all-zero set
	pset = SetUpTestSet3();
	NSLog(@"Random item from set with all-zero weights: %@", [pset randomObject]);
	
	PresentHistogram(histogram);
	
	return 0;
}


static OOProbabilitySet *SetUpTestSet1(void)
{
	// Create a probability set with 20 ordered NSNumbers, all of weight one.
	enum { kCount = 20 };
	unsigned i;
	float weights[kCount];
	id objects[kCount];
	
	for (i = 0; i < kCount; ++i)
	{
		objects[i] = [NSNumber numberWithInt:i+1];
		weights[i] = 1.0f;
	}
	
	return [OOProbabilitySet probabilitySetWithObjects:objects weights:weights count:kCount];
}


static OOProbabilitySet *SetUpTestSet2(void)
{
#if 0
	// Also test plist-based set-up as a bonus.
	id plist = [@"{ objects = (Five, One, Three, Zero, \"Also one\" ); weights = (5, 1, 3, 0, 1); }" propertyList];
	return [OOProbabilitySet probabilitySetWithPropertyListRepresentation:plist];
#else
	OOMutableProbabilitySet *pset = [OOMutableProbabilitySet probabilitySet];
	[pset setWeight:5 forObject:@"Five"];
	[pset setWeight:5 forObject:@"Three"];	// To test replacement
	[pset setWeight:3 forObject:@"Three"];
	[pset setWeight:0 forObject:@"Zero"];
	[pset setWeight:1 forObject:@"One"];
	[pset setWeight:1 forObject:@"Also one"];
	
	return pset;
#endif
}


static OOProbabilitySet *SetUpTestSet3(void)
{
	OOMutableProbabilitySet *pset = [OOMutableProbabilitySet probabilitySet];
	[pset setWeight:0 forObject:@"A"];
	[pset setWeight:0 forObject:@"B"];
	[pset setWeight:0 forObject:@"C"];
	return [pset copy];
}


static void PresentHistogram(NSCountedSet *histogram)
{
	NSEnumerator			*objEnum = nil;
	id						obj = nil;
	
	for (objEnum = [histogram objectEnumerator]; (obj = [objEnum nextObject]); )
	{
		NSLog(@"%@: %lu", obj, [histogram countForObject:obj]);
	}
}


void OOLogWithFunctionFileAndLine(NSString *inMessageClass, const char *inFunction, const char *inFile, unsigned long inLine, NSString *inFormat, ...)
{
	va_list args;
	va_start(args, inFormat);
	NSLogv(inFormat, args);
	va_end(args);
}


BOOL OOLogWillDisplayMessagesInClass(NSString *inMessageClass)
{
	return YES;
}

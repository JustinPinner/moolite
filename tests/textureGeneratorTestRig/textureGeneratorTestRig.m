#import <Foundation/Foundation.h>
#import "CollectionUtils.h"
#import "OOPlanetTextureGenerator.h"
#import "OOProfilingStopwatch.h"


#define WRITE_RESULTS	1


int main (int argc, const char * argv[])
{
    [[NSAutoreleasePool alloc] init];
	
	// Set up magic numbers for Lave.
	RANROTSeed seed = { 3560527675, 2338263651 };
	NSDictionary *planetInfo =
	$dict(
		  @"economy", $int(5),
		  @"land_color", [OOColor colorWithRed:0.742188 green:0.662143 blue:0.472565],
		  @"sea_color", [OOColor colorWithRed:0.589844 green:0.393997 blue:0.573013],
		  @"polar_land_color", [OOColor colorWithRed:0.925781 green:0.90082 blue:0.841702],
		  @"polar_sea_color", [OOColor colorWithRed:0.941016 green:0.862904 blue:0.934303],
		  @"land_fraction", $float(0.65),
		  @"noise_map_seed", [NSValue valueWithBytes:&seed objCType:@encode(RANROTSeed)]
	);
	
	// Set up generators with mock texture thingies.
	OOTexture *diffuseTex = nil, *normalTex = nil;
	if (![OOPlanetTextureGenerator generatePlanetTexture:&diffuseTex
										secondaryTexture:&normalTex
												withInfo:planetInfo])
	{
		NSLog(@"Well, that's interesting. The texture generator failed to set up.");
		return EXIT_FAILURE;
	}
	
	OOTextureGenerator *diffuseGen = diffuseTex.generator;
	
	// This is the bit that's interesting to profile.
	OOProfilingStopwatch *stopwatch = [OOProfilingStopwatch stopwatch];
	[stopwatch start];
	[diffuseGen render];
	[stopwatch stop];
	
	NSLog(@"Rendering completed in %g seconds.", stopwatch.currentTime);
	
#if WRITE_RESULTS
	OOTextureGenerator *normalGen = normalTex.generator;
	[normalGen render];
	
	NSLog(@"Writing diffuse/lights.");
	[diffuseGen dumpToRGBFile:@"diffuse" andAlphaFile:@"lights"];
	NSLog(@"Writing normal/specular.");
	[normalGen dumpToRGBFile:@"normal" andAlphaFile:@"specular"];
	NSLog(@"Done.");
#endif
	
    return 0;
}


unsigned RanrotWithSeed(RANROTSeed *ioSeed)
{
	assert(ioSeed != NULL);
	
	ioSeed->high = (ioSeed->high << 16) + (ioSeed->high >> 16);
	ioSeed->high += ioSeed->low;
	ioSeed->low += ioSeed->high;
	return ioSeed->high & 0x7FFFFFFF;
}


float randfWithSeed(RANROTSeed *ioSeed)
{
	return (RanrotWithSeed(ioSeed) & 0xffff) * (1.0f / 65536.0f);
}


@implementation OOColor

@synthesize redComponent, blueComponent, greenComponent;

+ (OOColor *) colorWithRed:(float)r green:(float)g blue:(float)b
{
	OOColor *result = [[[OOColor alloc] init] autorelease];
	result.redComponent = r;
	result.greenComponent = g;
	result.blueComponent = b;
	return result;
}

@end


@implementation OOTexture

@synthesize generator = _generator;

+ (id) textureWithGenerator:(OOTextureGenerator *)generator
{
	OOTexture *result = [[[OOTexture alloc] init] autorelease];
	result.generator = generator;
	return result;
}

@end


void OOLog(NSString *msgClass, NSString *format, ...)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	va_list args;
	va_start(args, format);
	NSString *message = [[[NSString alloc] initWithFormat:format arguments:args] autorelease];
	va_end(args);
	
	message = [NSString stringWithFormat:@"[%@] %@", msgClass, message];
	puts([message UTF8String]);
	
	DESTROY(pool);
}


void NSLogShim(NSString *format, ...)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	va_list args;
	va_start(args, format);
	NSString *message = [[[NSString alloc] initWithFormat:format arguments:args] autorelease];
	va_end(args);
	
	puts([message UTF8String]);
	
	DESTROY(pool);
}

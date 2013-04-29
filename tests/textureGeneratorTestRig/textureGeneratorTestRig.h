//
// Prefix header for all source files of the 'textureGeneratorTestRig' target in the 'textureGeneratorTestRig' project.
//

#ifdef __OBJC__

#import <Foundation/Foundation.h>

#import "OOMaths.h"


typedef struct RANROTSeed
{
	uint32_t			high,
	low;
} RANROTSeed;


unsigned RanrotWithSeed(RANROTSeed *ioSeed);
float randfWithSeed(RANROTSeed *ioSeed);


@protocol OOAsyncWorkTask <NSObject>
@end


typedef enum
{
	kOOTextureDataInvalid,
	
	kOOTextureDataRGBA,			// GL_RGBA, GL_UNSIGNED_INT_8_8_8_8 little-endian/GL_UNSIGNED_INT_8_8_8_8_REV big-endian.
	kOOTextureDataGrayscale
} OOTextureDataFormat;


typedef float GLfloat;
typedef NSInteger OOInteger;
typedef NSUInteger OOUInteger;
typedef double OOTimeDelta;


@class OOTextureGenerator;


@interface OOTexture: NSObject
{
@private
	OOTextureGenerator *_generator;
}

+ (id) textureWithGenerator:(OOTextureGenerator *)generator;

@property (retain) OOTextureGenerator *generator;

@end


// MockUniverse stands in for both Universe and MyOpenGLView.
@interface MockUniverse: NSObject

+ (MockUniverse *) sharedUniverse;

- (BOOL) reducedDetail;

- (MockUniverse *) gameView;

// General image-dumping methods.
- (void) dumpRGBAToFileNamed:(NSString *)name
					   bytes:(uint8_t *)bytes
					   width:(OOUInteger)width
					  height:(OOUInteger)height
					rowBytes:(OOUInteger)rowBytes;

- (void) dumpRGBToFileNamed:(NSString *)name
					  bytes:(uint8_t *)bytes
					  width:(OOUInteger)width
					 height:(OOUInteger)height
				   rowBytes:(OOUInteger)rowBytes;

- (void) dumpGrayToFileNamed:(NSString *)name
					   bytes:(uint8_t *)bytes
					   width:(OOUInteger)width
					  height:(OOUInteger)height
					rowBytes:(OOUInteger)rowBytes;

// Split alpha into separate file.
- (void) dumpRGBAToRGBFileNamed:(NSString *)rgbName
			   andGrayFileNamed:(NSString *)grayName
						  bytes:(uint8_t *)bytes
						  width:(OOUInteger)width
						 height:(OOUInteger)height
					   rowBytes:(OOUInteger)rowBytes;

@end


#define UNIVERSE [MockUniverse sharedUniverse]


#define DESTROY(x) do { id x_ = x; x = nil; [x_ release]; } while (0)


enum
{
	// Values don't matter in test rig
	kOOTextureMinFilterLinear, kOOTextureMagFilterLinear, kOOTextureRepeatS, kOOTextureNoShrink
};


void OOLog(NSString *msgClass, NSString *format, ...);
void NSLogShim(NSString *format, ...);
#define NSLog NSLogShim


// Texture generators have very simple colour needs.
@interface OOColor: NSObject
{
@private
	float redComponent, greenComponent, blueComponent;
}

+ (OOColor *) colorWithRed:(float)r green:(float)g blue:(float)b;

@property float redComponent;
@property float greenComponent;
@property float blueComponent;

@end

#endif

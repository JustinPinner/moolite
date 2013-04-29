typedef struct
{
	float			r, g, b;
} FloatRGB;


typedef struct
{
	float			r, g, b, a;
} FloatRGBA;


@interface OOTextureGenerator: NSObject
{
@protected
	void					*data;
	uint32_t				width, height, rowBytes;
	
	OOTextureDataFormat		format;
	
@private
	BOOL					_ready;
}


- (BOOL) isReady;
- (BOOL) enqueue;

- (BOOL) getResult:(void **)outData
			format:(OOTextureDataFormat *)outFormat
			 width:(uint32_t *)outWidth
			height:(uint32_t *)outHeight;

// For subclass
- (void) loadTexture;

// For client
- (void) render;

- (void) dumpToRGBFile:(NSString *)rgbName andAlphaFile:(NSString *)alphaName;

@end

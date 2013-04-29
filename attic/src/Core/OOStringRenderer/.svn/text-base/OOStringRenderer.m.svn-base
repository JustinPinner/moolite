/*

OOStringRenderer.m


Oolite
Copyright (C) 2004-2012 Giles C Williams and contributors

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
MA 02110-1301, USA.

*/

#import "OOStringRenderer.h"

#import "OOCache.h"
#import "OOCollectionExtractors.h"
#import "OOEncodingConverter.h"
#import "OOGraphicsResetManager.h"
#import "OOMacroOpenGL.h"
#import "OOOpenGLExtensionManager.h"
#import "OOTexture.h"
#import "ResourceManager.h"


/*
	Profiling observations:
	* The clock generates one new string per second.
	* The trade screens each use over 60 strings, so cache sizes below 70 are
	  undesireable.
	* Cache hit ratio is extremely near 100% at most times.
*/
#define INSTRUMENT_CACHE			0
#define CACHE_PRUNE_THRESHOLD		100


static OOTexture					*sFontTexture = nil;
static OOEncodingConverter			*sEncodingConverter = nil;
static float						sGlyphWidths[256];

#define GLYPH_SCALE_FACTOR			0.13		// 0.13 is an inherited magic number.

// Count of glpyhs in each direction in font texture.
#define GLYPH_COUNT_X				16
#define GLYPH_COUNT_Y				16

// Glyphs beyond 32 (space) have a 1/8 em baseline offset.
#define BASELINE_OFFSET_THRESHOLD	32
#define BASELINE_OFFSET				0.125f


static void InitTextEngine(void);


enum
{
	kFontTextureOptions = kOOTextureMinFilterMipMap | kOOTextureMagFilterLinear | kOOTextureNoShrink | kOOTextureAlphaMask,
	
	kVerticesPerGlyph		= 4,
	kComponentsPerVertex	= 4,
	kComponentsPerGlyph		= kComponentsPerVertex * kVerticesPerGlyph
};


void OODrawString(NSString *text, GLfloat x, GLfloat y, GLfloat z, NSSize size)
{
	[[OOStringRenderer rendererWithString:text] renderAt:(Vector){x, y, z} size:size];
}


void OODrawDynamicString(NSString *text, GLfloat x, GLfloat y, GLfloat z, NSSize size)
{
	[[OOStringRenderer rendererWithStringUncached:text] renderAt:(Vector){x, y, z} size:size];
}


NSRect OORectFromString(NSString *text, GLfloat x, GLfloat y, NSSize siz)
{
	GLfloat				w = 0;
	NSData				*data = nil;
	const uint8_t		*bytes = NULL;
	NSUInteger			i, length;
	
	if (sEncodingConverter == NULL)  InitTextEngine();
	
	data = [sEncodingConverter convertString:text];
	bytes = [data bytes];
	length = [data length];
	
	for (i = 0; i < length; i++)
	{
		w += siz.width * sGlyphWidths[bytes[i]];
	}
	
	return NSMakeRect(x, y, w, siz.height);
}


GLfloat OOStringWidthInEm(NSString *text)
{
	return OORectFromString(text, 0, 0, NSMakeSize(1.0 / (GLYPH_SCALE_FACTOR * 8.0), 1.0)).size.width;
}


@interface OOStringRenderer (OOPrivate) <OOGraphicsResetClient>

// Initializer. <transient> is a hint that the string is likely to be drawn only once.
- (id) initWithString:(NSString *)string transient:(bool)transient;

- (void) generateDrawingDataForString:(NSString *)string;

#ifndef NDEBUG
- (NSString *) recoverString;
#endif

@end


@implementation OOStringRenderer

+ (id) rendererWithString:(NSString *)string
{
	if (string == nil)  return nil;
	
	OOStringRenderer *result = nil;
	
#if INSTRUMENT_CACHE
	static NSUInteger queryCount = 0, missCount = 0;
	queryCount++;
#endif
	
	static OOCache *stringCache = nil;
	if (EXPECT_NOT(stringCache == nil))
	{
		stringCache = [[OOCache alloc] init];
		[stringCache setPruneThreshold:CACHE_PRUNE_THRESHOLD];
		[stringCache setName:@"OOStringRenderer cache"];
	}
	else
	{
		result = [stringCache objectForKey:string];
	}
	
	if (result == nil)
	{
		result = [[[self alloc] initWithString:string transient:false] autorelease];
		[stringCache setObject:result forKey:string];
		
#if INSTRUMENT_CACHE
		missCount++;
		if (missCount % 25 == 0)
		{
			NSUInteger hitCount = queryCount - missCount;
			OOLog(@"render.string.cache", @"String renderer cache hit rate: %.5g %% (%lu / %lu).", (double)hitCount / queryCount * 100.0, hitCount, queryCount);
		}
#endif
	}
	
	return result;
}


+ (id) rendererWithStringUncached:(NSString *)string
{
	return [[[self alloc] initWithString:string transient:true] autorelease];
}


- (id) initWithString:(NSString *)string transient:(bool)transient
{
	if (string == nil)
	{
		[self release];
		return nil;
	}
	
	if ((self = [super init]))
	{
		if (sFontTexture == nil)  InitTextEngine();
		
		[self generateDrawingDataForString:string];
		if (_data == NULL)
		{
			[self release];
			return nil;
		}
		
#if OO_USE_VBO
		_vboEnabled = !transient && [[OOOpenGLExtensionManager sharedManager] vboSupported];
		if (_vboEnabled)
		{
			[[OOGraphicsResetManager sharedManager] registerClient:self];
		}
#endif
	}
	
	return self;
}


- (void) dealloc
{
	[[OOGraphicsResetManager sharedManager] unregisterClient:self];
	[self resetGraphicsState];
	
	free(_data);
	
	[super dealloc];
}


- (NSString *) descriptionComponents
{
#ifndef NDEBUG
	return [NSString stringWithFormat:@"\"%@\"", [self recoverString]];
#else
	return [NSString stringWithFormat:@"%u glyphs", _count / kVerticesPerGlyph];
#endif
}


- (void) renderAt:(Vector)p size:(NSSize)s
{
	// Equivalent to glTranslatef(p.x, p.y, pz); glScalef(s.width, s.height, 1);
	OOMatrix drawMatrix = OOMatrixConstruct(
		s.width,		0,				0,				0,
		0,				s.height,		0,				0,
		0,				0,				1,				0,
		p.x,			p.y,			p.z,			1
	);
	
	// Equivalent to glScalef(1/s.width, 1/s.height, 1); glTranslatef(-p.x, -p.y, -pz); 
	OOMatrix restoreMatrix = OOMatrixConstruct(
		1/s.width,		0,				0,				0,
		0,				1/s.height,		0,				0,
		0,				0,				1,				0,
		-p.x/s.width,	-p.y/s.height,	-p.z,			1
	);
	const GLsizei stride = kComponentsPerVertex * sizeof *_data;
	
	OO_ENTER_OPENGL();
	
	OOSetOpenGLState(OPENGL_STATE_OVERLAY);
	OOGL(glEnable(GL_TEXTURE_2D));
	OOGL(glEnable(GL_CULL_FACE));
	OOGL(glEnableClientState(GL_TEXTURE_COORD_ARRAY));
	[sFontTexture apply];
	GLMultOOMatrix(drawMatrix);
	
	GLfloat *dataPtr = _data;
#if OO_USE_VBO
	if (_vboEnabled)
	{
		if (_vbo == 0)
		{
			OOGL(glGenBuffersARB(1, &_vbo));
			if (EXPECT_NOT(_vbo == 0))  _vboEnabled = false;
			else
			{
				OOGL(glBindBufferARB(GL_ARRAY_BUFFER, _vbo));
				OOGL(glBufferDataARB(GL_ARRAY_BUFFER, _count * kComponentsPerVertex * sizeof *_data, _data, GL_STATIC_DRAW));
				dataPtr = NULL;  // Use VBO data instead of _data.
			}
		}
		else
		{
			OOGL(glBindBufferARB(GL_ARRAY_BUFFER, _vbo));
			dataPtr = NULL;
		}
	}
#endif
	
	OOGL(glVertexPointer(2, GL_FLOAT, stride, dataPtr));
	OOGL(glTexCoordPointer(2, GL_FLOAT, stride, dataPtr + 2));
	OOGL(glDrawArrays(GL_QUADS, 0, _count));
	
#if OO_USE_VBO
	if (_vboEnabled)  OOGL(glBindBufferARB(GL_ARRAY_BUFFER, 0));
#endif
	
	GLMultOOMatrix(restoreMatrix);
	OOGL(glDisableClientState(GL_TEXTURE_COORD_ARRAY));
	OOGL(glDisable(GL_CULL_FACE));
	OOGL(glDisable(GL_TEXTURE_2D));
	OOVerifyOpenGLState();
}


- (void) generateDrawingDataForString:(NSString *)string
{
	NSAssert(_data == NULL, @"Attempt to generate drawing data for an OOStringRenderer that already has it.");
	
	NSData *glyphData = [sEncodingConverter convertString:string];
	NSUInteger length = [glyphData length];
	const OOGlyph *glyphs = (const OOGlyph *)[glyphData bytes];
	
	NSAssert(length < INT32_MAX / kVerticesPerGlyph, @"This string is ridiculous.");
	
	_count = (GLsizei)length * kVerticesPerGlyph;
	_data = malloc(_count * kComponentsPerVertex * sizeof *_data);
	
	if (EXPECT_NOT(_data == NULL))  return;
	
	GLfloat *next = _data;
	GLfloat x = 0;
	for (NSUInteger i = 0; i < length; i++)
	{
		OOGlyph glyph = glyphs[i];
		unsigned glyphX = glyph % GLYPH_COUNT_Y;
		unsigned glyphY = glyph / GLYPH_COUNT_Y;
		GLfloat textureX = (GLfloat)glyphX / GLYPH_COUNT_X;
		GLfloat textureY = (GLfloat)glyphY / GLYPH_COUNT_Y;
		
		if (glyph > BASELINE_OFFSET_THRESHOLD)  textureY += BASELINE_OFFSET / GLYPH_COUNT_Y;
		
		GLfloat leftV = x, rightV = x + 1.0f;
		GLfloat topV = 1.0f, bottomV = 0.0f;
		GLfloat leftT = textureX, rightT = textureX + 1.0f / GLYPH_COUNT_X;
		GLfloat topT = textureY, bottomT = textureY + 1.0f / GLYPH_COUNT_Y;
		
		/*
			Each vertex has four components:
			vertex x, vertex y, texture s, texture t.
			
			The vertices are arranged anti-clockwise from the bottom left.
		*/
		// LB
		*next++ = leftV;
		*next++ = bottomV;
		*next++ = leftT;
		*next++ = bottomT;
		
		// RB
		*next++ = rightV;
		*next++ = bottomV;
		*next++ = rightT;
		*next++ = bottomT;
		
		// RT
		*next++ = rightV;
		*next++ = topV;
		*next++ = rightT;
		*next++ = topT;
		
		// LT
		*next++ = leftV;
		*next++ = topV;
		*next++ = leftT;
		*next++ = topT;
		
		// Advance.
		x += sGlyphWidths[glyph];
	}
}


#ifndef NDEBUG
- (NSString *) recoverString
{
	/*
		Figure out what our initial string was by converting texture coordinates
		back into "glyph space".
	*/
	NSUInteger i, glyphCount = _count / kVerticesPerGlyph;
	OOGlyph glyphs[glyphCount];
	
	for (i = 0; i < glyphCount; i++)
	{
		// s component of first vertex
		GLfloat textureX = _data[i * kComponentsPerGlyph + 0 * kComponentsPerVertex + 2];
		// t component of third vertex
		GLfloat textureY = _data[i * kComponentsPerGlyph + 2 * kComponentsPerVertex + 3];
		
		OOGlyph rowBase = (OOGlyph)(textureY * GLYPH_COUNT_Y) * GLYPH_COUNT_X;	// Baseline offset will be truncated away.
		OOGlyph glyph = rowBase + textureX * GLYPH_COUNT_X;
		
		glyphs[i] = glyph;
	}
	
	return [[[NSString alloc] initWithBytes:glyphs length:glyphCount encoding:[sEncodingConverter encoding]] autorelease];
}
#endif


- (void) resetGraphicsState
{
	OO_ENTER_OPENGL();
	
	if (_vbo != 0)
	{
		glDeleteBuffersARB(1, &_vbo);
		_vbo = 0;
	}
}

@end


static void InitTextEngine(void)
{
	NSDictionary			*fontSpec = nil;
	NSArray					*widths = nil;
	NSString				*texName = nil;
	NSUInteger				i, count;
	
	fontSpec = [ResourceManager dictionaryFromFilesNamed:@"oolite-font.plist"
												inFolder:@"Config"
												andMerge:NO];
	
	texName = [fontSpec oo_stringForKey:@"texture" defaultValue:@"oolite-font.png"];
	sFontTexture = [OOTexture textureWithName:texName
									 inFolder:@"Textures"
									  options:kFontTextureOptions
								   anisotropy:0.0f
									  lodBias:-0.75f];
	[sFontTexture retain];
	
	sEncodingConverter = [[OOEncodingConverter alloc] initWithFontPList:fontSpec];
	widths = [fontSpec oo_arrayForKey:@"widths"];
	count = [widths count];
	if (count > 256)  count = 256;
	for (i = 0; i != count; ++i)
	{
		sGlyphWidths[i] = [widths oo_floatAtIndex:i] * GLYPH_SCALE_FACTOR;
	}
}

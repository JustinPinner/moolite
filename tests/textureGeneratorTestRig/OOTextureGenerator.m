//
//  OOTextureGenerator.m
//  textureGeneratorTestRig
//
//  Created by Jens Ayton on 2009-12-15.
//  Copyright 2009 Jens Ayton. All rights reserved.
//

#import "OOTextureGenerator.h"
#import "textureGeneratorTestRig.h"


@implementation OOTextureGenerator

- (BOOL) isReady
{
	return _ready;
}


- (BOOL) enqueue
{
	return NO;
}

- (BOOL) getResult:(void **)outData
			format:(OOTextureDataFormat *)outFormat
			 width:(uint32_t *)outWidth
			height:(uint32_t *)outHeight
{
	*outData = data;
	*outFormat = format;
	*outWidth = width;
	*outHeight = height;
	
	return YES;
}


- (void) loadTexture
{
	
}


- (void) render
{
	[self loadTexture];
	_ready = YES;
}


- (void) dumpToRGBFile:(NSString *)rgbName andAlphaFile:(NSString *)alphaName
{
	NSAssert(_ready, @"Must call -render before -dumpToRGBFile:andAlphaFile:");
	
	[UNIVERSE dumpRGBAToRGBFileNamed:rgbName
					andGrayFileNamed:alphaName
							   bytes:data
							   width:width
							  height:height
							rowBytes:width * 4];
}

@end

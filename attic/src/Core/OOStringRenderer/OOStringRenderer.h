/*

OOStringRenderer.h


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

#import "OOCocoa.h"
#import "OOMaths.h"
#import "OOOpenGL.h"


/*	OODrawString(text, x, y, z, size)
	OODrawDynamicString(text, x, y, z, size)
	
	Draw a string at the specified coordinates. The emSize parameter is the em
	box size; for undistorted drawing, it should be a square.
	
	OODrawString() caches string renderers. OODrawDynamicString() does not,
	and should be used for strings that are unlikely to be redrawn.
*/
void OODrawString(NSString *text, GLfloat x, GLfloat y, GLfloat z, NSSize emSize);

void OODrawDynamicString(NSString *text, GLfloat x, GLfloat y, GLfloat z, NSSize emSize);

NSRect OORectFromString(NSString *text, GLfloat x, GLfloat y, NSSize emSize);
GLfloat OOStringWidthInEm(NSString *text);


@interface OOStringRenderer: NSObject
{
@private
	GLfloat				*_data;
	GLsizei				_count;
#if OO_USE_VBO
	GLuint				_vbo;
	bool				_vboEnabled;
#endif
}

+ (id) rendererWithString:(NSString *)string;
+ (id) rendererWithStringUncached:(NSString *)string;

- (void) renderAt:(Vector)position size:(NSSize)emSize;

@end

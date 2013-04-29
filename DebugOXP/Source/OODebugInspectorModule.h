/*

OODebugInspectorModule.h


Oolite Debug OXP

Copyright © 2007-2013 Jens Ayton

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

#import <Cocoa/Cocoa.h>
#import "OOWeakReference.h"


@interface OODebugInspectorModule: NSObject
{
@private
	OOWeakReference				*_object;
	IBOutlet NSView				*_rootView;
	
}

- (id) initWithObject:(id <OOWeakReferenceSupport>)object;
- (BOOL) loadUserInterface;		// Called to load UI; subclasses should generally override -awakeFromNib and optionally -nibName instead.

- (NSString *) nibName;	// Default: class name
- (NSView *) rootView;

- (id) object;
- (void) update;

@end


@interface NSObject (OODebugInspectorSupport)

- (NSArray *) debugInspectorModules;		// Array of OODebugInspectorModule subclasses.

@end


@interface NSArray (OODebugInspectorSupportUtilities)

// Utility for implementing -debugInspectorModules.
- (NSArray *) arrayByAddingInspectorModuleOfClass:(Class)theClass
										forObject:(id <OOWeakReferenceSupport>)object;

@end


// Em dash
NSString *InspectorUnknownValueString(void);

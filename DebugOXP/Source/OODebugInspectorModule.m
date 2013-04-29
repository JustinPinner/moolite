/*

OODebugInspectorModule.m


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

#import "OODebugInspectorModule.h"


@implementation OODebugInspectorModule

- (id) initWithObject:(id <OOWeakReferenceSupport>)object
{
	if ((self = [super init]))
	{
		_object = [object weakRetain];
		
		if (![self loadUserInterface])
		{
			[self release];
			self = nil;
		}
	}
	
	return self;
}


- (void) dealloc
{
	[_rootView release];
	[_object release];
	
	[super dealloc];
}


- (BOOL) loadUserInterface
{
	NSString				*nibName = nil;
	
	nibName = [self nibName];
	if (nibName == nil)  return NO;
	
	return [NSBundle loadNibNamed:nibName owner:self];
}


- (NSString *) nibName
{
	return [self className];
}


- (NSView *) rootView
{
	return _rootView;
}


- (id) object
{
	return [_object weakRefUnderlyingObject];
}


- (void) update
{
	
}

@end


@implementation NSArray (OODebugInspectorSupportUtilities)

- (NSArray *) arrayByAddingInspectorModuleOfClass:(Class)theClass
										forObject:(id <OOWeakReferenceSupport>)object
{
	id				module = nil;
	NSArray			*result = self;
	
	if ([theClass isSubclassOfClass:[OODebugInspectorModule class]])
	{
		module = [[[theClass alloc] initWithObject:object] autorelease];
		if (module != nil)
		{
			result = [result arrayByAddingObject:module];
		}
	}
	
	return result;
}

@end


NSString *InspectorUnknownValueString(void)
{
	static NSString *string = nil;
	if (string == nil)
	{
		string = [NSLocalizedStringFromTableInBundle(@"--", NULL, [NSBundle bundleForClass:[OODebugInspectorModule class]], @"") retain];
		if (string == nil)  string = @"-";
	}
	
	return string;
}

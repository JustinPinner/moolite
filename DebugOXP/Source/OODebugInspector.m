/*

OODebugInspector.m


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

#import "OODebugInspector.h"
#import "OOEntityInspectorExtensions.h"
#import "OODebugInspectorModule.h"


static NSMutableDictionary		*sActiveInspectors = nil;


@interface OODebugInspector ()

- (id) initWithObject:(id <OOWeakReferenceSupport>)object;

- (void) placeModules;

- (void) update;

@end


@implementation OODebugInspector

+ (id) inspectorForObject:(id <OOWeakReferenceSupport>)object
{
	OODebugInspector		*inspector = nil;
	NSValue					*key = nil;
	
	if (object == nil)  return nil;
	
	// Look for existing inspector
	key = [NSValue valueWithNonretainedObject:object];
	inspector = [sActiveInspectors objectForKey:key];
	if (inspector != nil)
	{
		if ([inspector object] == object)  return inspector;
		else
		{
			// Existing inspector is for an old object that used to be at the same address.
			[sActiveInspectors removeObjectForKey:key];
		}
	}
	
	// No existing inspector; create one.
	inspector = [[[self alloc] initWithObject:object] autorelease];
	
	return inspector;
}


- (void) dealloc
{
	[_timer invalidate];
	_timer = nil;
	_panel = nil;
	[_object release];
	_object = nil;
	if (_key != nil)  [sActiveInspectors removeObjectForKey:_key];
	[_key release];
	_key = nil;
	[_modules release];
	[_panel close];
	
	[super dealloc];
}


- (id <OOWeakReferenceSupport>) object
{
	if (_object != nil)
	{
		id result = [_object weakRefUnderlyingObject];
		if (result == nil)
		{
			[_object release];
			_object = nil;
		}
		return result;
	}
	else
	{
		return nil;
	}
}


- (void) bringToFront
{
	if (![_panel isVisible])  [self update];
	[_panel orderFront:nil];
}


+ (void) cleanUpInspectors
{
	[[sActiveInspectors allValues] makeObjectsPerformSelector:@selector(cleanSelfUp)];
}


- (id) initWithObject:(id <OOWeakReferenceSupport>)object
{
	if ((self = [super init]))
	{
		_key = [[NSValue valueWithNonretainedObject:object] retain];
		_object = [object weakRetain];
		
		[NSBundle loadNibNamed:@"OODebugInspector" owner:self];
		[self update];
		_timer = [NSTimer scheduledTimerWithTimeInterval:0.1
												  target:self
												selector:@selector(updateTick:)
												userInfo:nil
												 repeats:YES];
		
		_modules = [[(id)object debugInspectorModules] retain];
		[self placeModules];
		
		if (sActiveInspectors == nil)  sActiveInspectors = [[NSMutableDictionary alloc] init];
		[sActiveInspectors setObject:self forKey:_key];
	}
	
	return self;
}


- (void) placeModules
{
	// Lay out modules vertically in panel.
	float				totalHeight = 4; // Margin at bottom
	NSRect				frame;
	NSView				*contentView = nil, *moduleView = nil;
	NSSize				size;
	
	// Sum heights of modules.
	for (OODebugInspectorModule *module in _modules)
	{
		totalHeight += [[module rootView] frame].size.height;
	}
	
	// Resize panel appropriately.
	frame = [_panel contentRectForFrameRect:[_panel frame]];
	frame.size.height = totalHeight + 4; // Margin at top
	[_panel setFrame:[_panel frameRectForContentRect:frame] display:NO];
	
	size = [_panel contentMinSize];
	size.height = frame.size.height;
	[_panel setContentMinSize:size];
	
	size = [_panel contentMaxSize];
	size.height = frame.size.height;
	[_panel setContentMaxSize:size];
	
	// Position each module.
	contentView = [_panel contentView];
	for (OODebugInspectorModule *module in _modules)
	{
		moduleView = [module rootView];
		frame = [moduleView frame];
		totalHeight -= frame.size.height;
		frame.origin.y = totalHeight;
		[moduleView setFrame:frame];
		[contentView addSubview:moduleView];
	}
	
	[self update];
}


- (void) update
{
	[_modules makeObjectsPerformSelector:@selector(update)];
}


- (void) updateTick:(NSTimer *)timer
{
	if ([_panel isVisible])  [self update];
}


- (void)windowWillClose:(NSNotification *)notification
{
	_panel = nil;
	NSValue *key = _key;
	_key = nil;
	if (key != nil)  [sActiveInspectors removeObjectForKey:key];
	[key release];
}


- (void) cleanSelfUp
{
	if ([self object] == nil)  [_panel close];
}

@end

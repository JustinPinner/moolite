/*

OOObjectDebugInspectorModule.m


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

#import "OOObjectDebugInspectorModule.h"
#import "PlayerEntity.h"
#import "OOEntityInspectorExtensions.h"


@implementation OOObjectDebugInspectorModule

- (void) awakeFromNib
{
	NSRect				basicIDFrame, secondaryIDFrame, targetSelfFrame, rootFrame;
	NSView				*rootView = [self rootView];
	float				delta;
	
	id object = [self object];
	
	basicIDFrame = [_basicIdentityField frame];
	secondaryIDFrame = [_secondaryIdentityField frame];
	targetSelfFrame = [_targetSelfButton frame];
	rootFrame = [rootView frame];
	
	if (![object inspCanBecomeTarget])
	{
		// Remove targetSelfButton.
		[_targetSelfButton removeFromSuperview];
		_targetSelfButton = nil;
		basicIDFrame.size.width = secondaryIDFrame.size.width;
	}
	
	if (![object inspHasSecondaryIdentityLine])
	{
		// No secondary identity line, remove secondary identity field.
		delta = basicIDFrame.origin.y - secondaryIDFrame.origin.y;
		[_secondaryIdentityField removeFromSuperview];
		_secondaryIdentityField = nil;
		
		rootFrame.size.height -= delta;
		basicIDFrame.origin.y -= delta,
		targetSelfFrame.origin.y -= delta;
	}
	
	// Put bits in the right place.
	[rootView setFrame:rootFrame];
	[_basicIdentityField setFrame:basicIDFrame];
	[_secondaryIdentityField setFrame:secondaryIDFrame];
	[_targetSelfButton setFrame:targetSelfFrame];
}


- (void) update
{
	id object = [self object];
	
	if (object != nil)  [_basicIdentityField setStringValue:[object inspBasicIdentityLine]];
	if (_secondaryIdentityField != nil)
	{
		if (object != nil)
		{
			[_secondaryIdentityField setStringValue:[object inspSecondaryIdentityLine] ?: InspectorUnknownValueString()];
		}
		else
		{
			[_secondaryIdentityField setStringValue:@"Dead"];
		}
	}
}


- (IBAction) targetSelf:sender
{
	[[self object] inspBecomeTarget];
}

@end


@implementation NSObject (OOObjectDebugInspectorModule)

- (NSArray *) debugInspectorModules
{
	return [[NSArray array] arrayByAddingInspectorModuleOfClass:[OOObjectDebugInspectorModule class]
													  forObject:(id)self];
}

@end

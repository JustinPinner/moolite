/*

OOEntityDebugInspectorModule.m


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

#import "OOEntityDebugInspectorModule.h"
#import "OODebugInspector.h"
#import "OOEntityInspectorExtensions.h"
#import "Entity.h"


@implementation OOEntityDebugInspectorModule

- (IBAction) inspectOwner:sender
{
	[[[self object] owner] inspect];
}


- (void) update
{
	id					object = [self object];
	NSString			*placeholder = InspectorUnknownValueString();
	
	[_scanClassField setStringValue:[object inspScanClassLine] ?: placeholder];
	[_statusField setStringValue:[object inspStatusLine] ?: placeholder];
	[_retainCountField setStringValue:[object inspRetainCountLine] ?: @"0"];
	[_positionField setStringValue:[object inspPositionLine] ?: placeholder];
	[_velocityField setStringValue:[object inspVelocityLine] ?: placeholder];
	[_orientationField setStringValue:[object inspOrientationLine] ?: placeholder];
	[_energyField setStringValue:[object inspEnergyLine] ?: placeholder];
	[_energyIndicator setFloatValue:object ? ([object energy] * 100.0f / [object maxEnergy]) : 0.0f];
	[_ownerField setStringValue:[object inspOwnerLine] ?: @"None"];
}

@end


@implementation Entity (OOEntityDebugInspectorModule)

- (NSArray *) debugInspectorModules
{
	return [[super debugInspectorModules] arrayByAddingInspectorModuleOfClass:[OOEntityDebugInspectorModule class]
																	forObject:(id)self];
}

@end

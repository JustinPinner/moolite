/*

OOAIDebugInspectorModule.m


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

#import "OOAIDebugInspectorModule.h"
#import "AI.h"
#import "ShipEntity.h"
#import "Universe.h"
#import "OOEntityInspectorExtensions.h"
#import "OOConstToString.h"


@implementation OOAIDebugInspectorModule

- (void) update
{
	AI					*object = [self object];
	NSString			*placeholder = InspectorUnknownValueString();
	NSSet				*pending = nil;
	NSString			*pendingDesc = nil;
	
	[_stateMachineNameField setStringValue:[object name] ?: placeholder];
	[_stateField setStringValue:[object state] ?: placeholder];
	if (object != nil)
	{
		[_stackDepthField setIntegerValue:[object stackDepth]];
		[_timeToThinkField setStringValue:[NSString stringWithFormat:@"%.1f", [object nextThinkTime] - [UNIVERSE getTime]]];
		[_behaviourField setStringValue:OOStringFromBehaviour([[object owner] behaviour])];
		[_frustrationField setDoubleValue:[[object owner] frustration]];
	}
	else
	{
		[_stackDepthField setStringValue:placeholder];
		[_timeToThinkField setStringValue:placeholder];
		[_behaviourField setStringValue:placeholder];
		[_frustrationField setStringValue:placeholder];
	}
	
	pending = [object pendingMessages];
	if ([pending count] == 0)
	{
		pendingDesc = @"none";
	}
	else
	{
		pendingDesc = [[[pending allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] componentsJoinedByString:@", "];
		pendingDesc = [NSString stringWithFormat:@"%lu: %@", [pending count], pendingDesc];
	}
	
	[_pendingMessagesField setStringValue:pendingDesc];
}


- (IBAction) thinkNow:sender
{
	[[self object] setNextThinkTime:[UNIVERSE getTime]];
}


- (IBAction) dumpPendingMessages:sender
{
	[[self object] debugDumpPendingMessages];
}

@end


@implementation AI (OOAIDebugInspectorModule)

- (NSString *) inspBasicIdentityLine
{
	if ([self owner] != nil)  return [NSString stringWithFormat:@"AI for %@", [[self owner] inspBasicIdentityLine]];
	return  [super inspBasicIdentityLine];
}


- (NSArray *) debugInspectorModules
{
	return [[super debugInspectorModules] arrayByAddingInspectorModuleOfClass:[OOAIDebugInspectorModule class]
																	forObject:(id)self];
}

@end

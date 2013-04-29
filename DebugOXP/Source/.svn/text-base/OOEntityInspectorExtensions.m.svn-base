/*

OOEntityInspectorExtensions.m


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

#import "OOEntityInspectorExtensions.h"
#import "OOConstToString.h"
#import "PlayerEntity.h"
#import "OODebugInspector.h"


@implementation NSObject (OOInspectorExtensions)

- (NSString *) inspDescription
{
	NSString *desc = [self shortDescriptionComponents];
	if (desc == nil)  return [self className];
	else  return [NSString stringWithFormat:@"%@ %@", [self className], desc];
}


- (NSString *) inspBasicIdentityLine
{
	return [self inspDescription];
}


- (BOOL) inspHasSecondaryIdentityLine
{
	return NO;
}


- (NSString *) inspSecondaryIdentityLine
{
	return nil;
}

- (BOOL) inspCanBecomeTarget
{
	return NO;
}


- (void) inspBecomeTarget
{
	
}


// Callable via JS Entity.inspect()
- (void) inspect
{
	if ([self conformsToProtocol:@protocol(OOWeakReferenceSupport)])
	{
		[[OODebugInspector inspectorForObject:(id <OOWeakReferenceSupport>)self] bringToFront];
	}
}

@end


@implementation Entity (OOEntityInspectorExtensions)

- (NSString *) inspDescription
{
	return [NSString stringWithFormat:@"%@ ID %u", [self class], [self universalID]];
}


- (NSString *) inspBasicIdentityLine
{
	OOUniversalID		myID = [self universalID];
	
	if (myID != NO_TARGET)
	{
		return [NSString stringWithFormat:@"%@ ID %u", [self class], myID];
	}
	else
	{
		return [self className];
	}
}


- (NSString *) inspScanClassLine
{
	return OOStringFromScanClass([self scanClass]);
}


- (NSString *) inspStatusLine
{
	return OOStringFromEntityStatus([self status]);
}


- (NSString *) inspRetainCountLine
{
	return [NSString stringWithFormat:@"%lu", [self retainCount]];
}


- (NSString *) inspPositionLine
{
	Vector v = [self position];
	return [NSString stringWithFormat:@"%.0f, %.0f, %.0f", v.x, v.y, v.z];
}


- (NSString *) inspVelocityLine
{
	Vector v = [self velocity];
	return [NSString stringWithFormat:@"%.1f, %.1f, %.1f (%.1f)", v.x, v.y, v.z, magnitude(v)];
}


- (NSString *) inspOrientationLine
{
	Quaternion q = [self orientation];
	return [NSString stringWithFormat:@"%.3f (%.3f, %.3f, %.3f)", q.w, q.x, q.y, q.z];
}


- (NSString *) inspEnergyLine
{
	return [NSString stringWithFormat:@"%i/%i", (int)[self energy], (int)[self maxEnergy]];
}


- (NSString *) inspOwnerLine
{
	if ([self owner] == self)  return @"Self";
	return [[self owner] inspDescription];
}


- (NSString *) inspTargetLine
{
	return nil;
}

@end


@implementation ShipEntity (OOEntityInspectorExtensions)

- (BOOL) inspHasSecondaryIdentityLine
{
	return YES;
}


- (NSString *) inspSecondaryIdentityLine
{
	return [self displayName];
}


- (NSString *) inspDescription
{
	return [NSString stringWithFormat:@"%@ ID %u", [self displayName], [self universalID]];
}


- (NSString *) inspTargetLine
{
	return [[self primaryTarget] inspDescription];
}


- (BOOL) inspCanBecomeTarget
{
	return ![self isSubEntity];
}


- (void) inspBecomeTarget
{
	if ([self inspCanBecomeTarget])  [[PlayerEntity sharedPlayer] addTarget:self];
}

@end


@implementation PlayerEntity (OOEntityInspectorExtensions)

- (NSString *) inspSecondaryIdentityLine
{
	return [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"\"%@\", %@", nil, [NSBundle bundleForClass:[self class]], @""), [self commanderName], [self displayName]];
}


- (BOOL) inspCanBecomeTarget
{
	return NO;
}


- (NSString *) inspDescription
{
	return @"Player";
}

@end

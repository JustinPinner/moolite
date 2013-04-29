/*	Simple mock ShipEntity for testing OOShipGroup.
*/

#import "OOWeakReference.h"


@interface ShipEntity : OOWeakRefObject
{
	NSString	*_name;
}

- (id) initWithName:(NSString *)name;

@end

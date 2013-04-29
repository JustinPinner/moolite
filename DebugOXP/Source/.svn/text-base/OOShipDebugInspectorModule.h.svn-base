/*

OOShipDebugInspectorModule.h


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


@interface OOShipDebugInspectorModule: OODebugInspectorModule
{
@private
	IBOutlet NSTextField		*_primaryRoleField;
	IBOutlet NSTextField		*_otherRolesField;
	IBOutlet NSTextField		*_targetField;
	IBOutlet NSTextField		*_AIField;
	IBOutlet NSButton			*_reportAIMessagesCheckBox;
	IBOutlet NSTextField		*_scriptField;
	IBOutlet NSTextField		*_groupField;
	IBOutlet NSTextField		*_escortGroupField;
	IBOutlet NSTextField		*_laserTempField;
	IBOutlet NSLevelIndicator	*_laserTempIndicator;
	IBOutlet NSTextField		*_cabinTempField;
	IBOutlet NSLevelIndicator	*_cabinTempIndicator;
	IBOutlet NSTextField		*_fuelField;
	IBOutlet NSLevelIndicator	*_fuelIndicator;
}

- (IBAction) inspectPlayer:sender;
- (IBAction) inspectTarget:sender;
- (IBAction) inspectAI:sender;
- (IBAction) inspectGroup:sender;
- (IBAction) inspectEscortGroup:sender;
- (IBAction) takeReportAIMessagesFrom:sender;

@end

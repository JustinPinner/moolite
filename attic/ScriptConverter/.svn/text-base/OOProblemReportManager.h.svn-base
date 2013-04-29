//
//  OOProblemReportManager.h
//  ScriptConverter
//
//  Created by Jens Ayton on 2007-11-24.
//  Copyright 2007 Jens Ayton. All rights reserved.
//

#import <Cocoa/Cocoa.h>


typedef enum
{
	kOOProblemSeverityNone,
	kOOProblemSeverityNote,
	kOOProblemSeverityWarning,
	kOOProblemSeverityUnknownSelector,
	kOOProblemSeverityStop,
	kOOProblemSeverityBug
} OOProblemSeverity;


@protocol OOProblemReportManager <NSObject>

- (void) addIssueWithSeverity:(OOProblemSeverity)severity key:(NSString *)key description:(NSString *)description;
- (OOProblemSeverity) highestSeverity;

@end

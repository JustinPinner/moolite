//
//  OOLegacyScriptToJavaScriptConverterCore.h
//  ScriptConverter
//
//  Created by Jens Ayton on 2008-08-30.
//  Copyright 2008 Jens Ayton. All rights reserved.
//

#import "OOCocoa.h"
#import "OOLegacyScriptToJavaScriptConverter.h"


@class OOJSExprNode;


@interface OOLegacyScriptToJavaScriptConverter (Private)

- (void) setMetadata:(NSDictionary *)metadata;
- (void) setProblemReporter:(id <OOProblemReportManager>)problemReporter;

- (NSString *) convertScript:(NSArray *)actions;


- (void) writeHeader;

- (void) append:(NSString *)string;
- (void) appendWithFormat:(NSString *)format, ...;
- (void) appendWithFormat:(NSString *)format arguments:(va_list)args;

- (void) indent;
- (void) outdent;

- (NSString *) legalizedVariableName:(NSString *)rawName;
- (NSString *) expandString:(NSString *)string;
- (NSString *) expandStringOrNumber:(NSString *)string;
- (NSString *) expandIntegerExpression:(NSString *)string;
- (NSString *) expandFloatExpression:(NSString *)string;
- (NSString *) expandPropertyReference:(NSString *)string;	// either .identifier or ["string expression"]

- (OOJSExprNode *) expandRightHandSide:(NSString *)rhs;
- (OOJSExprNode *) convertVariableAccess:(NSString *)variableName;

- (void) setInitializer:(NSString *)initializerStatement forKey:(NSString *)key;
- (void) setHelperFunction:(NSString *)function forKey:(NSString *)key;

// Helpers to emulate -intValue and -doubleValue. They produce zero instead of NaN when given non-numerical strings.
- (void) setParseFloatOrZeroHelper;
- (void) setParseIntOrZeroHelper;

- (void) addIssueWithSeverity:(OOProblemSeverity)severity key:(NSString *)key format:(NSString *)format args:(va_list)args;
- (void) addNoteIssueWithKey:(NSString *)key format:(NSString *)format, ...;
- (void) addWarningIssueWithKey:(NSString *)key format:(NSString *)format, ...;
- (void) addUnknownSelectorIssueWithKey:(NSString *)key format:(NSString *)format, ...;
- (void) addStopIssueWithKey:(NSString *)key format:(NSString *)format, ...;
- (void) addBugIssueWithKey:(NSString *)key format:(NSString *)format, ...;

@end


@interface OOLegacyScriptToJavaScriptConverter (ConverterCore)

- (void) convertActions:(NSArray *)actions;

@end

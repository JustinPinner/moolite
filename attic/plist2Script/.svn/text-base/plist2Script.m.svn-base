/*
 * Oolite script plist -> oos converter.
 *
 * Copyright (c) 2006 David Taylor. All rights reserved.
 *
 * This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/2.0/
 * or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.
 *
 * You are free:
 *
 * o to copy, distribute, display, and perform the work
 * o to make derivative works
 *
 * Under the following conditions:
 *
 * o Attribution. You must give the original author credit.
 * o Noncommercial. You may not use this work for commercial purposes.
 * o Share Alike. If you alter, transform, or build upon this work,
 *   you may distribute the resulting work only under a license identical to this one.
 *
 * For any reuse or distribution, you must make clear to others the license terms of this work.
 * Any of these conditions can be waived if you get permission from the copyright holder.
 * Your fair use and other rights are in no way affected by the above.
 */

#import <Foundation/Foundation.h>

int indent = -4;

void printActions(NSArray* actions);

NSString* getIndentString() {
	NSMutableString* indentString = [[NSMutableString alloc] initWithCapacity:indent];
	int i;
	for (i = 0; i < indent; i++)
		[indentString appendString:@" "];

	return [NSString stringWithString:indentString];
}

NSString* parseIfClause(NSArray* conditions) {
	int j;
	NSMutableString* statement = [[NSMutableString alloc] init];

	for (j = 0; j < [conditions count]; j++) {
		if (j == 0)
			[statement appendString:@"if "];
		if (j > 0)
			[statement appendString:@"and "];

		[statement appendString:(NSString*)[conditions objectAtIndex:j]];
		[statement appendString:@" "];
	}
	[statement appendString:@"then"];
	[statement replaceOccurrencesOfString:@" equal " withString:@" = " options:NSLiteralSearch range:NSMakeRange(0, [statement length])];
	[statement replaceOccurrencesOfString:@" lessthan " withString:@" < " options:NSLiteralSearch range:NSMakeRange(0, [statement length])];
	[statement replaceOccurrencesOfString:@" morethan " withString:@" > " options:NSLiteralSearch range:NSMakeRange(0, [statement length])];
	[statement replaceOccurrencesOfString:@" greaterthan " withString:@" > " options:NSLiteralSearch range:NSMakeRange(0, [statement length])];
	return [NSString stringWithString:statement];
}

void printIfClause(NSDictionary* ifClause) {
	indent += 4;
	NSString* indentString = getIndentString();

	NSArray* conditions = (NSArray*)[ifClause objectForKey:@"conditions"];
	fprintf(stdout, "%s%s\n", [indentString cString], [parseIfClause(conditions) cString]);
	NSArray* actions = (NSArray*)[ifClause objectForKey:@"do"];
	printActions(actions);
	fprintf(stdout, "%sendif\n\n", [indentString cString]);

	indent -= 4;
}

void printActions(NSArray* actions) {
	int j;
	indent += 4;
	NSString* indentString = getIndentString();

	NSMutableString* statement = [[NSMutableString alloc] init];

	for (j = 0; j < [actions count]; j++) {
		NSString* actionClassName = [[actions objectAtIndex:j] className];
		if ([actionClassName hasSuffix:@"String"]) {
			fprintf(stdout, "%s%s\n", [indentString cString], [(NSString*)[actions objectAtIndex:j] cString]);
		} else if ([actionClassName hasSuffix:@"Dictionary"]) {
			indent -= 4;
			printIfClause((NSDictionary*)[actions objectAtIndex:j]);
			indent += 4;
		}
	}

	indent -= 4;
}

int main (int argc, char** argv)
{
	int i;

	NSAutoreleasePool *arp = [[NSAutoreleasePool alloc] init];
	NSString* filename = [NSString stringWithCString:argv[1]];
	NSString* missionname = @"";
	BOOL printScriptList = NO;

	if (argc > 2)
		missionname = [NSString stringWithCString:argv[2]];
	else
		printScriptList = YES;

	NSDictionary* script = [NSDictionary dictionaryWithContentsOfFile:filename];
	NSArray* keys = [script allKeys];
	if (printScriptList == YES) {
		for (i = 0; i < [keys count]; i++) {
			NSObject* obj = [keys objectAtIndex:i];
			fprintf(stdout, "%s\n", [[obj description] cString]);
		}
	} else {
		NSArray* ifClauses = (NSArray*)[script objectForKey:missionname];
		if (ifClauses == nil) {
			fprintf(stderr, "could not find script %s\n", [missionname cString]);
		} else {
			fprintf(stdout, "%s\n", [missionname cString]);

			for (i = 0; i < [ifClauses count]; i++) {
				NSDictionary* ifClause = (NSDictionary*)[ifClauses objectAtIndex:i];
				printIfClause(ifClause);
			}
		}
	}

	[arp release];
	return 0;
}

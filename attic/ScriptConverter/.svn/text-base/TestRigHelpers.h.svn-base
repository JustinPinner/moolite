//
//  TestRigHelpers.h
//  ScriptConverter
//
//  Created by Jens Ayton on 2009-03-13.
//  Copyright 2009 Jens Ayton. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (TestRigHelpers)

// Add escape codes for string so that it's a valid JavaScript literal (if you put "" or '' around it).
- (NSString *)escapedForJavaScriptLiteral;

// This only allows ASCII identifiers, not extended identifiers as supported in JS 1.5 and later.
// Does not exclude keywords.
- (BOOL) isJavaScriptIdentifier;

// True for keywords and reserved words.
- (BOOL) isJavaScriptKeyword;

@end

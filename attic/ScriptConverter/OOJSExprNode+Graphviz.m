//
//  OOJSExprNode+Graphviz.m
//  ScriptConverter
//
//  Created by Jens Ayton on 2009-03-13.
//  Copyright 2009 Jens Ayton. All rights reserved.
//

#import "OOJSExprNode+Graphviz.h"
#import "OOLogging.h"
#import "TestRigHelpers.h"	// FIXME


@interface OOJSExprNode (GraphvizInternal)

- (void) appendGraphVizRepresentation:(NSMutableString *)graphviz andGetNodeName:(NSString **)name;

@end


@implementation OOJSExprNode (Graphviz)

- (NSString *) graphvizRepresentation
{
	NSMutableString *graphviz = [NSMutableString stringWithString:@"digraph jsexpr\n{\n\tgraph [charset=\"UTF-8\"];\n\tnode[shape=record];\n\t\n"];
	NSString *name = nil;
	
	[self appendGraphVizRepresentation:graphviz andGetNodeName:&name];
	
	[graphviz appendString:@"}\n"];
	return [[graphviz copy] autorelease];
}


- (void) appendGraphVizRepresentation:(NSMutableString *)graphviz andGetNodeName:(NSString **)name
{
	OOLogGenericSubclassResponsibility();
}

@end


@implementation OOJSIntLiteralExprNode (GraphvizInternal)

- (void) appendGraphVizRepresentation:(NSMutableString *)graphviz andGetNodeName:(NSString **)name
{
	*name = [NSString stringWithFormat:@"int_%p", self];
	[graphviz appendFormat:@"\t%@ [label=\"%lli\"];\n", *name, (long long)[self int64Value]];
}

@end


@implementation OOJSDoubleLiteralExprNode (GraphvizInternal)

- (void) appendGraphVizRepresentation:(NSMutableString *)graphviz andGetNodeName:(NSString **)name
{
	*name = [NSString stringWithFormat:@"double_%p", self];
	[graphviz appendFormat:@"\t%@ [label=\"%g\"];\n", *name, [self doubleValue]];
}

@end


@implementation OOJSBoolLiteralExprNode (GraphvizInternal)

- (void) appendGraphVizRepresentation:(NSMutableString *)graphviz andGetNodeName:(NSString **)name
{
	*name = [self boolValue] ? @"true" : @"false";
	[graphviz appendFormat:@"\t%@;\n", *name];
}

@end


@implementation OOJSStringLiteralExprNode (GraphvizInternal)

- (void) appendGraphVizRepresentation:(NSMutableString *)graphviz andGetNodeName:(NSString **)name
{
	*name = [NSString stringWithFormat:@"string_%p", self];
	[graphviz appendFormat:@"\t%@ [label=\"\\\"%@\\\"\"];\n", *name, [[self escapedStringValue] escapedForJavaScriptLiteral]];
}

@end


@implementation OOJSIdentifierExprNode (GraphvizInternal)

- (void) appendGraphVizRepresentation:(NSMutableString *)graphviz andGetNodeName:(NSString **)name
{
	*name = [NSString stringWithFormat:@"id_%p", self];
	[graphviz appendFormat:@"\t%@ [label=\"%@\"];\n", *name, [[self identifier] escapedForJavaScriptLiteral]];
}

@end


@implementation OOJSUnaryOperatorExprNode (GraphvizInternal)

- (void) appendGraphVizRepresentation:(NSMutableString *)graphviz andGetNodeName:(NSString **)name
{
	*name = [NSString stringWithFormat:@"unary_%p", self];
	[graphviz appendFormat:@"\t%@ [label=\"%@\"];\n", *name, [[self operatorToken] escapedForJavaScriptLiteral]];
	
	NSString *subName = nil;
	[[self subExpression] appendGraphVizRepresentation:graphviz andGetNodeName:&subName];
	[graphviz appendFormat:@"\t%@ -> %@;\n", *name, subName];
}

@end


@implementation OOJSBinaryOperatorExprNode (GraphvizInternal)

- (void) appendGraphVizRepresentation:(NSMutableString *)graphviz andGetNodeName:(NSString **)name
{
	*name = [NSString stringWithFormat:@"binary_%p", self];
	[graphviz appendFormat:@"\t%@ [label=\"<left>|<op>%@|<right>\"];\n", *name, [[self operatorToken] escapedForJavaScriptLiteral]];
	
	NSString *lhsName = nil;
	NSString *rhsName = nil;
	[[self leftHandSideExpression] appendGraphVizRepresentation:graphviz andGetNodeName:&lhsName];
	[[self rightHandSideExpression] appendGraphVizRepresentation:graphviz andGetNodeName:&rhsName];
	[graphviz appendFormat:@"\t%@:left -> %@;\n", *name, lhsName];
	[graphviz appendFormat:@"\t%@:right -> %@;\n", *name, rhsName];
}

@end


@implementation OOJSPropertyAccessExprNode (GraphvizInternal)

- (void) appendGraphVizRepresentation:(NSMutableString *)graphviz andGetNodeName:(NSString **)name
{
	*name = [NSString stringWithFormat:@"prop_%p", self];
	[graphviz appendFormat:@"\t%@ [label=\"<obj>|<op>[]|<prop>\"];\n", *name];
	
	NSString *objName = nil;
	NSString *propName = nil;
	[[self objectExpression] appendGraphVizRepresentation:graphviz andGetNodeName:&objName];
	[[self propertyExpression] appendGraphVizRepresentation:graphviz andGetNodeName:&propName];
	[graphviz appendFormat:@"\t%@:obj -> %@;\n", *name, objName];
	[graphviz appendFormat:@"\t%@:prop -> %@;\n", *name, propName];
}

@end


@implementation OOJSFunctionCallExprNode (GraphvizInternal)

- (void) appendGraphVizRepresentation:(NSMutableString *)graphviz andGetNodeName:(NSString **)name
{
	NSArray				*arguments = [self arguments];
	unsigned			i, count = [arguments count];
	
	*name = [NSString stringWithFormat:@"call_%p", self];
	
	[graphviz appendFormat:@"\t%@ [label=\"<func>|<op>call()", *name];
	for (i = 0; i < count; i++)
	{
		[graphviz appendFormat:@"|<arg%u>", i];
	}
	[graphviz appendString:@"\"]\n"];
	
	NSString *funcName = nil;
	[[self functionExpression] appendGraphVizRepresentation:graphviz andGetNodeName:&funcName];
	[graphviz appendFormat:@"\t%@:func -> %@;\n", *name, funcName];
	
	NSString *propName = nil;
	for (i = 0; i < count; i++)
	{
		[[arguments objectAtIndex:i] appendGraphVizRepresentation:graphviz andGetNodeName:&propName];
		[graphviz appendFormat:@"\t%@:arg%u -> %@;\n", *name, i, propName];
	}
}

@end


@implementation OOJSConditionalExprNode (GraphvizInternal)

- (void) appendGraphVizRepresentation:(NSMutableString *)graphviz andGetNodeName:(NSString **)name
{
	*name = [NSString stringWithFormat:@"cond_%p", self];
	[graphviz appendFormat:@"\t%@ [label=\"<condition>|<op>?:|<true>|<false>\"];\n", *name];
	
	NSString *condName = nil;
	NSString *trueName = nil;
	NSString *falseName = nil;
	[[self conditionExpression] appendGraphVizRepresentation:graphviz andGetNodeName:&condName];
	[[self trueExpression] appendGraphVizRepresentation:graphviz andGetNodeName:&trueName];
	[[self falseExpression] appendGraphVizRepresentation:graphviz andGetNodeName:&falseName];
	[graphviz appendFormat:@"\t%@:condition -> %@;\n", *name, condName];
	[graphviz appendFormat:@"\t%@:true -> %@;\n", *name, trueName];
	[graphviz appendFormat:@"\t%@:false -> %@;\n", *name, falseName];
}

@end

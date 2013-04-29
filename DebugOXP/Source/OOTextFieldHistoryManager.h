/*

OOTextFieldHistoryManager.h

Text field delegate to manage input history.


Oolite Debug OXP

Copyright (C) 2007 Jens Ayton

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
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

#import <Cocoa/Cocoa.h>


enum
{
	kDefaultHistorySize = 100
};


@interface OOTextFieldHistoryManager: NSObject
{
@private
	IBOutlet NSTextField		*textField;
	
	NSMutableArray				*_history;			// History buffer, newest lines at end
	NSUInteger					_historyMaxSize,	// Max allowable history entries
								_historyCurrSize,	// Current count
								_historyCursor;		// Index from end+1 -- 0 means new line, 1 means last entry in history
	NSString					*_latest;			// Last entered string when paging through history.
}

- (NSArray *) history;
- (void) setHistory:(NSArray *)history;

- (void) addToHistory:(NSString *)string;

- (NSUInteger) historySize;
- (void) setHistorySize:(NSUInteger)size;

@end

//
//  WWCardEditor.h
//  WWCardEditor
//
//  Created by Dan Grover on 6/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WWCardEditorRow.h"

@interface WWCardEditor : NSView {
	BOOL needsLayout;
	NSMutableArray *_rows;
	
	NSColor *keyLabelColor;
	NSFont *keyLabelFont;
	
	CGSize padding;
}


@property(assign) BOOL needsLayout;


// Row manipulation
@property(retain,readonly) NSArray *rows;
- (void) addRow:(WWCardEditorRow *)row;
- (void) addRow:(WWCardEditorRow *)row atIndex:(NSUInteger)newRowIndex;
- (void) removeRowAtIndex:(NSUInteger)removeRowIndex;

// Appearance
@property(retain) NSColor *keyLabelColor;
@property(retain) NSFont *keyLabelFont;
@property(assign) CGSize padding;

@end

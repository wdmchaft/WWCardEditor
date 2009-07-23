//
//  WWCardEditor.h
//  WWCardEditor
//
//  Created by Dan Grover on 6/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WWCardEditorRow.h"
#import "NSColor+Extras.h"

@interface WWCardEditor : NSView {
	BOOL needsLayout;
	BOOL editMode;
	NSMutableArray *_rows;
	
	NSColor *keyLabelColor;
	NSFont *keyLabelFont;
	CGSize padding;
	CGFloat rowSpacing;
	CGSize focusRingPadding;
	NSColor *backgroundColor;
	
	
	NSColor *focusRingBorderColor;
}

@property(assign) BOOL editMode;


// Row manipulation
@property(retain,readonly) NSArray *rows;
- (void) addRow:(WWCardEditorRow *)row;
- (void) addRow:(WWCardEditorRow *)row atIndex:(NSUInteger)newRowIndex;
- (void) removeRowAtIndex:(NSUInteger)removeRowIndex;

// Appearance
@property(retain) NSColor *keyLabelColor;
@property(retain) NSFont *keyLabelFont;
@property(retain) NSColor *backgroundColor;
@property(assign) CGSize padding;
@property(assign) CGFloat rowSpacing;

// Appearance: Focus Ring
@property(assign) CGSize focusRingPadding;
@property(retain) NSColor *focusRingBorderColor;

@end

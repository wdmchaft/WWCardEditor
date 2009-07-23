//
//  WWFlowingFieldContainer.h
//  WWCardEditor
//
//  Created by Dan Grover on 6/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WWFlowFieldSubfield.h"
#import "NSColor+Extras.h"
#import "WWCardEditorRow.h"

@interface WWFlowFieldRow : WWCardEditorRow {
	NSTextView *_textView;
	NSInteger activeField;
	NSArray *fields;
	CGFloat editBoxPadding;
	BOOL editMode;
	BOOL isRendering;
}

@property(retain) NSArray *fields;
@property(assign) NSInteger activeField;

@property(assign) BOOL editMode;

// Appearance
@property(assign) CGFloat editBoxPadding;

@end
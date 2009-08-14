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
	NSInteger activeSubfield;
	BOOL inUse;
	NSArray *subfields;
	NSMutableDictionary *_subfieldsNameIndex;
	BOOL isRendering;
}

@property(retain) NSArray *subfields;
- (NSDictionary *) subfieldsByName;

@property(assign) NSInteger activeSubfield;

@end
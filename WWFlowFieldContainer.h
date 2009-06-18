//
//  WWFlowingFieldContainer.h
//  WWCardEditor
//
//  Created by Dan Grover on 6/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WWFlowFields.h"
#import "NSColor+Extras.h"

@interface WWFlowFieldContainer : NSView {
	NSTextView *_textView;
	NSUInteger activeField;
	NSArray *fields;
	CGFloat editBoxPadding;
	BOOL editMode;
}

@property(retain) NSArray *fields;
@property(assign) NSUInteger activeField;

@property(assign) BOOL editMode;

// Appearance
@property(assign) CGFloat editBoxPadding;

@end



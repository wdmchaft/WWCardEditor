//
//  WWCardEditor_Internals.h
//  WWCardEditor
//
//  Created by Dan Grover on 7/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WWCardEditor.h"
@class WWFlowFieldRow;

// The row view responds to a number of methods that are used by the card editor
// to lay it out

@interface WWCardEditorRow()

@property(assign) WWCardEditor *parentEditor; // weak references to parents
@property(assign) WWCardEditorRow *parentRow; 
@property(assign) BOOL editMode;
@property(retain,readwrite) NSString *name;

- (CGFloat) neededHeight;
- (CGFloat) availableWidth;
- (NSRectArray) requestedFocusRectArrayAndCount:(NSUInteger *)count; // used for drawing those fancy drop shadow focus rings
+ (void) setDebugDrawMode:(BOOL)newVal;

- (NSArray *)principalResponders;
@end



@interface WWCardEditor()
@property(assign) BOOL needsLayout;

- (void) _selectNextRowResponder;
- (WWFlowFieldRow *)_firstRowWithResponder;
- (void) _selectPreviousRowResponder;
- (WWFlowFieldRow *)currentlyActiveRow;
@end
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

@interface WWCardEditorRow()

@property(assign) WWCardEditor *parentEditor; // weak references to parents
@property(assign) WWCardEditorRow *parentRow; 
@property(retain,readwrite) NSString *name;


- (CGFloat) neededHeight;
- (CGFloat) availableWidth;
- (NSRectArray) requestedFocusRectArrayAndCount:(NSUInteger *)count;
+ (void) setDebugDrawMode:(BOOL)newVal;

- (NSResponder *)principalResponder;
@end



@interface WWCardEditor()
@property(assign) BOOL needsLayout;

- (void) _selectNextRowResponder;
- (WWFlowFieldRow *)_firstRowWithResponder;
- (void) _selectPreviousRowResponder;
- (WWFlowFieldRow *)currentlyActiveRow;
@end
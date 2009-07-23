//
//  WWCardEditorRow.h
//  WWCardEditor
//
//  Created by Dan Grover on 6/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WWCardEditor;

@interface WWCardEditorRow : NSView {
	WWCardEditor *parentEditor;
	BOOL editMode;
}

@property(assign) WWCardEditor *parentEditor; // weak reference to parent

- (CGFloat) neededHeight;

@property(assign) BOOL editMode;

@end

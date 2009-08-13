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
	WWCardEditorRow *parentRow;
	BOOL editMode;
	NSString *name;
}

- (id)initWithName:(NSString *)theName;

@property(assign) BOOL editMode;
@property(retain,readonly) NSString *name;

@end

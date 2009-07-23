//
//  WWCheckboxRow.h
//  WWCardEditor
//
//  Created by Dan Grover on 7/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WWCardEditorRow.h"

@interface WWCheckboxRow : WWCardEditorRow {
	NSButton *checkbox;
	BOOL needsLayout;
}

@property(assign) BOOL isChecked;
@property(retain ) NSString *label;

@end

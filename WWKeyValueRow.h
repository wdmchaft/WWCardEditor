//
//  WWKeyValueRow.h
//  WWCardEditor
//
//  Created by Dan Grover on 6/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WWCardEditorRow.h"

@interface WWKeyValueRow : WWCardEditorRow {
	NSString *keyLabel;
	WWCardEditorRow *valueRowView;
	CGFloat splitPosition;
	BOOL needsLayout;
	BOOL hover;
}

@property(retain) NSString *keyLabel;
@property(retain) WWCardEditorRow *valueRowView;

@end


#define WWKeyValueRow_HorizontalBuffer 10
#define WWKeyValueRow_DefaultSplitPosition 80
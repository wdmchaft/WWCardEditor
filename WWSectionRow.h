//
//  WWSectionRow.h
//  WWCardEditor
//
//  Created by Dan Grover on 8/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WWCardEditorRow.h"
#import "WWAbstractContainerRow.h"

@interface WWSectionRow : WWAbstractContainerRow {
	NSButton *_disclosureTriangle;
	NSString *label;
	NSFont *labelFont;
	BOOL collapsed;
}

@property(retain) NSString *label;
@property(retain) NSFont *labelFont;
@property(assign) BOOL collapsed;


@end

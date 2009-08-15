//
//  WWSectionRow.h
//  WWCardEditor
//
//  Created by Dan Grover on 8/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WWCardEditorRow.h"

@interface WWSectionRow : WWCardEditorRow {
	NSMutableArray *_subrows;
	NSMutableDictionary *_subrowsByName;
	NSButton *_disclosureTriangle;
	
	NSString *label;
	NSFont *labelFont;
	BOOL _needsLayout;
	BOOL collapsed;
}

@property(retain) NSString *label;
@property(retain) NSFont *labelFont;
@property(assign) BOOL collapsed;

@property(retain,readonly) NSArray *subrows;

- (void) addSubrow:(WWCardEditorRow *)row;
- (void) insertSubrow:(WWCardEditorRow *)row atIndex:(NSUInteger)newRowIndex;
- (void) removeSubrowAtIndex:(NSUInteger)removeRowIndex;

@end

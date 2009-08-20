//
//  WWAbstractContainerRow.h
//  WWCardEditor
//
//  Created by Dan Grover on 8/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WWCardEditorRow.h"

@interface WWAbstractContainerRow : WWCardEditorRow {
	NSMutableArray *_subrows;
	NSMutableDictionary *_subrowsByName;
	BOOL _needsLayout;
}

@property(retain,readonly) NSArray *subrows;
- (void) addSubrow:(WWCardEditorRow *)row;
- (void) insertSubrow:(WWCardEditorRow *)row atIndex:(NSUInteger)newRowIndex;
- (void) removeSubrowAtIndex:(NSUInteger)removeRowIndex;

@end
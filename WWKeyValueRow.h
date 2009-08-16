//
//  WWKeyValueRow.h
//  WWCardEditor
//
//  Created by Dan Grover on 6/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WWCardEditorRow.h"

@protocol WWKeyValueRowDelegate;

@interface WWKeyValueRow : WWCardEditorRow {
	NSPopUpButton *_keyButton;
	NSArray *keyTypeIdentifiers;
	NSDictionary *keyTypeLabels;
	
	WWCardEditorRow *valueRowView;
	
	CGFloat splitPosition;
	BOOL _needsLayout;
	BOOL hover;
	NSObject<WWKeyValueRowDelegate> *delegate;
	
}

@property(retain) NSString *activeKeyType;
@property(retain) NSArray *keyTypeIdentifiers; 
@property(retain) NSDictionary *keyTypeLabels; // key identifier -> localized key name

@property(retain) WWCardEditorRow *valueRowView;

@end

#pragma mark -

@protocol WWKeyValueRowDelegate
- (void) keyValueRow:(WWKeyValueRow *)theRow choseKeyType:(NSString *)keyTypeIdentifier;
@end
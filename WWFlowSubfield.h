//
//  WWFlowFields.h
//  WWCardEditor
//
//  Created by Dan Grover on 6/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WWFlowSubfield : NSObject{
	NSString *name;
	NSString *value;
	NSFont *font;
	NSString *placeholder;
	BOOL editable;
}

// Initializers
- (id) initWithName:(NSString *)theName;
+ (WWFlowSubfield *) editableFieldWithName:(NSString *)fieldName placeholder:(NSString *)placeholderString initialValue:(NSString *)initialValue;
+ (WWFlowSubfield *) uneditableFieldWithName:(NSString *)fieldName initialValue:(NSString *)initialValue;
+ (WWFlowSubfield *) uneditableSpace;
+ (WWFlowSubfield *) uneditableNewline;

// Properties
@property(retain) NSString *name;
@property(retain) NSString *value;
@property(retain) NSFont *font;
@property(retain) NSString *placeholder;
@property(assign) BOOL editable;

@end

//
//  WWFlowFields.h
//  WWCardEditor
//
//  Created by Dan Grover on 6/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WWFlowFieldSubfield : NSObject{
	NSString *name;
	NSString *value;
	NSFont *font;
	NSString *placeholder;
	BOOL editable;
}

// Initializers
- (id) initWithName:(NSString *)theName;

+ (WWFlowFieldSubfield *) editableSubfieldWithName:(NSString *)fieldName placeholder:(NSString *)placeholderString initialValue:(NSString *)initialValue;
+ (WWFlowFieldSubfield *) uneditableSubfieldWithName:(NSString *)fieldName initialValue:(NSString *)initialValue;

+ (WWFlowFieldSubfield *) uneditableSpace;
+ (WWFlowFieldSubfield *) uneditableNewline;

// Properties
@property(retain) NSString *name; // TODO make readonly
@property(retain) NSString *value;
@property(retain) NSFont *font;
@property(retain) NSString *placeholder;
@property(assign) BOOL editable;

@end

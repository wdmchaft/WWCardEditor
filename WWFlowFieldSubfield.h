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
	BOOL allowsNewlines;
}

// Initializers
- (id) initWithName:(NSString *)theName;

+ (WWFlowFieldSubfield *) editableSubfieldWithName:(NSString *)fieldName placeholder:(NSString *)placeholderString initialValue:(NSString *)initialValue;
+ (WWFlowFieldSubfield *) uneditableSubfieldWithName:(NSString *)fieldName initialValue:(NSString *)initialValue;

+ (WWFlowFieldSubfield *) uneditableSpace;
+ (WWFlowFieldSubfield *) uneditableNewline;

/// Takes a format string and a (string -> wwflowfieldsubfield) dictionary and produces 
/// a series of WWFlowFieldSubfields, such that:
///   * the matching substrings in the format string are replaced with the fields in the dictionary
///   * the intervening non-matching substrings are replaced with uneditable fields with those substrings as their values
+ (NSArray *)subfieldsWithFormat:(NSString *)format tokensAndReplacements:(NSDictionary *)subs;

// Properties
@property(retain,readonly) NSString *name; 
@property(retain) NSString *value;
@property(retain) NSFont *font;
@property(retain) NSString *placeholder;
@property(assign) BOOL editable;
@property(assign) BOOL allowsNewlines;

@end

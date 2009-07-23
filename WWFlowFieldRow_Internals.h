//
//  WWFlowFieldContainer_Internals.h
//  WWCardEditor
//
//  Created by Dan Grover on 6/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WWFlowFieldRow()
@property(retain) NSTextView *_textView;

- (NSAttributedString *) _renderedText;

- (NSUInteger) _indexOfFieldForCharOffset:(NSUInteger)offsetDesired;

- (NSUInteger) _charOffsetForBeginningOfFieldAtIndex:(NSUInteger)fieldIndex;
- (NSUInteger) _charOffsetForEndOfFieldAtIndex:(NSUInteger)fieldIndex;
- (NSRange) _rangeForFieldAtIndex:(NSUInteger)fieldIndex;

- (BOOL) _fieldShouldBeDisplayedAsPlaceholder:(WWFlowFieldSubfield *)field;

- (NSDictionary *)_attributesForSubfield:(WWFlowFieldSubfield *)field;
- (NSString *) _displayedStringForField:(WWFlowFieldSubfield *)field;
@end

#define WWFlowFieldContainer_DefaultEditBoxPadding 1
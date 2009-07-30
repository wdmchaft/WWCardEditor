//
//  WWFlowingFieldContainer.m
//  WWCardEditor
//
//  Created by Dan Grover on 6/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WWFlowFieldRow.h"
#import "WWFlowFieldRowTextView.h"

#import "WWFlowFieldRow_Internals.h"
#import "WWCardEditor_Internals.h"

#pragma mark -

@implementation WWFlowFieldRow
@synthesize _textView, activeField, isRendering, inUse;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		WWFlowFieldRowTextView *view = [[[WWFlowFieldRowTextView alloc] initWithFrame:NSMakeRect(0,0,frame.size.width,frame.size.height)] autorelease];
		view.container = self;
		self._textView = view;
		
		[_textView setDelegate:self];
		[_textView setContinuousSpellCheckingEnabled:NO];
		[_textView setEditable:YES];
		[_textView setDrawsBackground:NO];
		[_textView setTextContainerInset:NSMakeSize(0,0)];
		[_textView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
		[self setAutoresizesSubviews:YES];
		[self addSubview:_textView];
		
		[self setEditMode:NO];
    }
	
    return self;
}


- (void)setNeedsDisplay{
	[self setNeedsDisplay:YES];
	[[self parentEditor] setNeedsDisplay:YES];
	[_textView setNeedsDisplay:YES];
}

- (void) dealloc{
	self._textView = nil;
	self.fields = nil;
	[super dealloc];
}

- (NSString *)description{
	return [NSString stringWithFormat:@"<WWFlowFieldRow: fields = %@",fields];
}

#pragma mark -
#pragma mark Accessors

- (NSArray *)fields {
    return fields; 
}

- (void)setFields:(NSArray *)aFields {
    if (fields != aFields) {
        [fields release];
        fields = [aFields retain];
    }
	
//	[_textView resignFirstResponder];
	[[_textView textStorage] setAttributedString:[self _renderedText]];
	//[self setActiveField:NSNotFound];
}

- (NSInteger)activeField {
    return activeField;
}

- (void)setActiveField:(NSInteger)anActiveField {
	if(anActiveField >= [fields count]){
		return;
	}
	
	NSUInteger oldField = activeField;
    activeField = anActiveField;
	
	if(activeField != oldField){
		if(!inUse){ // If there's no field selected, then make no text selected
			if([_textView selectedRange].location != NSNotFound){
				[_textView setSelectedRange: NSMakeRange(0, 0)];
			}
		}else{ // Otherwise, select all text in the new active field
			[_textView setSelectedRange:[self _rangeForFieldAtIndex:activeField]];
		}
	}
}

- (BOOL)editMode {
    return editMode;
}

- (void)setEditMode:(BOOL)flag {
	if(editMode != flag){
		
		[_textView setEditable:flag];
		[[_textView textStorage] setAttributedString:[self _renderedText]];
		
		if(editMode != flag){
			if(editMode){ // coming out of edit mode
				//self.activeField = NSNotFound;
			}else{ // going into edit mode
				//self.activeField = 0;
			}
		}
		
		editMode = flag;
		
		
		[self setNeedsDisplay];
		[[self superview] setNeedsDisplay:YES];
	}
}


#pragma mark -
#pragma mark Helpers

- (NSAttributedString *) _renderedText{
	NSMutableAttributedString *soFar = [[[NSMutableAttributedString alloc] initWithString:@""] autorelease];
	
	for(WWFlowFieldSubfield *field in fields){
		[soFar appendAttributedString:[[[NSAttributedString alloc] initWithString:[self _fieldShouldBeDisplayedAsPlaceholder:field] ? field.placeholder : field.value
																	   attributes:[self _attributesForSubfield:field]] autorelease]];
	}
	
	return soFar;
}


- (NSDictionary *)_attributesForSubfield:(WWFlowFieldSubfield *)field{
	if([self _fieldShouldBeDisplayedAsPlaceholder:field]){
		NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
		[attrs setObject:field.font forKey:NSFontAttributeName];
		[attrs setObject:[NSColor lightGrayColor] forKey:NSForegroundColorAttributeName];
		return attrs;
	}else{
		return [NSDictionary dictionaryWithObject:field.font forKey:NSFontAttributeName];
	}
}

- (NSUInteger) _indexOfFieldForCharOffset:(NSUInteger)offsetDesired{
	
	unsigned offsetReached = 0;
	
	for(NSUInteger i = 0; i < [fields count]; i++){
		WWFlowFieldSubfield *field = [fields objectAtIndex:i];
		unsigned len = [[self _displayedStringForField:field] length];
		
		if((offsetDesired >= offsetReached) && (offsetDesired < (offsetReached+len))){
			return i;
		}
		
		offsetReached += len;
	}
	
	return NSNotFound;
}

- (NSUInteger) _charOffsetForBeginningOfFieldAtIndex:(NSUInteger)fieldIndex{
	if(fieldIndex >= [fields count]){
		return NSNotFound;
	}
	
	NSUInteger soFar = 0;
	
	for(NSUInteger i = 0; i <= fieldIndex; i++){
		if(i == fieldIndex){
			return soFar;
		}else{
			WWFlowFieldSubfield *field = [fields objectAtIndex:i];
			soFar += [[self _displayedStringForField:field] length];
		}
	}
	
	return NSNotFound;
}

- (NSUInteger) _charOffsetForEndOfFieldAtIndex:(NSUInteger)fieldIndex{
	if(fieldIndex >= [fields count]){
		return NSNotFound;
	}
	
	NSUInteger beginning = [self _charOffsetForBeginningOfFieldAtIndex:fieldIndex];
	if(beginning == NSNotFound){
		return NSNotFound;
	}
	
	WWFlowFieldSubfield *field = [fields objectAtIndex:fieldIndex];
	return beginning + [[self _displayedStringForField:field] length];
}


- (NSRange) _rangeForFieldAtIndex:(NSUInteger)fieldIndex{
	if(fieldIndex >= [fields count]){
		return NSMakeRange(NSNotFound, 0);
	}

	WWFlowFieldSubfield *field = [fields objectAtIndex:fieldIndex];
	
	return NSMakeRange([self _charOffsetForBeginningOfFieldAtIndex:fieldIndex], [[self _displayedStringForField:field] length]);
}

- (BOOL) _fieldShouldBeDisplayedAsPlaceholder:(WWFlowFieldSubfield *)field{
	return (editMode && field.placeholder && (!field.value || [field.value isEqual:@""]));
}

- (NSString *)_displayedStringForField:(WWFlowFieldSubfield *)field{
	return [self _fieldShouldBeDisplayedAsPlaceholder:field] ? field.placeholder : field.value;
}

#pragma mark -
#pragma mark Text View Delegate

- (NSRange)textView:(NSTextView *)textView willChangeSelectionFromCharacterRange:(NSRange)oldSelectedCharRange toCharacterRange:(NSRange)newSelectedCharRange{
	[self setNeedsDisplay];
	
	if(isRendering){
		return newSelectedCharRange;
	}
	
	NSLog(@"oldRange = %@, newRange = %@",NSStringFromRange(oldSelectedCharRange),NSStringFromRange(newSelectedCharRange));
	
	
	if(!editMode || !inUse){
		return newSelectedCharRange; // If we're not in edit mode, they can select anything they want
	}
	
	if (newSelectedCharRange.location == NSNotFound){
		NSLog(@"Allowing no selection");
		return newSelectedCharRange; // no selection, that's cool.
	}
	
	NSUInteger fieldIndex = [self _indexOfFieldForCharOffset:newSelectedCharRange.location];
	if(fieldIndex == NSNotFound){
		// This could mean that they're changing the insertion point to the very end of the text, and the very end of the last mutable field.
		// Or it could mean they're trying to change the selection to none (by clicking on an invalid field), so we just set the field to Not Found and let them have no active field selected.
		
		if((newSelectedCharRange.location == [[_textView string] length]) && [[fields lastObject] editable]){
			self.activeField = [fields count] - 1; // this is where it changes it
		}else{
			self.activeField = NSNotFound;
		}
		
		return newSelectedCharRange;
	}
	
	// Check that we don't cross fields
	NSUInteger fieldStartChar = [self _charOffsetForBeginningOfFieldAtIndex:fieldIndex];
	NSUInteger fieldEndChar   = [self _charOffsetForEndOfFieldAtIndex:fieldIndex];
	
	if(fieldIndex != activeField){
		WWFlowFieldSubfield *field = [fields objectAtIndex:fieldIndex];
		
		// Figure out if they're just trying to type at the end of this field or fuck with the next one
		if((fieldIndex == (activeField + 1)) && (newSelectedCharRange.length == 0) && (newSelectedCharRange.location == fieldStartChar)){
			return newSelectedCharRange; // allow it. We interpret this scenario in -textView:shouldChangeTextInRange:replacementString:
		}

		// Allow them to change to the new field, but not if it's immutable or nonexistent 
		if(!field || !field.editable){
			NSLog(@"REJECTED AT CHANGE: immutable field");
			return oldSelectedCharRange;
		}
		else{
			// Okay, that's cool, you can change fields, but we're gonna have to select the whole field
			self.activeField = fieldIndex;
			return NSMakeRange(fieldStartChar, [[self _displayedStringForField:field] length]);
		}
	}
	
	return newSelectedCharRange;
}


- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString{
	NSLog(@"Changing text in range %@ (%@), new string = %@",NSStringFromRange(affectedCharRange), [[textView string] substringWithRange:affectedCharRange],  replacementString);
	[parentEditor setNeedsLayout:YES];
	[self setNeedsDisplay];
	
	if(!editMode || !inUse){
		return NO;
	}
	
	
	
	NSUInteger startFieldIndex = [self _indexOfFieldForCharOffset:affectedCharRange.location];
	NSUInteger endFieldIndex   = [self _indexOfFieldForCharOffset:affectedCharRange.location + affectedCharRange.length];
	NSUInteger startFieldStartChar = [self _charOffsetForBeginningOfFieldAtIndex:startFieldIndex];
	NSUInteger endFieldStartChar = [self _charOffsetForBeginningOfFieldAtIndex:endFieldIndex];
	
	// First things first: we want to block any edit that crosses subfields, that's a no-no.
	// However, there are two cases where this is fine:
	// - Pressing delete at the end of a field (which is technically the start of the next)
	// - Doing the above, but where the "next" is NSNotFound (which is the case if we're pressing delete at the end of the last field)
	
	if((startFieldIndex != endFieldIndex)){
		NSLog(@"ATTEMPTING TO CHANGE TEXT CROSS-FIELDS...startField = %d, endField = %d",startFieldIndex,endFieldIndex);
		if(((affectedCharRange.location + affectedCharRange.length) == endFieldStartChar) || (endFieldIndex == NSNotFound)){
			
			NSLog(@"But that's cool...startField = %d, endField = %d",startFieldIndex,endFieldIndex);
		}else{
			NSLog(@"NO NO");
			return NO;
		}
	}
	
	// Newlines are not allowed in these fields
	// If someone enters or pastes one, we're going to strip it, and then handle the updating of the textView ourselves (by returning NO).
	NSString *newlineScrubbedReplacementString = [[replacementString stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	
	// Override the textview's handling all the time for now
	BOOL overrideHandling = YES; //[newlineScrubbedReplacementString isEqual:replacementString]; 
	
	// TODO decide on if we should only conditionally override the textview's insertion of text or 
	// do it ALL the time (could be performance reasons for doing it conditionally)
	
	// Could possible use the "marked text" stuff
	
	BOOL fieldWasAPlaceholderBefore = NO;
	WWFlowFieldSubfield *relevantField = nil;
	
	// Anyway...
	// If we are in the middle of an editable subfield, just replace the equivilent range in the subfield's .value property.
	// If we're at the *end* of an editable subfield (but in reality just a 0-len selection at the start of the next), then append the text.
	
	if((startFieldIndex == NSNotFound) || ((affectedCharRange.length == 0) && (affectedCharRange.location == startFieldStartChar) && (startFieldIndex == (activeField + 1)))){
		relevantField = [fields objectAtIndex:activeField];
		
		fieldWasAPlaceholderBefore = [self _fieldShouldBeDisplayedAsPlaceholder:relevantField];
		relevantField.value = [[self _displayedStringForField:relevantField] stringByAppendingString:newlineScrubbedReplacementString];

	}else{
		NSRange localRange = NSMakeRange(affectedCharRange.location - startFieldStartChar, affectedCharRange.length); // translate affectedCharRange to be in terms of this string only
		relevantField = [fields objectAtIndex:startFieldIndex];
		
		fieldWasAPlaceholderBefore = [self _fieldShouldBeDisplayedAsPlaceholder:relevantField];
		relevantField.value = [[self _displayedStringForField:relevantField] stringByReplacingCharactersInRange:localRange withString:newlineScrubbedReplacementString];
	}

	
	BOOL fieldWasAPlaceholderAfterwards = [self _fieldShouldBeDisplayedAsPlaceholder:relevantField];
	
	// If we changed between a placeholder and not one, then that is also a reason to override the nstextview's normal handling of this event
	overrideHandling = overrideHandling || (fieldWasAPlaceholderBefore != fieldWasAPlaceholderAfterwards);
	
	if(overrideHandling){
		// If this is reached, we're going to put the new text there on behalf of the textfield since it would have put the return-carriage-laden
		// text in its place (or for some other reason)
		
		NSRange oldSelectedRange = [_textView selectedRange]; // Remember the old selection range to give the appearance that the textField is handling this action, not us
		NSRange newSelectedRange = oldSelectedRange;
		
		isRendering = YES;
		[[_textView textStorage] setAttributedString:[self _renderedText]];
		
		if(!fieldWasAPlaceholderBefore && fieldWasAPlaceholderAfterwards){
			newSelectedRange = [self _rangeForFieldAtIndex:[fields indexOfObject:relevantField]]; // TODO clean up
		}
		else{
			
			
			if(!newlineScrubbedReplacementString.length){
				NSLog(@"Delete key handling");
				newSelectedRange.location -= 1;
			}else{
				newSelectedRange.location += newlineScrubbedReplacementString.length;
			}
			
			newSelectedRange.length = 0;
		}
		
		[_textView setSelectedRange:newSelectedRange];
		isRendering = NO;
		
		[self setNeedsDisplay];
		return NO;
	}
	else{
		[self setNeedsDisplay];
		return YES;
	}
}

#pragma mark -
#pragma mark Overrides

- (CGFloat) neededHeight{
	CGFloat available = parentRow ? [parentRow availableWidth] : ([parentEditor frame].size.width - [parentEditor padding].width*2);
	
	NSRect boundingRect = [[self _renderedText] boundingRectWithSize:NSMakeSize(available,INT_MAX) 
															 options:NSStringDrawingUsesLineFragmentOrigin];
	
	return boundingRect.size.height;
}


- (NSRectArray) requestedFocusRectArrayAndCount:(NSUInteger *)count{
	if(!editMode || ([[self window] firstResponder] != _textView)){
		return [super requestedFocusRectArrayAndCount:count];
	}
	
	NSRange activeFieldRange = [self _rangeForFieldAtIndex:self.activeField];
	NSUInteger rectCount = 0;
	NSRectArray rects = [[_textView layoutManager] rectArrayForCharacterRange:activeFieldRange 
												 withinSelectedCharacterRange:NSMakeRange(NSNotFound, 0) 
															  inTextContainer:[_textView textContainer] 
																	rectCount:&rectCount];
	
	*count = rectCount;
	return rects;
}

- (CGFloat) availableWidth{
	NSLog(@"Getting avail width for flow field....-%d",[[self _renderedText] size].width);
	return [super availableWidth] - [[self _renderedText] size].width;
}

- (NSResponder *)principalResponder{
	return _textView;
}


#pragma mark -

- (void) _selectNextSubfieldOrRow{
	if(activeField == ([fields count] - 1)){
		NSLog(@"At last subfield, telling parent to get next row resp");
		[parentEditor _selectNextRowResponder];
		return;
	}
	
	for(NSUInteger i = activeField + 1; i < [fields count]; i++){
		WWFlowFieldSubfield *subfield = [fields objectAtIndex:i];
		if(subfield.editable){
			self.activeField = i;
			return;
		}
	}
	
	// Must be no more editable fields if we're still running, go to the next one
	[parentEditor _selectNextRowResponder];
}


- (void) _selectPreviousSubfieldOrRow{
	if(activeField == 0){
		[parentEditor _selectPreviousRowResponder];
		return;
	}
	
	for(NSUInteger i = activeField - 1; i >= 0; i--){
		WWFlowFieldSubfield *subfield = [fields objectAtIndex:i];
		if(subfield.editable){
			self.activeField = i;
			return;
		}
	}
	
	// If we can't find any subfield by this point that we can switch to, then have the parent go to the previous row
	[parentEditor _selectPreviousRowResponder];
}

- (void) _selectFirstEditableSubfield{
	for(NSUInteger i = 0; i < [fields count]; i++){
		if([[fields objectAtIndex:i] editable]){
			[self setActiveField:i];
			return;
		}
	}
}

- (void) _selectLastEditableSubfield{
	for(NSUInteger i = ([fields count] - i); i >= 0; i--){
		if([[fields objectAtIndex:i] editable]){
			NSLog(@"Looking at %d / %d",i,[fields count]-1);
			[self setActiveField:i];
			return;
		}
	}
}

@end
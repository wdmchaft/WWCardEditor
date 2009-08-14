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
@synthesize _textView, activeSubfield, isRendering, inUse, _subfieldsNameIndex;

- (id)initWithName:(NSString *)theName {
    if (self = [super initWithName:theName]){
		WWFlowFieldRowTextView *view = [[[WWFlowFieldRowTextView alloc] initWithFrame:NSMakeRect(0,0,[self frame].size.width,[self frame].size.height)] autorelease];
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
		
		self._subfieldsNameIndex = [NSMutableDictionary dictionary];
		
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
	self._subfieldsNameIndex = nil;
	self.subfields = nil;
	[super dealloc];
}

- (NSString *)description{
	return [NSString stringWithFormat:@"<WWFlowFieldRow: subfields = %@",subfields];
}

+ (void) initialize{
	[self exposeBinding:@"subfields"];
	[self exposeBinding:@"subfieldsByName"];
}

#pragma mark -
#pragma mark Accessors

- (NSArray *)subfields {
    return subfields; 
}

- (void)setSubfields:(NSArray *)aFields {
	
	// Stop observing our old subfields
	//for(WWFlowFieldSubfield *subfield in subfields){
	//	[subfield removeObserver:self forKeyPath:@"value"];
	//	[subfield removeObserver:self forKeyPath:@"placeholder"];
	//}
	
	// Do the actual setting
    if (subfields != aFields) {
        [subfields release];
        subfields = [aFields retain];
    }
	
//	[_textView resignFirstResponder];
	[[_textView textStorage] setAttributedString:[self _renderedText]];
	//[self setActiveField:NSNotFound];
	
	[self willChangeValueForKey:@"subfieldsByName"];
	
	self._subfieldsNameIndex = [NSMutableDictionary dictionary];
	for(WWFlowFieldSubfield *subfield in subfields){
		
		if([subfield name]){ 
			[_subfieldsNameIndex setObject:subfield forKey:[subfield name]];
		}
		
		[subfield addObserver:self forKeyPath:@"value" options:0 context:nil];
		[subfield addObserver:self forKeyPath:@"placeholder" options:0 context:nil];
	}
	
	[self didChangeValueForKey:@"subfieldsByName"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	//NSLog(@"Got change %@ for object %@ on key path %@",change,object,keyPath);
	if(!inUse && [subfields containsObject:object]){
		[[_textView textStorage] setAttributedString:[self _renderedText]];
	}
}



- (NSDictionary *) subfieldsByName{
	return _subfieldsNameIndex;
}

- (NSInteger)activeSubfield {
    return activeSubfield;
}

- (void)setActiveSubfield:(NSInteger)anActiveField {
	if(anActiveField >= [subfields count]){
		return;
	}
	
	NSUInteger oldField = activeSubfield;
    activeSubfield = anActiveField;
	
	if(activeSubfield != oldField){
		if(!inUse){ // If there's no field selected, then make no text selected
			if([_textView selectedRange].location != NSNotFound){
				[_textView setSelectedRange: NSMakeRange(0, 0)];
			}
		}else{ // Otherwise, select all text in the new active field
			[_textView setSelectedRange:[self _rangeForFieldAtIndex:activeSubfield]];
		}
	}
}

- (BOOL)editMode {
    return editMode;
}

- (void)setEditMode:(BOOL)flag {
	if(editMode != flag){
		
		if(editMode != flag){
			if(editMode){ // coming out of edit mode
				//self.activeSubfield = NSNotFound;
			}else{ // going into edit mode
				//self.activeSubfield = 0;
			}
		}
		
		editMode = flag;
		
		[_textView setEditable:flag];
		[[_textView textStorage] setAttributedString:[self _renderedText]];
		
		
		[self setNeedsDisplay];
		[[self superview] setNeedsDisplay:YES];
	}
}


#pragma mark -
#pragma mark Helpers

- (NSAttributedString *) _renderedText{
	NSMutableAttributedString *soFar = [[[NSMutableAttributedString alloc] initWithString:@""] autorelease];
	
	for(WWFlowFieldSubfield *field in subfields){
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
	
	for(NSUInteger i = 0; i < [subfields count]; i++){
		WWFlowFieldSubfield *field = [subfields objectAtIndex:i];
		unsigned len = [[self _displayedStringForField:field] length];
		
		if((offsetDesired >= offsetReached) && (offsetDesired < (offsetReached+len))){
			return i;
		}
		
		offsetReached += len;
	}
	
	return NSNotFound;
}

- (NSUInteger) _charOffsetForBeginningOfFieldAtIndex:(NSUInteger)fieldIndex{
	if(fieldIndex >= [subfields count]){
		return NSNotFound;
	}
	
	NSUInteger soFar = 0;
	
	for(NSUInteger i = 0; i <= fieldIndex; i++){
		if(i == fieldIndex){
			return soFar;
		}else{
			WWFlowFieldSubfield *field = [subfields objectAtIndex:i];
			soFar += [[self _displayedStringForField:field] length];
		}
	}
	
	return NSNotFound;
}

- (NSUInteger) _charOffsetForEndOfFieldAtIndex:(NSUInteger)fieldIndex{
	if(fieldIndex >= [subfields count]){
		return NSNotFound;
	}
	
	NSUInteger beginning = [self _charOffsetForBeginningOfFieldAtIndex:fieldIndex];
	if(beginning == NSNotFound){
		return NSNotFound;
	}
	
	WWFlowFieldSubfield *field = [subfields objectAtIndex:fieldIndex];
	return beginning + [[self _displayedStringForField:field] length];
}


- (NSRange) _rangeForFieldAtIndex:(NSUInteger)fieldIndex{
	if(fieldIndex >= [subfields count]){
		return NSMakeRange(NSNotFound, 0);
	}

	WWFlowFieldSubfield *field = [subfields objectAtIndex:fieldIndex];
	
	return NSMakeRange([self _charOffsetForBeginningOfFieldAtIndex:fieldIndex], [[self _displayedStringForField:field] length]);
}

- (BOOL) _fieldShouldBeDisplayedAsPlaceholder:(WWFlowFieldSubfield *)field{
	return (editMode && field && field.editable && field.placeholder && (!field.value || [field.value isEqual:@""]));
}

- (NSString *)_displayedStringForField:(WWFlowFieldSubfield *)field{
	return [self _fieldShouldBeDisplayedAsPlaceholder:field] ? field.placeholder : field.value;
}

#pragma mark -
#pragma mark Text View Delegate

- (NSRange)textView:(NSTextView *)textView willChangeSelectionFromCharacterRange:(NSRange)oldSelectedCharRange toCharacterRange:(NSRange)newSelectedCharRange{
	[self setNeedsDisplay];
	
	// If it's not the user triggering this, let it go.
	if(isRendering) return newSelectedCharRange; 
	
	// If we're not in edit mode, they can select anything they want
	if(!editMode || !inUse) return newSelectedCharRange; 
	
	// It's fine to not select anything
	if (newSelectedCharRange.location == NSNotFound){
		NSLog(@"Allowing no selection");
		return newSelectedCharRange; 
	}
	
	
	NSUInteger fieldIndex = [self _indexOfFieldForCharOffset:newSelectedCharRange.location];
	if(fieldIndex == NSNotFound){
		// This could mean that they're changing the insertion point to the very end of the text, and the very end of the last mutable field.
		// Or it could mean they're trying to change the selection to none (by clicking on an invalid field), so we just set the field to Not Found and let them have no active field selected.
		
		if((newSelectedCharRange.location == [[_textView string] length]) && [[subfields lastObject] editable]){
			NSLog(@"changing subfield from %d to %d",activeSubfield,[subfields count] - 1);
			self.activeSubfield = [subfields count] - 1; // this is where it changes it
		}else{
			self.activeSubfield = NSNotFound;
		}
		
		// Allow the selection unless this last field happens to be a placeholder (in which case, they still have to select all of it)
		if([self _fieldShouldBeDisplayedAsPlaceholder:[subfields objectAtIndex:activeSubfield]]){
			return [self _rangeForFieldAtIndex:activeSubfield];
		}else{
			return newSelectedCharRange;
		}
	}
	
	// Check that we don't cross subfields
	NSUInteger fieldStartChar = [self _charOffsetForBeginningOfFieldAtIndex:fieldIndex];
	NSUInteger fieldEndChar   = [self _charOffsetForEndOfFieldAtIndex:fieldIndex];
	WWFlowFieldSubfield *field = [subfields objectAtIndex:fieldIndex];
	
	if(fieldIndex != activeSubfield){
		// Figure out if they're just trying to type at the end of this field or fuck with the next one
		if((fieldIndex == (activeSubfield + 1)) && (newSelectedCharRange.length == 0) && (newSelectedCharRange.location == fieldStartChar)){
			// They're typing at the end of a field (even though it looks like the next one).
			// This is fine UNLESS the field should be a placeholder, in which we must select the entirety of the field
			if([self _fieldShouldBeDisplayedAsPlaceholder:[subfields objectAtIndex:activeSubfield]]){
				return [self _rangeForFieldAtIndex:activeSubfield];
			}else{
				return newSelectedCharRange; // allow it. We interpret this scenario in -textView:shouldChangeTextInRange:replacementString:
			}
		}

		// Allow them to change to the new field, but not if it's immutable or nonexistent 
		if(!field || !field.editable){
			NSLog(@"REJECTED AT CHANGE: immutable field");
			return oldSelectedCharRange;
		}
		else{
			// Okay, that's cool, you can change subfields, but we're gonna have to select the whole field
			self.activeSubfield = fieldIndex;
			return NSMakeRange(fieldStartChar, [[self _displayedStringForField:field] length]);
		}
	}
	
	// Additional hack-ish checks concerning placeholders: if the subfield is a placeholder, make sure they select all of it.
	
	// Prevent left-arrowing to put the insertion point at the start of the subfield
	if([self _fieldShouldBeDisplayedAsPlaceholder:[subfields objectAtIndex:fieldIndex]]){
		NSLog(@"MODIFIED AT CHANGE: Must select entirety of placeholder field");
		return NSMakeRange(fieldStartChar, [[self _displayedStringForField:field] length]);
	}

	NSLog(@"No objections in field row");
	return newSelectedCharRange;
}



- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString{
	[parentEditor setNeedsLayout:YES];
	[self setNeedsDisplay];
	
	if(!editMode || !inUse) return NO; 
	
	// Gather info we need
	NSUInteger startFieldIndex = [self _indexOfFieldForCharOffset:affectedCharRange.location];
	NSUInteger endFieldIndex   = [self _indexOfFieldForCharOffset:affectedCharRange.location + affectedCharRange.length];
	NSUInteger startFieldStartChar = [self _charOffsetForBeginningOfFieldAtIndex:startFieldIndex];
	NSUInteger endFieldStartChar = [self _charOffsetForBeginningOfFieldAtIndex:endFieldIndex];
	
	NSRange oldMarkedRange = [textView markedRange];
	NSRange oldSelectedCharRange = [textView selectedRange];
	
	
	NSLog(@"Changing text in range %@ (%@), new string = %@, marked range = %@, selected range = %@",
		  NSStringFromRange(affectedCharRange), 
		  [[textView string] substringWithRange:affectedCharRange],  
		  replacementString,
		  NSStringFromRange(oldMarkedRange),
		  NSStringFromRange(oldSelectedCharRange));
	
	
	// First things first: we want to block any edit that crosses subsubfields, that's a no-no.
	// However, there are two cases where this is fine:
	// - Pressing delete at the end of a field (which is technically the start of the next)
	// - Doing the above, but where the "next" is NSNotFound (which is the case if we're pressing delete at the end of the last field)
	
	if((startFieldIndex != endFieldIndex)){
		NSLog(@"ATTEMPTING TO CHANGE TEXT CROSS-FIELDS...startField = %d, endField = %d",startFieldIndex,endFieldIndex);
		if(((affectedCharRange.location + affectedCharRange.length) == endFieldStartChar) || (endFieldIndex == NSNotFound)){
			NSLog(@"startField = %d endField = %d (starts at %d, char range is %@)",startFieldIndex,endFieldIndex,endFieldStartChar,NSStringFromRange(affectedCharRange));
			if(![replacementString length] && (oldSelectedCharRange.location <= affectedCharRange.location)){ // If we're forward-deleting...
				
				return NO; // This is not cool because it affects the next field.
			}
			
			NSLog(@"ok, that's fine");
			
			
		}else{
			return NO;
		}
	}
	
		
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
	
	// Newlines are not allowed in some subfields...if someone enters or pastes one, we're going to strip it, and then handle the updating of the textView ourselves (by returning NO).
	NSString *newlineScrubbedReplacementString = [[replacementString stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	NSString *usedReplacementString;
	if((startFieldIndex == NSNotFound) || ((affectedCharRange.length == 0) && (affectedCharRange.location == startFieldStartChar) && (startFieldIndex == (activeSubfield + 1)))){
		relevantField = [subfields objectAtIndex:activeSubfield];
		usedReplacementString = [relevantField allowsNewlines] ? replacementString : newlineScrubbedReplacementString;
		
		fieldWasAPlaceholderBefore = [self _fieldShouldBeDisplayedAsPlaceholder:relevantField];
		relevantField.value = [[self _displayedStringForField:relevantField] stringByAppendingString:usedReplacementString];

	}else{
		NSRange localRange = NSMakeRange(affectedCharRange.location - startFieldStartChar, affectedCharRange.length); // translate affectedCharRange to be in terms of this string only
		relevantField = [subfields objectAtIndex:startFieldIndex];
		usedReplacementString = [relevantField allowsNewlines] ? replacementString : newlineScrubbedReplacementString;
		
		fieldWasAPlaceholderBefore = [self _fieldShouldBeDisplayedAsPlaceholder:relevantField];
		relevantField.value = [[self _displayedStringForField:relevantField] stringByReplacingCharactersInRange:localRange withString:usedReplacementString];
	}

	
	BOOL fieldWasAPlaceholderAfterwards = [self _fieldShouldBeDisplayedAsPlaceholder:relevantField];
	
	// If we changed between a placeholder and not one, then that is also a reason to override the nstextview's normal handling of this event
	overrideHandling = overrideHandling || (fieldWasAPlaceholderBefore != fieldWasAPlaceholderAfterwards);
	
	if(overrideHandling){
		// If this is reached, we're going to put the new text there on behalf of the textfield since it would have put the return-carriage-laden
		// text in its place (or for some other reason)
		
		NSRange newSelectedCharRange = oldSelectedCharRange;
		
		isRendering = YES;
		[[_textView textStorage] setAttributedString:[self _renderedText]];
		
		if(fieldWasAPlaceholderAfterwards){
			newSelectedCharRange = [self _rangeForFieldAtIndex:[subfields indexOfObject:relevantField]]; // TODO clean up
		}
		else{
			if(!usedReplacementString.length){ // They pressed the delete key
				// But which delete key?
				if(oldSelectedCharRange.location <= affectedCharRange.location){ // forward delete

				}else{ // backspace
					newSelectedCharRange.location -= 1;
				}
			
			}else{
				newSelectedCharRange.location += usedReplacementString.length;
			}
			
			newSelectedCharRange.length = 0;
		}
		
		[_textView setSelectedRange:newSelectedCharRange];
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
	
	NSRange activeSubfieldRange = [self _rangeForFieldAtIndex:self.activeSubfield];
	NSUInteger rectCount = 0;
	NSRectArray rects = [[_textView layoutManager] rectArrayForCharacterRange:activeSubfieldRange 
												 withinSelectedCharacterRange:NSMakeRange(NSNotFound, 0) 
															  inTextContainer:[_textView textContainer] 
																	rectCount:&rectCount];
	
	*count = rectCount;
	return rects;
}

- (CGFloat) availableWidth{
	return [super availableWidth] - [[self _renderedText] size].width;
}

- (NSResponder *)principalResponder{
	return _textView;
}


#pragma mark -
#pragma Focus/Responder Chain Handling

- (void) _selectNextSubfieldOrRow{
	if(activeSubfield == ([subfields count] - 1)){
		[parentEditor _selectNextRowResponder];
		return;
	}
	
	for(NSUInteger i = activeSubfield + 1; i < [subfields count]; i++){
		WWFlowFieldSubfield *subfield = [subfields objectAtIndex:i];
		if(subfield.editable){
			self.activeSubfield = i;
			return;
		}
	}
	
	// Must be no more editable subfields if we're still running, go to the next one
	[parentEditor _selectNextRowResponder];
}


- (void) _selectPreviousSubfieldOrRow{
	if(activeSubfield == 0){
		[parentEditor _selectPreviousRowResponder];
		return;
	}
	
	for(NSUInteger i = activeSubfield - 1; i >= 0; i--){
		WWFlowFieldSubfield *subfield = [subfields objectAtIndex:i];
		if(subfield.editable){
			self.activeSubfield = i;
			return;
		}
	}
	
	// If we can't find any subfield by this point that we can switch to, then have the parent go to the previous row
	[parentEditor _selectPreviousRowResponder];
}

- (void) _selectFirstEditableSubfield{
	for(NSUInteger i = 0; i < [subfields count]; i++){
		if([[subfields objectAtIndex:i] editable]){
			[self setActiveSubfield:i];
			return;
		}
	}
}

- (void) _selectLastEditableSubfield{
	for(NSUInteger i = ([subfields count] - i); i >= 0; i--){
		if([[subfields objectAtIndex:i] editable]){
			[self setActiveSubfield:i];
			return;
		}
	}
}

@end
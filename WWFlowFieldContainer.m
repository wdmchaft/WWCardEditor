//
//  WWFlowingFieldContainer.m
//  WWCardEditor
//
//  Created by Dan Grover on 6/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WWFlowFieldContainer.h"
#import "WWFlowFieldContainerTextView.h"

#import "WWFlowFieldContainer_Internals.h"

#pragma mark -

@implementation WWFlowFieldContainer
@synthesize _textView, activeField;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		WWFlowFieldContainerTextView *view = [[[WWFlowFieldContainerTextView alloc] initWithFrame:NSMakeRect(0,0,frame.size.width,frame.size.height)] autorelease];
		view.container = self;
		self._textView = view;
		[_textView setDelegate:self];
		[_textView setContinuousSpellCheckingEnabled:NO];
		[_textView setEditable:YES];
		[_textView setDrawsBackground:NO];
		[_textView setTextContainerInset:NSMakeSize(15,15)];
		//[_textView setSelectionGranularity:NSSelectByCharacter];

		// TODO autoresize
		[self addSubview:_textView];
		// Default params
		self.editBoxPadding = WWFlowFieldContainer_DefaultEditBoxPadding;
    }
    return self;
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow{
	// Register for notifications when the window becomes or resigns key, so that we can redraw the control
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self name:NSWindowDidBecomeKeyNotification object:[self window]];
	[nc removeObserver:self name:NSWindowDidResignKeyNotification object:[self window]];
	
	[nc addObserver:self selector:@selector(setNeedsDisplay) name:NSWindowDidBecomeKeyNotification object:newWindow];
	[nc addObserver:self selector:@selector(setNeedsDisplay) name:NSWindowDidResignKeyNotification object:newWindow];
}

- (void)setNeedsDisplay{
	[self setNeedsDisplay:YES];
}

- (void) dealloc{
	[_textView release];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeKeyNotification object:[self window]];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignKeyNotification object:[self window]];
	[super dealloc];
}

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
}

- (CGFloat)editBoxPadding {
    return editBoxPadding;
}

- (void)setEditBoxPadding:(CGFloat)anEditBoxPadding {
    editBoxPadding = anEditBoxPadding;
	[self setNeedsDisplay:YES];
}


#pragma mark -

- (NSAttributedString *) _renderedText{
	NSMutableAttributedString *soFar = [[[NSMutableAttributedString alloc] initWithString:@""] autorelease];
	
	for(WWFlowField *field in fields){
		NSDictionary *attrs = [NSDictionary dictionaryWithObject:field.font forKey:NSFontAttributeName];
		[soFar appendAttributedString:[[[NSAttributedString alloc] initWithString:field.value attributes:attrs] autorelease]];
	}
	
	return soFar;
}

- (NSUInteger) _indexOfFieldForCharOffset:(NSUInteger)offsetDesired{
	
	unsigned offsetReached = 0;
	
	for(NSUInteger i = 0; i < [fields count]; i++){
		WWFlowField *field = [fields objectAtIndex:i];
		unsigned len = [field.value length];
		
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
			WWFlowField *field = [fields objectAtIndex:i];
			soFar += [field.value length];
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
	
	return beginning + [((WWFlowField *)[fields objectAtIndex:fieldIndex]).value length];
}


- (NSRange) _rangeForFieldAtIndex:(NSUInteger)fieldIndex{
	if(fieldIndex >= [fields count]){
		return NSMakeRange(NSNotFound, 0);
	}

	return NSMakeRange([self _charOffsetForBeginningOfFieldAtIndex:fieldIndex], 
					   [((WWFlowField *)[fields objectAtIndex:fieldIndex]).value length]);
}


#pragma mark -
#pragma mark Text View Delegate

//- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString;
// Delegate only.  If characters are changing, replacementString is what will replace the affectedCharRange.  If attributes only are changing, replacementString will be nil.  Will not be called if textView:shouldChangeTextInRanges:replacementStrings: is implemented.

- (NSRange)textView:(NSTextView *)textView willChangeSelectionFromCharacterRange:(NSRange)oldSelectedCharRange toCharacterRange:(NSRange)newSelectedCharRange{
	[self setNeedsDisplay:YES];
	NSLog(@"oldRange = %@, newRange = %@",NSStringFromRange(oldSelectedCharRange),NSStringFromRange(newSelectedCharRange));
	

	if (newSelectedCharRange.location == NSNotFound){
		return newSelectedCharRange; // no selection, that's cool.
	}
	
	NSUInteger fieldIndex = [self _indexOfFieldForCharOffset:newSelectedCharRange.location];
	if(fieldIndex == NSNotFound){
		return newSelectedCharRange;
	}
	
	
	// Check that we don't cross fields
	NSUInteger fieldStartChar = [self _charOffsetForBeginningOfFieldAtIndex:fieldIndex];
	NSUInteger fieldEndChar   = [self _charOffsetForEndOfFieldAtIndex:fieldIndex];
	
	if(fieldIndex != activeField){
		WWFlowField *field = [fields objectAtIndex:fieldIndex];
		
		// Figure out if they're just trying to type at the end of this field or fuck with the next one
		if(fieldIndex == (activeField + 1) && (newSelectedCharRange.length == 0) && (newSelectedCharRange.location == fieldStartChar)){
			return newSelectedCharRange; // allow it. We interpret this scenario in -textView:shouldChangeTextInRange:replacementString:
		}
		
		// Allow them to change to the new field, but not if it's immutable or nonexistent 
		if(!field || [field isMemberOfClass:[WWImmutableStringFlowField class]]){
			NSLog(@"REJECTED AT CHANGE: immutable field");
			return oldSelectedCharRange;
		}
		else{
			// Okay, that's cool, you can change fields, but we're gonna have to select the whole field
			activeField = fieldIndex;
			NSLog(@"MODIFIED AT CHANGE: Selecting entire field");
			return NSMakeRange(fieldStartChar, field.value.length);
		}
	}
	
	
	return newSelectedCharRange;
}


- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString{
	NSLog(@"Changing text in range %@, new string = %@",NSStringFromRange(affectedCharRange), replacementString);
	
	NSUInteger startFieldIndex = [self _indexOfFieldForCharOffset:affectedCharRange.location];
	NSUInteger endFieldIndex   = [self _indexOfFieldForCharOffset:affectedCharRange.location + affectedCharRange.length];
	NSUInteger startFieldStartChar = [self _charOffsetForBeginningOfFieldAtIndex:startFieldIndex];
	
	// Newlines are not allowed in these fields
	// If someone enters or pastes one, we're going to strip it, and then handle the updating of the textView ourselves (by returning NO).
	NSString *newlineScrubbedReplacementString = [[replacementString stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	BOOL overrideHandling = ![newlineScrubbedReplacementString isEqual:replacementString]; 
	
	// Anyway...
	// If we are in the middle of an editable field, just replace the equivilent range in the "field"'s .value property.
	// If we're at the *end* of an editable field (but in reality just a 0-len selection at the start of the next), then append the text.
	
	if((affectedCharRange.length == 0) && (affectedCharRange.location == startFieldStartChar) && (startFieldIndex == (activeField + 1))){
		WWFlowField *field = [fields objectAtIndex:activeField];
		field.value = [field.value stringByAppendingString:newlineScrubbedReplacementString];
	}else{
		// translate affectedCharRange locally
		NSRange localRange = NSMakeRange(affectedCharRange.location - startFieldStartChar, affectedCharRange.length);
		WWFlowField *startField = [fields objectAtIndex:startFieldIndex];
		startField.value = [startField.value stringByReplacingCharactersInRange:localRange withString:newlineScrubbedReplacementString];
	}

	if(overrideHandling){
		// If this is reached, we're going to put the new text there on behalf of the textfield since it would have put the return-carriage-laden
		// text in its place.
		
		NSRange oldSelectedRange = [_textView selectedRange]; // Remember the old selection range to give the appearance that the textField is handling this action, not us
		
		[[_textView textStorage] setAttributedString:[self _renderedText]];
		
		oldSelectedRange.location += newlineScrubbedReplacementString.length;
		oldSelectedRange.length = 0;
		
		[_textView setSelectedRange:oldSelectedRange];
		
		[self setNeedsDisplay];
		return NO;
	}else{
		[self setNeedsDisplay];
		return YES;
	}
}


/*
- (BOOL)textView:(NSTextView *)textView clickedOnLink:(id)link atIndex:(NSUInteger)charIndex;
// Delegate only.

- (void)textView:(NSTextView *)textView clickedOnCell:(id <NSTextAttachmentCell>)cell inRect:(NSRect)cellFrame atIndex:(NSUInteger)charIndex;
// Delegate only.

- (void)textView:(NSTextView *)textView doubleClickedOnCell:(id <NSTextAttachmentCell>)cell inRect:(NSRect)cellFrame atIndex:(NSUInteger)charIndex;
// Delegate only.

- (void)textView:(NSTextView *)view draggedCell:(id <NSTextAttachmentCell>)cell inRect:(NSRect)rect event:(NSEvent *)event atIndex:(NSUInteger)charIndex;
// Delegate only.  Allows the delegate to take over attachment dragging altogether.

- (NSArray *)textView:(NSTextView *)view writablePasteboardTypesForCell:(id <NSTextAttachmentCell>)cell atIndex:(NSUInteger)charIndex;
// Delegate only.  If the previous method is not used, this method and the next allow the textview to take care of attachment dragging and pasting, with the delegate responsible only for writing the attachment to the pasteboard.  In this method, the delegate should return an array of types that it can write to the pasteboard for the given attachment.

- (BOOL)textView:(NSTextView *)view writeCell:(id <NSTextAttachmentCell>)cell atIndex:(NSUInteger)charIndex toPasteboard:(NSPasteboard *)pboard type:(NSString *)type ;
// Delegate only.  In this method, the delegate should attempt to write the given attachment to the pasteboard with the given type, and return success or failure.

- (NSRange)textView:(NSTextView *)textView willChangeSelectionFromCharacterRange:(NSRange)oldSelectedCharRange toCharacterRange:(NSRange)newSelectedCharRange;
// Delegate only.  Will not be called if textView:willChangeSelectionFromCharacterRanges:toCharacterRanges: is implemented.  Effectively prevents multiple selection.

- (NSArray *)textView:(NSTextView *)textView willChangeSelectionFromCharacterRanges:(NSArray *)oldSelectedCharRanges toCharacterRanges:(NSArray *)newSelectedCharRanges;
// Delegate only.  Supersedes textView:willChangeSelectionFromCharacterRange:toCharacterRange:.  Return value must be a non-nil, non-empty array of objects responding to rangeValue.

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRanges:(NSArray *)affectedRanges replacementStrings:(NSArray *)replacementStrings;
// Delegate only.  Supersedes textView:shouldChangeTextInRange:replacementString:.  The affectedRanges argument obeys the same restrictions as selectedRanges, and the replacementStrings argument will either be nil (for attribute-only changes) or have the same number of elements as affectedRanges.

- (NSDictionary *)textView:(NSTextView *)textView shouldChangeTypingAttributes:(NSDictionary *)oldTypingAttributes toAttributes:(NSDictionary *)newTypingAttributes;
// Delegate only.  The delegate should return newTypingAttributes to allow the change, oldTypingAttributes to prevent it, or some other dictionary to modify it.


- (void)textViewDidChangeSelection:(NSNotification *)notification;

- (void)textViewDidChangeTypingAttributes:(NSNotification *)notification;

- (NSString *)textView:(NSTextView *)textView willDisplayToolTip:(NSString *)tooltip forCharacterAtIndex:(NSUInteger)characterIndex;
// Delegate only.  Allows delegate to modify the tooltip that will be displayed from that specified by the NSToolTipAttributeName, or to suppress display of the tooltip (by returning nil).

- (NSArray *)textView:(NSTextView *)textView completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index;
// Delegate only.  Allows delegate to modify the list of completions that will be presented for the partial word at the given range.  Returning nil or a zero-length array suppresses completion.  Optionally may specify the index of the initially selected completion; default is 0, and -1 indicates no selection.


- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString;
// Delegate only.  If characters are changing, replacementString is what will replace the affectedCharRange.  If attributes only are changing, replacementString will be nil.  Will not be called if textView:shouldChangeTextInRanges:replacementStrings: is implemented.

- (BOOL)textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector;


- (NSInteger)textView:(NSTextView *)textView shouldSetSpellingState:(NSInteger)value range:(NSRange)affectedCharRange;
// Delegate only.  Allows delegate to control the setting of spelling and grammar indicators.  Values are those listed for NSSpellingStateAttributeName. 

- (NSMenu *)textView:(NSTextView *)view menu:(NSMenu *)menu forEvent:(NSEvent *)event atIndex:(NSUInteger)charIndex;
// Delegate only.  Allows delegate to control the context menu returned by menuForEvent:.  The menu parameter is the context menu NSTextView would otherwise return; charIndex is the index of the character that was right-clicked. 

*/





#pragma mark -


- (void)drawRect:(NSRect)rect {
	NSPoint containerOrigin	 = [_textView textContainerOrigin];
	CGContextRef myContext = [[NSGraphicsContext currentContext] graphicsPort];
	
	[[NSColor whiteColor] set];
	NSRectFill([self bounds]);


	NSRange activeFieldRange = [self _rangeForFieldAtIndex:self.activeField];

	NSUInteger rectCount = 0;
	NSRectArray rects = [[_textView layoutManager] rectArrayForCharacterRange:activeFieldRange 
												 withinSelectedCharacterRange:NSMakeRange(NSNotFound, 0) 
															  inTextContainer:[_textView textContainer] 
																	rectCount:&rectCount];
	
	CGMutablePathRef glyphPath = CGPathCreateMutable();
	CGMutablePathRef outerGlyphPath = CGPathCreateMutable();
	
	for(unsigned i = 0; i < rectCount; i++){
		NSRect nsRect = rects[i];
		CGRect cgRect = CGRectMake(floor(nsRect.origin.x - editBoxPadding + containerOrigin.x), 
								   floor(nsRect.origin.y - editBoxPadding + containerOrigin.y), 
								   floor(nsRect.size.width + editBoxPadding * 2.0f), 
								   floor(nsRect.size.height + editBoxPadding * 2.0f));
		
		cgRect = CGRectInset(cgRect, -0.5, -0.5); // avoid drawing on pixel cracks
		
		CGPathAddRect(glyphPath, nil, cgRect);
		CGPathAddRect(outerGlyphPath, nil, CGRectInset(cgRect, -1, -1));
	}
	

	CGContextBeginPath(myContext);
	CGContextAddPath(myContext, glyphPath);
	CGContextClosePath(myContext);
	
	// Draw a fancy drop shadow if our window has focus
	if([[self window] isKeyWindow]){
		CGContextSetShadowWithColor(myContext, CGSizeMake(2, -3), 5.0, [[NSColor colorWithDeviceWhite:0 alpha:0.9] asCGColor]);
	}

	[[NSColor whiteColor] set];
	CGContextFillPath(myContext);
	
	CGContextSetShadowWithColor(myContext, CGSizeMake(0,0), 0, nil);
	
	CGContextBeginPath(myContext);
	CGContextAddPath(myContext, outerGlyphPath);
	CGContextClosePath(myContext);
	
	[[NSColor lightGrayColor] set];
	CGContextStrokePath(myContext);
}


- (BOOL) isFlipped{
	return YES;
}


@end
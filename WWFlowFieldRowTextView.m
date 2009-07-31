//
//  WWFlowFieldContainerTextView.m
//  WWCardEditor
//
//  Created by Dan Grover on 6/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WWFlowFieldRowTextView.h"
#import "WWFlowFieldRow.h"

#import "WWFlowFieldRow_Internals.h"
#import "WWCardEditor.h"
#import "WWCardEditor_Internals.h"

@implementation WWFlowFieldRowTextView 
@synthesize container;


// some logic for selection will need to be put in the text field itself, to prevent the display of even a prospective selection before it is validated by the delegate


- (NSRange)selectionRangeForProposedRange:(NSRange)proposedSelRange granularity:(NSSelectionGranularity)granularity{
	[[container parentEditor] setNeedsDisplay:YES];
	NSLog(@"Proposed range");
	
	if(!container.editMode){
		return proposedSelRange; // If we're not in edit mode, they can select anything they want
	}
	
	if (proposedSelRange.location == NSNotFound){
		NSLog(@"Allowing proposed sel range %@",NSStringFromRange(proposedSelRange));
		return proposedSelRange; // no selection, that's cool.
	}
	
	NSRange oldSelectedCharRange = [self selectedRange];
	NSUInteger startFieldIndex = [container _indexOfFieldForCharOffset:proposedSelRange.location];
	NSUInteger endFieldIndex   = [container _indexOfFieldForCharOffset:proposedSelRange.location + proposedSelRange.length];
	
	if(startFieldIndex == NSNotFound){
		NSLog(@"MODIFIED AT PROPOSED RANGE: No valid field");
		return NSMakeRange(proposedSelRange.location, 0);
	}
	
	WWFlowFieldSubfield *startField = [container.fields objectAtIndex:startFieldIndex];
	WWFlowFieldSubfield *endField = (endFieldIndex < [container.fields count]) ? [container.fields objectAtIndex:endFieldIndex] : nil;
	
	if(![startField editable]){
		// This is allowable if they're really trying to type at the end of a legal, mutable field
		if (!proposedSelRange.length  && ([container _charOffsetForBeginningOfFieldAtIndex:startFieldIndex] == proposedSelRange.location)){
			NSUInteger potentiallyLegalPreviousFieldIndex = startFieldIndex - 1;
			if((potentiallyLegalPreviousFieldIndex >= 0) && (potentiallyLegalPreviousFieldIndex < [container.fields count]) 
			   && [[container.fields objectAtIndex:potentiallyLegalPreviousFieldIndex] editable])
			{
				NSLog(@"Allowing typing at end of field");
				return proposedSelRange;
			}
		}
		
		// Otherwise block it
		NSLog(@"REJECTED AT PROPOSED RANGE: Trying to edit immutable field");
		return oldSelectedCharRange;
	}
	else if(!endField || !endField.editable){
		if(proposedSelRange.length > [[container _displayedStringForField:startField] length]){ // Only block this if they're not just trying to get the last character of the active field
			NSLog(@"REJECTED AT PROPOSED RANGE (End): Trying to edit immutable field");
			return oldSelectedCharRange;
		}
	}
	
	// Check that we don't cross fields
	NSUInteger startFieldStartChar = [container _charOffsetForBeginningOfFieldAtIndex:startFieldIndex];
	NSUInteger startFieldEndChar = [container _charOffsetForEndOfFieldAtIndex:startFieldIndex];
	
	if(startFieldIndex != endFieldIndex){
		if((startFieldIndex == container.activeField) && (endFieldIndex > startFieldIndex)){
			NSLog(@"MODIFIED AT PROPOSED RANGE: Can't select ahead across fields, only selecting until end of current field.");
			return NSMakeRange(proposedSelRange.location, [[container _displayedStringForField:startField] length] - (proposedSelRange.location - startFieldStartChar));
		}
		else if((startFieldIndex < container.activeField) && (endFieldIndex >= container.activeField)){
			NSUInteger endFieldStartChar = [container _charOffsetForBeginningOfFieldAtIndex:endFieldIndex];
			NSLog(@"MODIFIED AT PROPOSED RANGE: Can't select behind across fields, only selecting from beginning of end field to end of proposed selection");
			return NSMakeRange(endFieldStartChar, proposedSelRange.location + proposedSelRange.length - endFieldStartChar);
		}
	}

	if(startFieldIndex != container.activeField){
		if(proposedSelRange.length == 0){
			NSLog(@"MODIFIED AT PROPOSED RANGE: Changing active field, length = 0");
			return NSMakeRange(startFieldStartChar,0);
		}else{
			NSLog(@"REJECTED AT PROPOSED RANGE: Can't propose a non-zero-length selection in a non-active field");
			return oldSelectedCharRange;
		}
	}
	
	
	NSLog(@"No objections");
	return proposedSelRange;
}



// Overrides

- (void)selectAll:(id)sender{
	if(container.activeField != NSNotFound){
		[self setSelectedRange:[container _rangeForFieldAtIndex:container.activeField]];
	}
	
}

- (void)insertTab:(id)sender{
	[container _selectNextSubfieldOrRow];
}

- (void)insertBacktab:(id)sender{
	[container _selectPreviousSubfieldOrRow];
}

- (BOOL)resignFirstResponder{
	//container.isRendering = YES;
	//[self setSelectedRange:NSMakeRange(NSNotFound, 0)];
	//container.isRendering = NO;
	
	[self setEditable:NO];
	container.inUse = NO;
	return [super resignFirstResponder];
}

- (BOOL)becomeFirstResponder{
	if(![[container parentEditor] editMode]){
		return NO;
	}
	
	[self setEditable:YES];
	container.inUse = YES;
	return [super becomeFirstResponder];
}

// The main drawing of focus rings is in WWCardEditor, but we have to do a little here too,
// due to the way NSTextViews are drawn
- (void) drawRect:(NSRect)rect{
	
	// Draw what we would normally draw, then white out the drawn area that intersects with
	// the focus rectangle (then trace over the text inside of it)
	[super drawRect:rect];
	
	// But only if there should actually be a focus ring here.
	if(([[self window] firstResponder] != self) || ![container inUse] || ![container editMode]){
		return;
	}
	
	
	NSUInteger count = 0;
	NSRectArray focusRingRects = [container requestedFocusRectArrayAndCount:&count];
	
	[[[container parentEditor] backgroundColor] set];
	CGSize focusRingPadding = container.parentEditor.focusRingPadding;

	for(unsigned i = 0; i < count; i++){
		NSRect fieldRect = [self convertRect:focusRingRects[i] fromView:container];
		fieldRect = NSMakeRect(floor(fieldRect.origin.x), floor(fieldRect.origin.y), floor(fieldRect.size.width), floor(fieldRect.size.height));
		NSRect fillRect = NSInsetRect(fieldRect, -1* focusRingPadding.width, -1* focusRingPadding.height);
		
		NSRectFill(fillRect);
	}
	
	// Re-trace the text over the background
	NSPoint containerOrigin	 = [self textContainerOrigin];
	NSRange fieldGlyphRange = [[self layoutManager] glyphRangeForCharacterRange:[container _rangeForFieldAtIndex:container.activeField] actualCharacterRange:nil];
	[[self layoutManager] drawBackgroundForGlyphRange:fieldGlyphRange atPoint:containerOrigin];
	[[self layoutManager] drawGlyphsForGlyphRange:fieldGlyphRange atPoint:containerOrigin];
}


@end
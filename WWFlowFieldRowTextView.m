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

@implementation WWFlowFieldRowTextView 
@synthesize container;


// some logic for selection will need to be put in the text field itself, to prevent the display of even a prospective selection before it is validated by the delegate


- (NSRange)selectionRangeForProposedRange:(NSRange)proposedSelRange granularity:(NSSelectionGranularity)granularity{
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
				return proposedSelRange;
			}
		}
		
		// Otherwise block it
		NSLog(@"REJECTED AT PROPOSED RANGE: Trying to edit immutable field");
		return oldSelectedCharRange;
	}
	else if(!endField || !endField.editable){
		if(proposedSelRange.length > startField.value.length){ // Only block this if they're not just trying to get the last character of the active field
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
			return NSMakeRange(proposedSelRange.location, startField.value.length - (proposedSelRange.location - startFieldStartChar));
		}
		else if((startFieldIndex < container.activeField) && (endFieldIndex >= container.activeField)){
			NSUInteger endFieldStartChar = [container _charOffsetForBeginningOfFieldAtIndex:endFieldIndex];
			NSUInteger endFieldEndChar   = [container _charOffsetForEndOfFieldAtIndex:endFieldIndex];
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
	
	return proposedSelRange;
}


// Draw white rectangles where the editing box should be and then redraw the text on top
- (void) drawRect:(NSRect)rect{
	[super drawRect:rect];
	
	if(!container.editMode || (container.activeField == NSNotFound)){
		return;
	}
	
	CGContextRef myContext	 = [[NSGraphicsContext currentContext] graphicsPort];
	NSPoint containerOrigin	 = [self textContainerOrigin];
	
	// Find where to draw the rects
	NSRange activeFieldRange =  [container _rangeForFieldAtIndex:container.activeField];
	NSUInteger rectCount = 0;
	NSRectArray rects = [[self layoutManager] rectArrayForCharacterRange:activeFieldRange withinSelectedCharacterRange:NSMakeRange(NSNotFound, 0) inTextContainer:[self textContainer] rectCount:&rectCount];
	
	float padding = container.editBoxPadding;
	
	CGContextBeginPath(myContext);
	for(unsigned i = 0; i < rectCount; i++){
		NSRect nsRect = rects[i];
		CGRect cgRect = CGRectMake(floor(nsRect.origin.x - padding + containerOrigin.x), 
								   floor(nsRect.origin.y - padding + containerOrigin.y), 
								   floor(nsRect.size.width + padding*2),
								   floor(nsRect.size.height + padding*2));
		
		CGContextAddRect(myContext, CGRectInset(cgRect, -0.5, -0.5));
	}
	CGContextClosePath(myContext);
	
	// Draw white rects
	[[NSColor whiteColor] set];
	CGContextFillPath(myContext);
	
	// Redraw the text over the white rects
	NSRange fieldGlyphRange = [[self layoutManager] glyphRangeForCharacterRange:activeFieldRange actualCharacterRange:nil];
	[[self layoutManager] drawBackgroundForGlyphRange:fieldGlyphRange atPoint:containerOrigin];
	[[self layoutManager] drawGlyphsForGlyphRange:fieldGlyphRange atPoint:containerOrigin];
}


// Overrides

- (void)selectAll:(id)sender{
	if(container.activeField != NSNotFound){
		[self setSelectedRange:[container _rangeForFieldAtIndex:container.activeField]];
	}
	
}

@end
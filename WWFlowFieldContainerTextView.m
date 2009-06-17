//
//  WWFlowFieldContainerTextView.m
//  WWCardEditor
//
//  Created by Dan Grover on 6/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WWFlowFieldContainerTextView.h"
#import "WWFlowFieldContainer.h"

#import "WWFlowFieldContainer_Internals.h"

@implementation WWFlowFieldContainerTextView 
@synthesize container;


// some logic for selection will need to be put in the text field itself, to prevent the display of even a prospective selection before it is validated by the delegate


- (NSRange)selectionRangeForProposedRange:(NSRange)proposedSelRange granularity:(NSSelectionGranularity)granularity{
	NSRange oldSelectedCharRange = [self selectedRange];
	
	NSLog(@"Proposing change from start=%d, len=%d to start=%d, len=%d",oldSelectedCharRange.location, oldSelectedCharRange.length, oldSelectedCharRange.location, oldSelectedCharRange.length);
	
	NSUInteger startFieldIndex = [container _indexOfFieldForCharOffset:proposedSelRange.location];
	NSUInteger endFieldIndex   = [container _indexOfFieldForCharOffset:proposedSelRange.location + proposedSelRange.length];
	
	if(startFieldIndex == NSNotFound){
		NSLog(@"REJECTED AT PROPOSED RANGE: No valid field");
		return oldSelectedCharRange;
	}
	
	WWFlowField *startField = [container.fields objectAtIndex:startFieldIndex];
	if([startField isMemberOfClass:[WWImmutableStringFlowField class]]){
		NSLog(@"REJECTED AT PROPOSED RANGE: Trying to edit immutable field");
		return oldSelectedCharRange;
	}
	
	// Check that we don't cross fields
	NSUInteger startFieldStartChar = [container _charOffsetForBeginningOfFieldAtIndex:startFieldIndex];
	NSUInteger startFieldEndChar = [container _charOffsetForEndOfFieldAtIndex:startFieldIndex];
	
	
	
	if(startFieldIndex != endFieldIndex){
		if((startFieldIndex == container.activeField) && (endFieldIndex > startFieldIndex)){
			NSLog(@"MODIFIED AT PROPOSED RANGE: Can't select ahead across fields, only selecting until end of current field.");
			return NSMakeRange(proposedSelRange.location, startField.value.length - (proposedSelRange.location - startFieldStartChar));
		}else if((startFieldIndex < container.activeField) && (endFieldIndex >= container.activeField)){
			NSUInteger endFieldStartChar = [container _charOffsetForBeginningOfFieldAtIndex:endFieldIndex];
			NSUInteger endFieldEndChar   = [container _charOffsetForEndOfFieldAtIndex:endFieldIndex];
		
			NSLog(@"MODIFIED AT PROPOSED RANGE: Can't select behind across fields, only selecting from beginning of end field to end of proposed selection");
			return NSMakeRange(endFieldStartChar, proposedSelRange.location + proposedSelRange.length - endFieldStartChar);
		}
		else{
			// Not cool at all
			NSLog(@"REJECTED AT PROPOSED RANGE: Other cross-field situation");
			return oldSelectedCharRange;
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
	
	CGContextRef myContext	 = [[NSGraphicsContext currentContext] graphicsPort];
	NSPoint containerOrigin	 = [self textContainerOrigin];
	
	// Find where to draw the rects
	NSRange activeFieldRange = [container _rangeForFieldAtIndex:[container _indexOfFieldForCharOffset:[self selectedRange].location]];
	NSUInteger rectCount = 0;
	NSRectArray rects = [[self layoutManager] rectArrayForCharacterRange:activeFieldRange withinSelectedCharacterRange:NSMakeRange(NSNotFound, 0) inTextContainer:[self textContainer] rectCount:&rectCount];
	
	CGContextBeginPath(myContext);
	for(unsigned i = 0; i < rectCount; i++){
		NSRect nsRect = rects[i];
		CGRect cgRect = CGRectMake(nsRect.origin.x - WWFlowFieldContainer_EditBoxPadding + containerOrigin.x - 1, 
								   nsRect.origin.y - WWFlowFieldContainer_EditBoxPadding + containerOrigin.y - 1, 
								   nsRect.size.width + WWFlowFieldContainer_EditBoxPadding*2 + 1, 
								   nsRect.size.height + WWFlowFieldContainer_EditBoxPadding*2 + 1);
		CGContextAddRect(myContext, cgRect);
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
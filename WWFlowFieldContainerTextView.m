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

/*
- (NSRange)selectionRangeForProposedRange:(NSRange)proposedSelRange granularity:(NSSelectionGranularity)granularity{

}*/


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











@end
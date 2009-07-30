//
//  WWKeyValueRow.m
//  WWCardEditor
//
//  Created by Dan Grover on 6/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WWKeyValueRow.h"
#import "WWCardEditor.h"
#import "WWCardEditor_Internals.h"


@interface WWKeyValueRow()
- (void) _layoutIfNeeded;
- (NSMutableDictionary *)_labelAttributes;
@end

#pragma mark -

@implementation WWKeyValueRow

- (id)init{
    if (self = [super initWithFrame:NSZeroRect]){
		splitPosition = 80;
		[[self window] setAcceptsMouseMovedEvents:YES];
		[[self window] setIgnoresMouseEvents:NO];
    }
    return self;
}

- (void)dealloc {
    [self setKeyLabel:nil];
	[self setValueRowView:nil];
    [super dealloc];
}

- (NSString *)description{
	return [NSString stringWithFormat:@"<WWKeyValueRow: keyLabel = %@, valueRow = %@>",keyLabel, valueRowView];
}

- (NSMutableDictionary *)_labelAttributes{
	NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
	[attrs setObject:parentEditor.keyLabelFont forKey:NSFontAttributeName];
	[attrs setObject:parentEditor.keyLabelColor forKey:NSForegroundColorAttributeName];
	return attrs;
}

#pragma mark -

- (NSString *)keyLabel {
    return keyLabel; 
}


- (void)setKeyLabel:(NSString *)aKeyLabel {
    if (keyLabel != aKeyLabel) {
        [keyLabel release];
        keyLabel = [aKeyLabel retain];
    }
	
	[self setNeedsDisplay:YES];
}


- (WWCardEditorRow *)valueRowView {
    return valueRowView; 
}

- (void)setValueRowView:(WWCardEditorRow *)aValueRowView {
    if (valueRowView != aValueRowView) {
		[valueRowView removeFromSuperview];
        [valueRowView release];
        valueRowView = [aValueRowView retain];
		
		
		[self addSubview:valueRowView];
		[valueRowView setParentEditor:self.parentEditor];
		[valueRowView setAutoresizingMask:NSViewMaxXMargin | NSViewMaxYMargin | NSViewWidthSizable | NSViewHeightSizable];
		[self setAutoresizesSubviews:YES];
    }
	
	needsLayout = YES;
}

- (CGFloat)splitPosition {
    return splitPosition;
}

- (void)setSplitPosition:(CGFloat)aSplitPosition {
    splitPosition = aSplitPosition;
	needsLayout = YES;
}

- (void)setParentEditor:(WWCardEditor *)aParentEditor {
    if (parentEditor != aParentEditor) {
        [parentEditor release];
        parentEditor = [aParentEditor retain];
    }
	
	[valueRowView setParentEditor:aParentEditor];
	[valueRowView setParentRow:self];
}

- (void)setEditMode:(BOOL)flag {
	[valueRowView setEditMode:flag];
	[super setEditMode:flag];
}

- (void)setParentRow:(WWCardEditorRow *)aParentRow {
    [valueRowView setParentRow:aParentRow];
	[super setParentRow:aParentRow];
}

#pragma mark -
#pragma mark Overrides

- (void) _layoutIfNeeded{
	if(needsLayout){
		[valueRowView setFrame:NSMakeRect(splitPosition, 0, [self frame].size.width - splitPosition, [valueRowView neededHeight])];
		
		
		needsLayout = NO;
	}
}

- (NSResponder *)principalResponder{
	return [valueRowView principalResponder];
}

- (NSRectArray) requestedFocusRectArrayAndCount:(NSUInteger *)count{
	if (!valueRowView) return [super requestedFocusRectArrayAndCount:count];
	
	NSUInteger valueRowRectCount = 0;
	NSRectArray valueRowRects = [valueRowView requestedFocusRectArrayAndCount:&valueRowRectCount];
	for(NSUInteger i = 0; i < valueRowRectCount; i++){
		valueRowRects[i].origin.x += splitPosition;// = [self convertRect:valueRowRects[i] fromView:valueRowView];
	}
	
	*count = valueRowRectCount;
	return valueRowRects;
}

-(void)resetCursorRects{
    [self discardCursorRects];
	
	NSSize labelSize = [keyLabel sizeWithAttributes:[self _labelAttributes]];
	
    NSRect clippedItemBounds = NSIntersectionRect([self visibleRect], NSMakeRect(splitPosition - 10 - labelSize.width,0,labelSize.width, labelSize.height));

    if (!NSIsEmptyRect(clippedItemBounds)) {
		[self addCursorRect:clippedItemBounds cursor:[NSCursor arrowCursor]];
		[self addTrackingRect:clippedItemBounds owner:self userData:nil assumeInside:NO];
    }
}


- (CGFloat) neededHeight{
	return MAX([valueRowView neededHeight], [keyLabel sizeWithAttributes:[self _labelAttributes]].height); 
}

- (CGFloat) availableWidth{
	return [super availableWidth] - splitPosition;
}



#pragma mark -
#pragma mark Drawing

- (void)drawRect:(NSRect)rect {
	[self _layoutIfNeeded];
	
	NSMutableDictionary *attrs = [self _labelAttributes];
	NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
	[style setAlignment:NSRightTextAlignment];
	[attrs setObject:[style autorelease] forKey:NSParagraphStyleAttributeName];
	
	NSAttributedString *styledLabel =  [[[NSAttributedString alloc] initWithString:keyLabel attributes:attrs] autorelease];
	NSSize labelRect = [styledLabel size];
	
	if(hover && !editMode){
		float capRadius = 7;
		
		[attrs setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
		
		// Key side
		NSPoint startPoint = NSMakePoint(splitPosition - labelRect.width - capRadius - 4, labelRect.height / 2 );
		
		NSBezierPath *highlightPath = [NSBezierPath bezierPath];
		[highlightPath appendBezierPathWithArcWithCenter: startPoint radius: capRadius startAngle: 90.0f endAngle: 270.f clockwise: NO];
		[highlightPath appendBezierPathWithRect:NSMakeRect(splitPosition - labelRect.width - 4 - capRadius, 0, labelRect.width + 10, labelRect.height)];
		
		[[NSColor colorWithCalibratedWhite:0 alpha:1-0.69] set];
		[highlightPath fill];

		
		// Value side
		highlightPath = [NSBezierPath bezierPath];
		[[NSColor colorWithCalibratedWhite:0 alpha:1-0.89] set];
	
		CGFloat highlightWidth = [self availableWidth] - [valueRowView availableWidth] + 10;
		
		if([self neededHeight] > (labelRect.height + 3)){
			[highlightPath appendBezierPathWithRoundedRect:NSMakeRect(splitPosition + 1, 0, highlightWidth, [self neededHeight]) xRadius:capRadius yRadius:capRadius];
			[highlightPath appendBezierPathWithRect:NSMakeRect(splitPosition+1,0,capRadius,capRadius)];
		}else{
			[highlightPath appendBezierPathWithRoundedRect:NSMakeRect(splitPosition + 1, 0, highlightWidth, labelRect.height) xRadius:capRadius yRadius:capRadius];
			[highlightPath appendBezierPathWithRect:NSMakeRect(splitPosition+1,0,capRadius,labelRect.height)];
		}
			
		[highlightPath fill];
	}
	
	// Draw key label
	[keyLabel drawInRect:NSMakeRect(0, 0, splitPosition - 10, labelRect.height) withAttributes:attrs];
	[super drawRect:rect];
}

- (BOOL) isFlipped{
	return YES;
}


#pragma mark -
#pragma mark Event Handling

- (void)mouseEntered:(NSEvent *)theEvent{
	hover = YES;
	[self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent{
	hover = NO;
	[self setNeedsDisplay:YES];
}

- (void)mouseMoved:(NSEvent *)theEvent{
	[self setNeedsDisplay:YES];
}


@end
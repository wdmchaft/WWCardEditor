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

#define WWKeyValueRow_HorizontalBuffer 10
#define WWKeyValueRow_DefaultSplitPosition 80

@interface WWKeyValueRow()
- (void) _layoutIfNeeded;
- (NSString *) _displayedKeyLabel;
- (NSMutableDictionary *)_labelAttributes;
- (void) _populateMenu;
- (BOOL) _menuShouldBeHidden;
- (NSRect) _labelMouseRect;

@property(retain) NSPopUpButton *_keyButton;
@end

#pragma mark -

@implementation WWKeyValueRow
@synthesize _keyButton, delegate, actionMenu;

- (id)initWithName:(NSString *)theName{
    if (self = [super initWithName:theName]){
		splitPosition = WWKeyValueRow_DefaultSplitPosition;
		
		self._keyButton = [[[NSPopUpButton alloc] initWithFrame:NSZeroRect] autorelease];
		[_keyButton setFont:[parentEditor keyLabelFont]];
		[[_keyButton cell] setControlSize:NSMiniControlSize];
		[_keyButton setTarget:self];
		[_keyButton setAction:@selector(_choseNewKeyType)];
		[_keyButton setBordered:NO];
		[_keyButton setAlignment:NSRightTextAlignment];
		
		[self setKeyTypeIdentifiers:[NSArray arrayWithObject:@"label"]];
		
		[self addSubview:_keyButton];
		
		[[self window] setAcceptsMouseMovedEvents:YES];
		[[self window] setIgnoresMouseEvents:NO];
    }
    return self;
}

- (void)dealloc {
	self._keyButton = nil;
	self.actionMenu = nil;
	self.keyTypeLabels = nil;
	self.keyTypeIdentifiers = nil;
	self.valueRowView = nil;
    [super dealloc];
}

- (NSString *)description{
	return [NSString stringWithFormat:@"<WWKeyValueRow: keyTypes = %@, valueRow = %@>",keyTypeIdentifiers, valueRowView];
}

+ (void) initialize{
	[self exposeBinding:@"keyLabel"];
	[self exposeBinding:@"valueRow"];
}


- (NSMutableDictionary *)_labelAttributes{
	NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
	
	if(parentEditor){
		[attrs setObject:parentEditor.keyLabelFont forKey:NSFontAttributeName];
		[attrs setObject:parentEditor.keyLabelColor forKey:NSForegroundColorAttributeName];
	}
	
	return attrs;
}


#pragma mark -



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
	
	_needsLayout = YES;
}


- (NSDictionary *)keyTypeLabels {
    return keyTypeLabels; 
}

- (void)setKeyTypeLabels:(NSDictionary *)aKeyTypeLabels {
    if (keyTypeLabels != aKeyTypeLabels) {
        [keyTypeLabels release];
        keyTypeLabels = [aKeyTypeLabels retain];
		
		[self _populateMenu];
    }
}



- (NSString *)activeKeyType {
    return [keyTypeIdentifiers objectAtIndex:[_keyButton indexOfSelectedItem]];
}


- (void)setActiveKeyType:(NSString *)anActiveKeyType {
	if([keyTypeIdentifiers containsObject:anActiveKeyType]){
		[_keyButton selectItemAtIndex:[keyTypeIdentifiers indexOfObject:anActiveKeyType]];
	}
}


- (NSArray *)keyTypeIdentifiers {
    return keyTypeIdentifiers; 
}

- (void)setKeyTypeIdentifiers:(NSArray *)aKeyTypeIdentifiers {
    if (keyTypeIdentifiers != aKeyTypeIdentifiers) {
        [keyTypeIdentifiers release];
        keyTypeIdentifiers = [aKeyTypeIdentifiers retain];
		[self _populateMenu];
		_needsLayout = YES;
    }
}



- (CGFloat)splitPosition {
    return splitPosition;
}

- (void)setSplitPosition:(CGFloat)aSplitPosition {
    splitPosition = aSplitPosition;
	_needsLayout = YES;
}


- (void)setParentEditor:(WWCardEditor *)aParentEditor {
    if (parentEditor != aParentEditor) {
        [parentEditor release];
        parentEditor = [aParentEditor retain];
    }
	
	[_keyButton setFont:parentEditor.keyLabelFont];
	
	[valueRowView setParentEditor:aParentEditor];
	[valueRowView setParentRow:self];
}


- (void)setEditMode:(BOOL)flag {
	[valueRowView setEditMode:flag];
	_needsLayout = YES;
	[super setEditMode:flag];
}

- (void)setParentRow:(WWCardEditorRow *)aParentRow {
    [valueRowView setParentRow:aParentRow];
	[super setParentRow:aParentRow];
}

#pragma mark -
#pragma mark Helpers


- (void) _populateMenu{
	NSMenu *menu = [[[NSMenu alloc] init] autorelease];
	
	for(unsigned i = 0; i < [keyTypeIdentifiers count]; i++){
		NSString *identifier = [keyTypeIdentifiers objectAtIndex:i];
		
		NSMenuItem *item = [[NSMenuItem alloc] init];
		[item setTag:i];
		
		NSString *title = [keyTypeLabels objectForKey:identifier];
		[item setTitle:title ? title : identifier];
		[item setTarget:self];
		[item setAction:@selector(_menuAction:)];
		[item setEnabled:YES];
		
		[menu addItem:item];
		[item release];
	}
	
	[menu setAutoenablesItems:YES];
	
	[_keyButton setMenu:menu];
}

- (void) _menuAction:(id)sender{
	NSLog(@"menu action: %@",sender);
	[self resetCursorRects];
	_needsLayout;
	
	if(delegate){
		[delegate keyValueRow:self choseKeyType:[keyTypeIdentifiers objectAtIndex:[sender tag]]];
	}
}


- (BOOL) _menuShouldBeHidden{
	return (!editMode || ([keyTypeIdentifiers count] <= 1));
}

- (NSString *) _displayedKeyLabel{
	NSString *keyType = [self activeKeyType];
	NSString *label = [keyTypeLabels objectForKey:keyType];
	return label ? label : keyType;
}


#pragma mark -
#pragma mark Overrides

- (void) _layoutIfNeeded{
	if(_needsLayout){
		[valueRowView setFrame:NSMakeRect(splitPosition, 0, [self frame].size.width - splitPosition, [valueRowView neededHeight])];
		
		[_keyButton setFrame:NSMakeRect(0, 
									    0, 
										splitPosition + 4,
								        [[self _displayedKeyLabel] sizeWithAttributes:[self _labelAttributes]].height)];
		
		[_keyButton setHidden:[self _menuShouldBeHidden]];
		
		_needsLayout = NO;
	}
}

- (NSArray *)principalResponders{
	NSMutableArray *responders = [NSMutableArray array];
	
	if([keyTypeIdentifiers count] > 1) [responders addObject:_keyButton];
	[responders addObjectsFromArray:[valueRowView principalResponders]];
	
	return responders;
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



- (CGFloat) neededHeight{
	return MAX([valueRowView neededHeight], [[[_keyButton selectedItem] title] sizeWithAttributes:[self _labelAttributes]].height); 
}

- (CGFloat) availableWidth{
	return [super availableWidth] - splitPosition - WWKeyValueRow_HorizontalBuffer;
}



#pragma mark -
#pragma mark Drawing

- (void)drawRect:(NSRect)rect {
	[self _layoutIfNeeded];
	
	NSMutableDictionary *attrs = [self _labelAttributes];
	NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
	[style setAlignment:NSRightTextAlignment];
	[attrs setObject:[style autorelease] forKey:NSParagraphStyleAttributeName];
	
	NSAttributedString *styledLabel =  [[[NSAttributedString alloc] initWithString:[[_keyButton selectedItem] title] attributes:attrs] autorelease];
	NSSize labelRect = [styledLabel size];
	
	if(hover && !editMode){
		float capRadius = 7;
		
		[attrs setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
		
		// Key side
		NSPoint startPoint = NSMakePoint(splitPosition - labelRect.width - capRadius - 4, labelRect.height / 2 );
		
		NSBezierPath *highlightPath = [NSBezierPath bezierPath];
		[highlightPath appendBezierPathWithArcWithCenter: startPoint radius: capRadius startAngle: 90.0f endAngle: 270.f clockwise: NO];
		[highlightPath appendBezierPathWithRect:NSMakeRect(splitPosition - labelRect.width - 4 - capRadius, 0, labelRect.width + WWKeyValueRow_HorizontalBuffer, labelRect.height)];
		
		[[NSColor colorWithCalibratedWhite:0 alpha:1-0.69] set];
		[highlightPath fill];

		
		// Value side
		highlightPath = [NSBezierPath bezierPath];
		[[NSColor colorWithCalibratedWhite:0 alpha:1-0.89] set];
	
		CGFloat highlightWidth = [self availableWidth] - [valueRowView availableWidth] + WWKeyValueRow_HorizontalBuffer;
		
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
	if([self _menuShouldBeHidden]){
		[[self _displayedKeyLabel]  drawInRect:NSMakeRect(0, 0, splitPosition - WWKeyValueRow_HorizontalBuffer, labelRect.height) 
								withAttributes:attrs];
	}
	
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

- (void)mouseDown:(NSEvent *)theEvent{
	NSPoint converted = [self convertPoint:[theEvent locationInWindow] fromView:[[self window] contentView]];
	if(actionMenu && NSPointInRect(converted, [self _labelMouseRect])){
		[NSMenu popUpContextMenu:actionMenu withEvent:theEvent forView:self];
	}
}

-(void)resetCursorRects{
    [self discardCursorRects];
	
    NSRect clippedItemBounds = [self _labelMouseRect]; 
	
    if (!NSIsEmptyRect(clippedItemBounds)) {
		[self addCursorRect:clippedItemBounds cursor:[NSCursor arrowCursor]];
		[self addTrackingRect:clippedItemBounds owner:self userData:nil assumeInside:NO];
    }
}

- (NSRect) _labelMouseRect{
	NSSize labelSize = [[self _displayedKeyLabel]sizeWithAttributes:[self _labelAttributes]];
    NSRect clippedItemBounds = NSIntersectionRect([self visibleRect], NSMakeRect(splitPosition - WWKeyValueRow_HorizontalBuffer - labelSize.width,0,labelSize.width, labelSize.height));
	return clippedItemBounds;
}
@end
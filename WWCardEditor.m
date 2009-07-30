//
//  WWCardEditor.m
//  WWCardEditor
//
//  Created by Dan Grover on 6/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WWCardEditor.h"
#import "WWCardEditorRow.h"
#import "WWCardEditor_Internals.h"
#import "WWKeyValueRow.h"

@interface WWCardEditor()
@property(retain) NSMutableArray *_rows;
@end

#pragma mark -

@implementation WWCardEditor
@synthesize needsLayout, _rows;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		self._rows = [NSMutableArray array];
		self.keyLabelColor = [NSColor darkGrayColor];
		self.keyLabelFont = [NSFont fontWithName:@"Helvetica Bold" size:12];
		
		self.padding = CGSizeMake(10, 10);
		self.rowSpacing = 0;
		self.backgroundColor = [NSColor whiteColor];
		
		self.focusRingBorderColor = [NSColor lightGrayColor];
		self.focusRingPadding = CGSizeMake(3, 3);
    }
    return self;
}

- (void) dealloc{
	self.keyLabelColor = nil;
	self.keyLabelFont = nil;
	self.focusRingBorderColor = nil;
	self.backgroundColor = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeKeyNotification object:[self window]];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignKeyNotification object:[self window]];
	
	[super dealloc];
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow{
	// Register for notifications when the window becomes or resigns key, so that we can redraw the control
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self name:NSWindowDidBecomeKeyNotification object:[self window]];
	[nc removeObserver:self name:NSWindowDidResignKeyNotification object:[self window]];
	
	[nc addObserver:self selector:@selector(setNeedsDisplay) name:NSWindowDidBecomeKeyNotification object:newWindow];
	[nc addObserver:self selector:@selector(setNeedsDisplay) name:NSWindowDidResignKeyNotification object:newWindow];
}

+ (void) initialize{
	[self exposeBinding:@"keyLabelColor"];
	[self exposeBinding:@"backgroundColor"];
	[self exposeBinding:@"padding"];
	[self exposeBinding:@"rowSpacing"];
	
}

#pragma mark -
#pragma mark Accessors

- (NSColor *)keyLabelColor {
    return keyLabelColor; 
}

- (void)setKeyLabelColor:(NSColor *)aKeyLabelColor {
    if (keyLabelColor != aKeyLabelColor) {
        [keyLabelColor release];
        keyLabelColor = [aKeyLabelColor retain];
		[self setNeedsDisplay:YES];
    }
}


- (NSFont *)keyLabelFont {
    return keyLabelFont; 
}

- (void)setKeyLabelFont:(NSFont *)aKeyLabelFont {
    if (keyLabelFont != aKeyLabelFont) {
        [keyLabelFont release];
        keyLabelFont = [aKeyLabelFont retain];
		needsLayout = YES;
    }
}

- (NSColor *)backgroundColor {
    return backgroundColor; 
}

- (void)setBackgroundColor:(NSColor *)aBackgroundColor {
    if (backgroundColor != aBackgroundColor) {
        [backgroundColor release];
        backgroundColor = [aBackgroundColor retain];
		[self setNeedsDisplay:YES];
    }
}

- (CGSize)padding {
    return padding;
}

- (void)setPadding:(CGSize)aPadding {
    padding = aPadding;
	needsLayout = YES;
	[self setNeedsDisplay:YES];
}

- (CGFloat)rowSpacing {
    return rowSpacing;
}

- (void)setRowSpacing:(CGFloat)aRowSpacing {
	NSLog(@"Row spacing");
    rowSpacing = aRowSpacing;
	needsLayout = YES;
	[self setNeedsDisplay:YES];
}

- (BOOL)editMode {
    return editMode;
}

- (void)setEditMode:(BOOL)flag {
    editMode = flag;
	for(WWCardEditorRow *row in _rows){
		[row setEditMode:flag];
		[row setNeedsDisplay:YES];
	}
	[self setNeedsDisplay:YES];
}

- (CGSize)focusRingPadding {
    return focusRingPadding;
}

- (void)setFocusRingPadding:(CGSize)aFocusRingPadding {
    focusRingPadding = aFocusRingPadding;
	[self setNeedsDisplay:YES];
}

- (NSColor *)focusRingBorderColor {
    return focusRingBorderColor; 
}

- (void)setFocusRingBorderColor:(NSColor *)aFocusRingBorderColor {
    if (focusRingBorderColor != aFocusRingBorderColor) {
        [focusRingBorderColor release];
        focusRingBorderColor = [aFocusRingBorderColor retain];
    }
	
	[self setNeedsDisplay:YES];
}


#pragma mark -
#pragma mark Row Manipulation 

- (void) addRow:(WWCardEditorRow *)row{
	[self addRow:row atIndex:[_rows count]];
}

- (void) addRow:(WWCardEditorRow *)row atIndex:(NSUInteger)newRowIndex{
	row.parentEditor = self;
	[_rows insertObject:row atIndex:newRowIndex];
	[self addSubview:row];
	needsLayout = YES;
}

- (void) removeRowAtIndex:(NSUInteger)removeRowIndex{
	[[_rows objectAtIndex:removeRowIndex] removeFromSuperview];
	[_rows removeObjectAtIndex:removeRowIndex];
	needsLayout = YES;
}

- (NSArray *)rows{
	return _rows;
}


#pragma mark -
#pragma mark Layout/Drawing

- (void) layoutIfNeeded{
	if(needsLayout){
		CGFloat yCursor = padding.height;
		
		for(WWCardEditorRow *row in _rows){
			CGFloat neededHeight = [row neededHeight];
			[row setFrame:NSMakeRect(padding.width, yCursor,[self frame].size.width - (padding.width*2), neededHeight)];
			yCursor += neededHeight + rowSpacing;
		}
		
		needsLayout = NO;	
	}
}

- (void) viewWillDraw{
	[self layoutIfNeeded];
}

- (void)drawRect:(NSRect)rect {
	
	if(backgroundColor){
		[backgroundColor set];
		NSRectFill([self bounds]);
	}
	
	//[super drawRect:rect];
	
	CGContextRef myContext = [[NSGraphicsContext currentContext] graphicsPort];
	
	CGMutablePathRef glyphPath = CGPathCreateMutable();
	NSUInteger totalRectCount = 0;
	
	for(WWCardEditorRow *row in _rows){
		NSUInteger rectCount = 0;
		NSRectArray rects = [row requestedFocusRectArrayAndCount:&rectCount];
		totalRectCount += rectCount;
		
		for(NSUInteger i = 0; i < rectCount; i++){
			NSRect nsRect = NSInsetRect([self convertRect:rects[i] fromView:row],-1*focusRingPadding.width,-1*focusRingPadding.height);
			
			// avoid drawing on pixel cracks:
			CGRect cgRect = CGRectMake(floor(nsRect.origin.x), floor(nsRect.origin.y), floor(nsRect.size.width), floor(nsRect.size.height));
			cgRect = CGRectInset(cgRect, -0.5, -0.5); 
			
			CGPathAddRect(glyphPath, nil, cgRect);
		}
	}
	
	if(!totalRectCount){
		return;
	}
	
	// Draw the white rectangles
	CGContextBeginPath(myContext);
	CGContextAddPath(myContext, glyphPath);
	CGContextClosePath(myContext);
	[backgroundColor set];
	CGContextFillPath(myContext);
	
	//Draw a fancy drop shadow if our window has focus
	if([[self window] isKeyWindow]){
		CGContextBeginPath(myContext);
		CGContextAddPath(myContext, glyphPath);
		CGContextClosePath(myContext);
	
		CGContextSetShadowWithColor(myContext, CGSizeMake(3.5, -3.5), 5.0, [[NSColor colorWithDeviceWhite:0 alpha:0.9] asCGColor]);
		CGContextFillPath(myContext);
		CGContextSetShadowWithColor(myContext, CGSizeMake(0,0), 0, nil);
	}
	
	// Draw the borders
	CGContextBeginPath(myContext);
	CGContextAddPath(myContext, glyphPath);
	CGContextClosePath(myContext);
	
	[[self focusRingBorderColor] set];
	CGContextStrokePath(myContext);
			
	[super drawRect:rect];
}

- (BOOL) isFlipped{
	return YES;
}

- (void) setNeedsDisplay{
	[self setNeedsDisplay:YES];
}


#pragma mark -
- (void) _selectNextRowResponder{
	WWFlowFieldRow *activeRow = [self currentlyActiveRow];
	if(activeRow){
		for(NSUInteger i = [_rows indexOfObject:activeRow] + 1; i < [_rows count]; i++){

			WWFlowFieldRow *row = [_rows objectAtIndex:i];
			
			if([row principalResponder]){
				[[self window] makeFirstResponder:[row principalResponder]];
				return;
			}
		}
		
		// If we've reached this point, there's no next row that can become a responder, so select our own next responder 
		[[self nextResponder] becomeFirstResponder];
		
	}else{
		// If there's no active row, just select the first row that we're able to
		[[self _firstRowWithResponder] becomeFirstResponder];
		
		WWFlowFieldRow *firstRow = [self _firstRowWithResponder];
		if(firstRow){
			[[self window] makeFirstResponder:[firstRow principalResponder]];
		}
	}
}

- (void) _selectPreviousRowResponder{
	WWFlowFieldRow *activeRow = [self currentlyActiveRow];
	if(activeRow){
		NSUInteger activeRowIndex = [_rows indexOfObject:activeRow];
		if(activeRowIndex == 0){
			[[self window] makeFirstResponder:[self previousKeyView]];
			return;
		}
		
		for(NSUInteger i = [_rows indexOfObject:activeRow] - 1; i >= 0; i--){
			WWFlowFieldRow *row = [_rows objectAtIndex:i];
			if([row principalResponder]){
				[[self window] makeFirstResponder:[row principalResponder]];
				return;
			}
		}
		
	}
	
}



- (WWFlowFieldRow *)currentlyActiveRow{
	for(WWFlowFieldRow *row in _rows){
		if([row principalResponder] == [[self window] firstResponder]){
			return row;
		}
	}
	
	return nil;
}


- (WWFlowFieldRow *)_firstRowWithResponder{
	for(WWFlowFieldRow *row in _rows){
		if([row principalResponder]){
			return row;
		}
	}
	
	return nil;
}

@end

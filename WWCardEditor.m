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
#import "WWFlowFieldRow.h"
#import "WWFlowFieldRow_Internals.h"

@interface WWCardEditor()
@property(retain) NSMutableArray *_rows;
@property(retain) NSMutableDictionary *_rowNameIndex;
@end

#pragma mark -

@implementation WWCardEditor
@synthesize needsLayout, _rows, _rowNameIndex;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		
		self._rows = [NSMutableArray array];
		self._rowNameIndex = [NSMutableDictionary dictionary];
		self.keyLabelColor = [NSColor blackColor];
		self.keyLabelFont = [NSFont fontWithName:@"Helvetica Bold" size:11];
		
		self.padding = CGSizeMake(10, 10);
		self.rowSpacing = 0;
		self.backgroundColor = [NSColor whiteColor];
		
		self.focusRingBorderColor = [NSColor lightGrayColor];
		self.focusRingPadding = CGSizeMake(3, 3);
    }
    return self;
}

- (void) dealloc{
	self._rows = nil;
	self._rowNameIndex = nil;
	
	self.keyLabelColor = nil;
	self.keyLabelFont = nil;
	self.focusRingBorderColor = nil;
	self.backgroundColor = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow{
	// Register for notifications when the window becomes or resigns key, so that we can redraw the control
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	// stop observing the old window
	[nc removeObserver:self name:NSWindowDidBecomeKeyNotification object:[self window]];
	[nc removeObserver:self name:NSWindowDidResignKeyNotification object:[self window]];
	
	// start observing the new one
	[nc addObserver:self selector:@selector(setNeedsDisplay) name:NSWindowDidBecomeKeyNotification object:newWindow];
	[nc addObserver:self selector:@selector(setNeedsDisplay) name:NSWindowDidResignKeyNotification object:newWindow];
}

+ (void) initialize{
	[self exposeBinding:@"keyLabelColor"];
	[self exposeBinding:@"backgroundColor"];
	[self exposeBinding:@"padding"];
	[self exposeBinding:@"rowSpacing"];
	[self exposeBinding:@"rowsByName"];
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
	if(!row){
		@throw [NSException exceptionWithName:@"WWCardEditor" reason:@"attempt to add nil row" userInfo:nil];
	}

	
	[self willChangeValueForKey:@"rows"];
	[_rows insertObject:row atIndex:newRowIndex];
	[self didChangeValueForKey:@"rows"];
	
	
	if([row name]){
		[self willChangeValueForKey:@"rowsByName"];
		[_rowNameIndex setObject:row forKey:[row name]];
		[self didChangeValueForKey:@"rowsByName"];
	}
	
	
	row.parentEditor = self;
	[self addSubview:row];
	needsLayout = YES;
}


- (void) removeRowAtIndex:(NSUInteger)removeRowIndex{
	WWCardEditorRow *theRow = [_rows objectAtIndex:removeRowIndex];
	theRow.parentEditor = nil;
	
	[self willChangeValueForKey:@"rows"];
	[_rows removeObjectAtIndex:removeRowIndex];
	[self didChangeValueForKey:@"rows"];
	
	if([theRow name]){
		[self willChangeValueForKey:@"rowsByName"];
		[_rowNameIndex removeObjectForKey:[theRow name]];
		[self didChangeValueForKey:@"rowsByName"];
	}
	
	[theRow removeFromSuperview];
	
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
	[self setNeedsDisplay:YES];
	
	
	WWFlowFieldRow *activeRow = [self currentlyActiveRow];
	if(activeRow){
		for(NSUInteger i = [_rows indexOfObject:activeRow] + 1; i < [_rows count]; i++){

			WWFlowFieldRow *row = [_rows objectAtIndex:i];
			
			if([[row principalResponders] count]){
				[[self window] makeFirstResponder:[[row principalResponders] objectAtIndex:0]];
				
				if([row isMemberOfClass:[WWFlowFieldRow class]]){
					[((WWFlowFieldRow *)row) _selectFirstEditableSubfield];
				}
				
				return;
			}
		}
		
		// If we've reached this point, there's no next row that can become a responder, so select our own next responder 
		[[self nextResponder] becomeFirstResponder];
		
	}else{
		// If there's no active row, just select the first row that we're able to
		[[self _firstRowWithResponder] becomeFirstResponder];
		
		WWFlowFieldRow *firstRow = [self _firstRowWithResponder];
		if(firstRow && [[firstRow principalResponders] count]){
			[[self window] makeFirstResponder:[[firstRow principalResponders] objectAtIndex:0]];
		}
	}
}

- (void) _selectPreviousRowResponder{
	[self setNeedsDisplay:YES];
	
	WWFlowFieldRow *activeRow = [self currentlyActiveRow];
	if(activeRow){
		NSUInteger activeRowIndex = [_rows indexOfObject:activeRow];
		if(activeRowIndex == 0){
			[[self window] makeFirstResponder:[self previousKeyView]];
			return;
		}
		
		for(NSUInteger i = [_rows indexOfObject:activeRow] - 1; i >= 0; i--){
			WWFlowFieldRow *row = [_rows objectAtIndex:i];
			if([[row principalResponders] count]){
				[[self window] makeFirstResponder:[[row principalResponders] objectAtIndex:0]];
				
				if([row isMemberOfClass:[WWFlowFieldRow class]]){
					[((WWFlowFieldRow *)row) _selectLastEditableSubfield];
				}
				
				return;
			}
		}
		
	}
	
}


- (WWFlowFieldRow *)currentlyActiveRow{
	for(WWFlowFieldRow *row in _rows){
		if([[row principalResponders] containsObject:[[self window] firstResponder]]){
			return row;
		}
	}
	
	return nil;
}


- (WWFlowFieldRow *)_firstRowWithResponder{
	for(WWFlowFieldRow *row in _rows){
		if([[row principalResponders] count]) return row;
	}
	
	return nil;
}



- (NSDictionary *)rowsByName{
    return _rowNameIndex;
}


@end
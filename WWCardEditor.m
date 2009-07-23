//
//  WWCardEditor.m
//  WWCardEditor
//
//  Created by Dan Grover on 6/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WWCardEditor.h"
#import "WWCardEditorRow.h"
#import "WWCardEditorRow_Internals.h"

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
    }
    return self;
}


- (void) dealloc{
	self.keyLabelColor = nil;
	self.keyLabelFont = nil;
	self.backgroundColor = nil;
	[super dealloc];
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
		needsLayout = YES;
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

- (void)drawRect:(NSRect)rect {
	[self layoutIfNeeded];
	
	if(backgroundColor){
		[backgroundColor set];
		NSRectFill(rect);
	}
	
	[super drawRect:rect];
}

- (BOOL) isFlipped{
	return YES;
}

@end

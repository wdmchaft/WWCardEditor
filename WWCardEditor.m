//
//  WWCardEditor.m
//  WWCardEditor
//
//  Created by Dan Grover on 6/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WWCardEditor.h"

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
		self.backgroundColor = [NSColor whiteColor];
    }
    return self;
}


- (void) dealloc{
	[self setKeyLabelColor:nil];
	[self setKeyLabelFont:nil];
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

#pragma mark -

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

- (void) layoutIfNeeded{
	if(needsLayout){
		CGFloat yCursor = padding.height;
		
		for(WWCardEditorRow *row in _rows){
			CGFloat neededHeight = [row neededHeight];
			[row setFrame:NSMakeRect(padding.width, yCursor,[self frame].size.width, neededHeight)];
			yCursor += neededHeight;
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

- (CGSize)padding {
    return padding;
}

- (void)setPadding:(CGSize)aPadding {
    padding = aPadding;
	needsLayout = YES;
	[self setNeedsDisplay:YES];
}




- (BOOL) isFlipped{
	return YES;
}
@end

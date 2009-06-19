//
//  WWKeyValueRow.m
//  WWCardEditor
//
//  Created by Dan Grover on 6/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WWKeyValueRow.h"
#import "WWCardEditor.h"

@interface WWKeyValueRow()
- (void) _layoutIfNeeded;
@end

#pragma mark -

@implementation WWKeyValueRow

- (id)init{
    if (self = [super initWithFrame:NSZeroRect]){
		splitPosition = 100;
    }
    return self;
}

- (void)dealloc {
    [self setKeyLabel:nil];
	
    [super dealloc];
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

- (void) _layoutIfNeeded{
	if(needsLayout){
		[valueRowView setFrame:NSMakeRect(splitPosition, 0, [self frame].size.width - splitPosition, [valueRowView neededHeight])];
		needsLayout = NO;
	}
}


#pragma mark -

- (CGFloat) neededHeight{
	return MAX([valueRowView neededHeight],20);
}

- (void)drawRect:(NSRect)rect {
	[self _layoutIfNeeded];
	
	NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
	
	[attrs setObject:parentEditor.keyLabelFont forKey:NSFontAttributeName];
	[attrs setObject:parentEditor.keyLabelColor forKey:NSForegroundColorAttributeName];
	
	NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
	[style setAlignment:NSRightTextAlignment];
	[attrs setObject:[style autorelease] forKey:NSParagraphStyleAttributeName];
	
	[keyLabel drawInRect:NSMakeRect(0, 0, splitPosition - 10, 20) withAttributes:attrs];
	[super drawRect:rect];
}

@end
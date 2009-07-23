//
//  WW_checkboxRow.m
//  WWCardEditor
//
//  Created by Dan Grover on 7/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WWCheckboxRow.h"
#import "WWCardEditor_Internals.h"


@interface WWCheckboxRow()
@property(retain) NSButton *_checkbox;
- (void) _layoutIfNeeded;
@end

#pragma mark -

@implementation WWCheckboxRow
@synthesize _checkbox;

- (id)init{
    if (self = [super initWithFrame:NSZeroRect]){
		self._checkbox = [[[NSButton alloc] initWithFrame:NSZeroRect] autorelease];
		
		[_checkbox setButtonType:NSSwitchButton];
		[_checkbox setBezelStyle:NSRegularSquareBezelStyle];
		[[_checkbox cell] setControlSize:NSSmallControlSize];
		[self addSubview:_checkbox];
		[self setEditMode:[super editMode]];
		needsLayout = YES;
    }
	
    return self;
}

- (void)dealloc {
	self._checkbox = nil;
	
    [super dealloc];
}
						 
- (void) _layoutIfNeeded{
	if(needsLayout){
		[_checkbox setFrame:NSMakeRect(0, 0, [self availableWidth], [self neededHeight])];
		needsLayout = NO;
	}
}

- (CGFloat) neededHeight{
	return MAX(16, [[_checkbox title] sizeWithAttributes:[NSDictionary dictionaryWithObject:[_checkbox font] forKey:NSFontAttributeName]].height);
}
						
#pragma mark -
#pragma mark Accessors

- (BOOL)isChecked {
	return [_checkbox intValue];
}

- (void)setIsChecked:(BOOL)flag {
	[_checkbox setIntValue:flag];
}

- (NSString *)label {
	return [_checkbox title];
}

- (void)setLabel:(NSString *)aLabel {
	[_checkbox setTitle:aLabel];
}


- (void)setEditMode:(BOOL)flag {
	[_checkbox setEnabled:flag];
	[super setEditMode:flag];
}

- (NSFont *)font {
    return [_checkbox font];
}

- (void)setFont:(NSFont *)aFont{
    [_checkbox setFont:aFont];
}

#pragma mark -

- (BOOL) isFlipped{
	return YES;
}

- (void)drawRect:(NSRect)rect {
	[self _layoutIfNeeded];
	[super drawRect:rect];
}

@end

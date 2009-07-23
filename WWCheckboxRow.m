//
//  WWCheckboxRow.m
//  WWCardEditor
//
//  Created by Dan Grover on 7/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WWCheckboxRow.h"


@interface WWCheckboxRow()
@property(retain) NSButton *checkbox;
- (void) _layoutIfNeeded;
@end

#pragma mark -

@implementation WWCheckboxRow
@synthesize checkbox;

- (id)init{
    if (self = [super initWithFrame:NSZeroRect]){
		self.checkbox = [[[NSButton alloc] initWithFrame:NSZeroRect] autorelease];
		
		[checkbox setButtonType:NSSwitchButton];
		[checkbox setBezelStyle:NSRegularSquareBezelStyle];
		[[checkbox cell] setControlSize:NSSmallControlSize];
		[self addSubview:checkbox];
		needsLayout = YES;
    }
	
    return self;
}

- (void)dealloc {
	self.checkbox = nil;
	
    [super dealloc];
}
						 
- (void) _layoutIfNeeded{
	if(needsLayout){
		[checkbox setFrame:NSMakeRect(0,0,[[self superview] frame].size.width,[self neededHeight])];
		needsLayout = NO;
	}
}

- (CGFloat) neededHeight{
	return 25;
}
						
#pragma mark -
#pragma mark Accessors

- (BOOL)isChecked {
	return [checkbox intValue];
}

- (void)setIsChecked:(BOOL)flag {
	[checkbox setIntValue:flag];
}

- (NSString *)label {
	return [checkbox title];
}

- (void)setLabel:(NSString *)aLabel {
	[checkbox setTitle:aLabel];
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

//
//  WWCardEditorRow.m
//  WWCardEditor
//
//  Created by Dan Grover on 6/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WWCardEditorRow.h"


@implementation WWCardEditorRow
@synthesize parentEditor, editMode;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (CGFloat) neededHeight{
	@throw [NSException exceptionWithName:@"WWCardEditorRow" reason:@"WWCardEditorRow had neededHeight called on it -- this should not be used directly" userInfo:nil];
}

- (void)drawRect:(NSRect)rect{
	[[NSColor redColor] set];
	[NSBezierPath strokeRect:[self bounds]];
}

@end

//
//  WWCardEditorRow.m
//  WWCardEditor
//
//  Created by Dan Grover on 6/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WWCardEditorRow.h"
#import "WWCardEditor_Internals.h"

@implementation WWCardEditorRow
@synthesize parentEditor, parentRow, editMode;

- (id)initWithName:(NSString *)theName {
    if (self = [super initWithFrame:NSZeroRect]) {
		
    }
    return self;
}


- (CGFloat) neededHeight{
	return 0;
	//@throw [NSException exceptionWithName:@"WWCardEditorRow" reason:@"WWCardEditorRow had neededHeight called on it -- this should not be used directly" userInfo:nil];
}

- (void)drawRect:(NSRect)rect{
	//[[NSColor redColor] set];
	//[NSBezierPath strokeRect:[self bounds]];
	[super drawRect:rect];
}


- (CGFloat) availableWidth{
	if(parentRow){
		return [parentRow availableWidth];
	}else{
		return [parentEditor frame].size.width - [parentEditor padding].width*2;
	}
}

- (NSRectArray) requestedFocusRectArrayAndCount:(NSUInteger *)count{
	*count = 0;
	return nil;
}

- (BOOL) isFlipped{
	return YES;
}

- (NSResponder *)principalResponder{
	return nil;
}

@end

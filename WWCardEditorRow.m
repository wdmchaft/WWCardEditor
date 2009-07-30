//
//  WWCardEditorRow.m
//  WWCardEditor
//
//  Created by Dan Grover on 6/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WWCardEditorRow.h"
#import "WWCardEditor_Internals.h"
#import <objc/runtime.h>

static BOOL debugMode;

@implementation WWCardEditorRow
@synthesize parentEditor, parentRow, editMode, name;

- (id)initWithName:(NSString *)theName {
    if (self = [super initWithFrame:NSZeroRect]) {
		
    }
    return self;
}

+ (void) setDebugDrawMode:(BOOL)newVal{
	debugMode = newVal;
}


- (CGFloat) neededHeight{
	return 0;
	//@throw [NSException exceptionWithName:@"WWCardEditorRow" reason:@"WWCardEditorRow had neededHeight called on it -- this should not be used directly" userInfo:nil];
}

- (void)drawRect:(NSRect)rect{
	if(debugMode){
		// Draw a rectangle of the bounds of this row
		[[NSColor redColor] set];
		[NSBezierPath strokeRect:[self bounds]];
		
		// Draw the class name in a little rect in the corner
		NSString *className = [NSString stringWithCString:class_getName([self class])];
		
		NSMutableDictionary *drawAttrs = [NSMutableDictionary dictionaryWithObject:[NSFont systemFontOfSize:8] forKey:NSFontAttributeName];
		[drawAttrs setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
		
		NSSize textSize = [className sizeWithAttributes:drawAttrs];
		NSRectFill(NSMakeRect(0, 0, textSize.width+2, textSize.height+2));
		[className drawAtPoint:NSMakePoint(1,1) withAttributes:drawAttrs];
	}
	
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

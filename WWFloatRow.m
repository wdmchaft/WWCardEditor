//
//  WWFloatRow.m
//  WWCardEditor
//
//  Created by Dan Grover on 8/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WWFloatRow.h"
#import "WWCardEditor_Internals.h"

@interface WWFloatRow()


@end

#pragma mark -

@implementation WWFloatRow

- (id)initWithName:(NSString *)theName{
    if (self = [super initWithName:theName]){
		
    }
	
    return self;
}

- (void)dealloc {
	
    [super dealloc];
}


- (CGFloat)spacing {
    return spacing;
}

- (void)setSpacing:(CGFloat)theSpacing {
    spacing = theSpacing;
	_needsLayout = YES;
}


- (CGFloat) neededHeight{
	CGFloat soFar = 0;
	
	for(unsigned i = 1; i < [_subrows count]; i++){
		WWCardEditorRow *row = [_subrows objectAtIndex:i];
		soFar += [row neededHeight] + [parentEditor rowSpacing];
	}

	soFar = MAX(soFar,[[_subrows objectAtIndex:0] neededHeight]);
	
	return soFar;
}

- (CGFloat) neededWidth{
	CGFloat widestRow = 0;

	for(unsigned i = 1; i < [_subrows count]; i++){
		widestRow = MAX(widestRow,[[_subrows objectAtIndex:i] neededWidth]);
	}
	
	if([_subrows count]){
		widestRow += [[_subrows objectAtIndex:0] neededWidth];
	}
	
	
	return widestRow;
}






#pragma mark -

- (void) _layoutIfNeeded{
	if(_needsLayout){
		if(![_subrows count]) return;
		
		WWCardEditorRow *floatedRow = [_subrows objectAtIndex:0];
		[floatedRow setFrame:NSMakeRect(0,0,[floatedRow neededWidth],[floatedRow neededHeight])];
		
		CGFloat xCursor = [floatedRow neededWidth] + spacing;
		CGFloat yCursor = 0;
		
		for(unsigned i = 1; i < [_subrows count]; i++){
			WWCardEditorRow *row = [_subrows objectAtIndex:i];
			[row setFrame:NSMakeRect(xCursor, yCursor, [self availableWidth] - xCursor, [row neededHeight])];
			yCursor += [row neededHeight];
			NSLog(@"row frame for %d is %@",i,NSStringFromRect([row frame]));
		}
		
		
		
		parentEditor.needsLayout = YES;
	}
}
			
- (void) viewWillDraw{
	[self _layoutIfNeeded];
}

- (void)drawRect:(NSRect)rect{
	[self _layoutIfNeeded];
}

@end
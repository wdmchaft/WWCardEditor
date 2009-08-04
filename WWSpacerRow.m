//
//  WWSpacerRow.m
//  WWCardEditor
//
//  Created by Dan Grover on 7/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WWSpacerRow.h"
#import "WWCardEditor_Internals.h"

@implementation WWSpacerRow

- (CGFloat)height {
    return height;
}

- (void)setHeight:(CGFloat)anHeight {
    height = anHeight;
	[parentEditor setNeedsLayout:YES];
}

- (CGFloat) neededHeight{
	return height;
}

@end

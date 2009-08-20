//
//  WWFloatRow.h
//  WWCardEditor
//
//  Created by Dan Grover on 8/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WWCardEditorRow.h"
#import "WWAbstractContainerRow.h"


@interface WWFloatRow : WWAbstractContainerRow {
	CGFloat spacing;
	
}

@property(assign) CGFloat spacing;

@end
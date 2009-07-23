//
//  WWCardEditorRow_Internals.h
//  WWCardEditor
//
//  Created by Dan Grover on 7/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface WWCardEditorRow()

@property(assign) WWCardEditor *parentEditor; // weak references to parents
@property(assign) WWCardEditorRow *parentRow; 

- (CGFloat) neededHeight;
- (CGFloat) availableWidth;

@end
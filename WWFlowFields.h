//
//  WWFlowFields.h
//  WWCardEditor
//
//  Created by Dan Grover on 6/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WWFlowField : NSObject{
	NSString *name;
	NSString *value;
	NSFont *font;
}

@property(retain) NSString *name;
@property(retain) NSString *value;
@property(retain) NSFont *font;

- (id) initWithName:(NSString *)theName;


@end

#pragma mark -

@interface WWEditableFlowField : WWFlowField{
	NSString *placeholder;
}

@property(retain) NSString *placeholder;

@end

#pragma mark -

@interface WWImmutableStringFlowField : WWFlowField{
	
}

@end

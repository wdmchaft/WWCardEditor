//
//  WWFlowFields.m
//  WWCardEditor
//
//  Created by Dan Grover on 6/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WWFlowFields.h"

@implementation WWFlowField 
@synthesize name, value, font;

- (id) initWithName:(NSString *)theName{
	if(self = [super init]){
		self.font = [NSFont fontWithName:@"Helvetica" size:12];
		self.value = @"";
		self.name = theName;
	}
	
	return self;
}


- (void) dealloc{
	[name release];
	[value release];
	[font release];
	[super dealloc];
}

@end

#pragma mark -

@implementation WWEditableFlowField


@end

#pragma mark -

@implementation WWImmutableStringFlowField


@end
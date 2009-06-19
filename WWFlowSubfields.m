//
//  WWFlowFields.m
//  WWCardEditor
//
//  Created by Dan Grover on 6/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WWFlowSubfields.h"

@implementation WWFlowSubfield 
@synthesize name, value, font;

- (id) initWithName:(NSString *)theName{
	if(self = [super init]){
		self.font = [NSFont fontWithName:@"Helvetica" size:12];
		self.value = @"";
		self.name = theName;
	}
	
	return self;
}

- (NSString *) description{
	return [NSString stringWithFormat:@"<WWFlowField: name = %@, value = %@>",name, value];
}

- (NSAttributedString *) displayString{
	return [[[NSAttributedString alloc] initWithString:self.value 
											attributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]] autorelease];
}

- (BOOL) _isDisplayedAsPlaceholder{
	return NO;
}


- (void) dealloc{
	[name release];
	[value release];
	[font release];
	[super dealloc];
}

@end

#pragma mark -

@implementation WWEditableFlowSubfield
@synthesize placeholder;

- (id) initWithName:(NSString *)theName{
	if(self = [super initWithName:theName]){
		self.placeholder = theName;
	}
	
	return self;
}

- (void) dealloc{
	[placeholder release];
	[super dealloc];
}
	
- (NSAttributedString *) _displayString{
	if([self _isDisplayedAsPlaceholder]){
		NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
		[attrs setObject:font forKey:NSFontAttributeName];
		[attrs setObject:[NSColor lightGrayColor] forKey:NSForegroundColorAttributeName];

		return [[[NSAttributedString alloc] initWithString:self.value attributes:attrs] autorelease];
	}else{
		return [super displayString];
	}
}

- (BOOL) _isDisplayedAsPlaceholder{
	return (!value || [value isEqual:@""]);
}


@end

#pragma mark -

@implementation WWImmutableStringFlowSubfield


@end
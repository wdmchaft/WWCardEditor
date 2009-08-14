//
//  WWFlowFields.m
//  WWCardEditor
//
//  Created by Dan Grover on 6/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WWFlowFieldSubfield.h"

@interface WWFlowFieldSubfield()
@property(retain,readwrite) NSString *name; 
@end

@implementation WWFlowFieldSubfield 
@synthesize name, font, editable, placeholder, allowsNewlines;

- (id) init{
	if(self = [self initWithName:nil]){
		
	}
	
	return self;
}

- (id) initWithName:(NSString *)theName{ // designated init
	if(self = [super init]){
		self.font		 = [NSFont fontWithName:@"Helvetica" size:12];
		self.value		 = @"";
		self.name		 = theName;
		self.placeholder = @"Empty";
		self.editable	 = YES;
	}
	
	return self;
}

- (void) dealloc{
	self.name = nil;
	self.value = nil;
	self.font = nil;
	self.placeholder = nil;
	[super dealloc];
}


- (NSString *) description{
	return [NSString stringWithFormat:@"<WWFlowFieldSubfield: name = %@, editable = %d, value = %@>", name, editable, value];
}

+ (void) initialize{
	[self exposeBinding:@"value"];
	[self exposeBinding:@"editable"];
	[self exposeBinding:@"font"];
	[self exposeBinding:@"placeholder"];
}

- (NSString *)value {
    return value; 
}
- (void)setValue:(NSString *)aValue {
    if (value != aValue) {
		if(!aValue || [aValue isEqual:[NSNull null]]) aValue = @"";
        [value release];
        value = [aValue retain];
    }
}



#pragma mark -
#pragma mark Convenience Factory Methods

+ (WWFlowFieldSubfield *) editableSubfieldWithName:(NSString *)fieldName placeholder:(NSString *)placeholderString initialValue:(NSString *)initialValue{
	WWFlowFieldSubfield *field = [[WWFlowFieldSubfield alloc] initWithName:fieldName];
	field.editable = YES;
	field.placeholder = placeholderString;
	field.value = initialValue;
	return [field autorelease];
}


+ (WWFlowFieldSubfield *) uneditableSubfieldWithName:(NSString *)fieldName initialValue:(NSString *)initialValue{
	WWFlowFieldSubfield *field = [[WWFlowFieldSubfield alloc] initWithName:fieldName];
	field.editable = NO;
	field.value = initialValue;
	return [field autorelease];
}

+ (WWFlowFieldSubfield *) uneditableSpace{
	return [WWFlowFieldSubfield uneditableSubfieldWithName:nil initialValue:@" "];
}

+ (WWFlowFieldSubfield *) uneditableNewline{
	return [WWFlowFieldSubfield uneditableSubfieldWithName:nil initialValue:@"\n"];
}

// TODO: unit test this shiznit
// TODO: maybe make this more efficient if it becomes a problem (it's at least O(n^2) now)
+ (NSArray *)subfieldsWithFormat:(NSString *)format tokensAndReplacements:(NSDictionary *)subs{
	NSMutableArray *soFar = [NSMutableArray array];
	
	// Scan through the format string...
	NSMutableString *currentTerm = [NSMutableString string];
	
	for(NSUInteger formatOffset = 0; formatOffset < [format length]; formatOffset++){
		[currentTerm appendString:[format substringWithRange:NSMakeRange(formatOffset,1)]];
		
		// Check if any right-aligned substring of currentTerm matches any token
		NSRange matchRange = NSMakeRange(NSNotFound, 0);
		for(unsigned potentialTokenLength = 0; potentialTokenLength <= [currentTerm length]; potentialTokenLength++){
			NSString *potentialToken = [currentTerm substringFromIndex:[currentTerm length] - potentialTokenLength];
			
			if([subs objectForKey:potentialToken]){ // We gots us a match
				matchRange.location = [currentTerm length] - potentialTokenLength;
				matchRange.length   = potentialTokenLength;
				break;
			}
		}
		
		// If there was a match...
		if(matchRange.location != NSNotFound){
			// Put the non-matching left side (if any) as an uneditable subfield
			if(matchRange.location > 0){
				NSString *nonMatchingPortion = [currentTerm substringToIndex:matchRange.location];
				[soFar addObject:[WWFlowFieldSubfield uneditableSubfieldWithName:nil initialValue:nonMatchingPortion]];
			}
			
			// Put the matching right side as an editable subfield
			NSString *matchingPortion = [currentTerm substringFromIndex:matchRange.location];
			[soFar addObject:[subs objectForKey:matchingPortion]];
			
			// Reset currentTerm so we can match the next potential term/token
			currentTerm = [NSMutableString string];
		}
		
		// Keep scanning...
	}
	
	// If there's a non-matching part at the end, we need to catch this too
	if([currentTerm length]){
		[soFar addObject:[WWFlowFieldSubfield uneditableSubfieldWithName:nil initialValue:currentTerm]];
	}
	
	return soFar;
}


@end
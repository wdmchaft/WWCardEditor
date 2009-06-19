//
//  TestController.m
//  WWCardEditor
//
//  Created by Dan Grover on 6/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TestController.h"


@implementation TestController


- (void) awakeFromNib{
	NSLog(@"Hi!");
	
	NSFont *bigFont = [NSFont fontWithName:@"Helvetica Bold" size:18];
	
	WWFlowFieldSubfield *firstName = [WWFlowFieldSubfield editableFieldWithName:@"firstName" placeholder:@"First" initialValue:@"Dan"];
	firstName.font = bigFont;
	
	WWFlowFieldSubfield *nameSpace = [WWFlowFieldSubfield uneditableSpace];
	nameSpace.font = bigFont;
	
	WWFlowFieldSubfield *lastName = [WWFlowFieldSubfield editableFieldWithName:@"lastName" placeholder:@"Last" initialValue:@"Grover"];
	lastName.font = bigFont;
	
	WWFlowFieldSubfield *addyLine1 = [WWFlowFieldSubfield editableFieldWithName:@"addressLine1" placeholder:@"Address" initialValue:@"504 Page St"];
	WWFlowFieldSubfield *city = [WWFlowFieldSubfield editableFieldWithName:@"city" placeholder:@"City" initialValue:@"San Francisco"];
	WWFlowFieldSubfield *cityComma = [WWFlowFieldSubfield uneditableFieldWithName:@"cityComma" initialValue:@", "];
	WWFlowFieldSubfield *state = [WWFlowFieldSubfield editableFieldWithName:@"state" placeholder:@"State" initialValue:@"CA"];
	WWFlowFieldSubfield *zipSpace = [WWFlowFieldSubfield uneditableSpace];
	WWFlowFieldSubfield *zip = [WWFlowFieldSubfield editableFieldWithName:@"zip" placeholder:@"ZIP" initialValue:@"94117"];

	
	
	NSArray *fields = [NSArray arrayWithObjects:firstName,nameSpace,lastName,[WWFlowFieldSubfield uneditableNewline],addyLine1,[WWFlowFieldSubfield uneditableNewline],city,cityComma,state,zipSpace,zip,nil];
	NSLog(@"Setting fields = %@",fields);
	flowFieldContainer.fields = fields;
	
	[self toggleEditMode:nil];

	
	
	/*
	WWFlowFieldRow *flow2 = [[[WWFlowFieldRow alloc] initWithFrame:NSZeroRect] autorelease];
	
	WWFlowSubfield *firstName2 = [[[WWEditableFlowSubfield alloc] initWithName:@"firstName"] autorelease];
	firstName2.value = @"Dan";
	firstName2.font = bigFont;
	
	WWFlowSubfield *nameSpace2 = [[[WWImmutableStringFlowSubfield alloc] initWithName:@"nameSpace"] autorelease];
	nameSpace2.value = @" ";
	nameSpace2.font = bigFont;
	
	WWFlowSubfield *lastName2 = [[[WWEditableFlowSubfield alloc] initWithName:@"lastName"] autorelease];
	lastName2.value = @"Grover";
	lastName2.font = bigFont;
	
	flow2.fields = [NSArray arrayWithObjects:firstName2,nameSpace2,lastName2,nil];
	
	//WWKeyValueRow *kv1 = [[[WWKeyValueRow alloc] init] autorelease];
	//kv1.keyLabel = @"Name";
	//kv1.valueRowView = flow2;
	
	
	WWKeyValueRow *kv2 = [[[WWKeyValueRow alloc] init] autorelease];
	kv2.keyLabel = @"home";
	
	[cardEditor addRow:flow2];
	[cardEditor addRow:kv2];
	[cardEditor setNeedsDisplay:YES];*/

}



- (IBAction) refreshDebugDisplay:(id)sender{
	[debugDisplay setStringValue:[[flowFieldContainer fields] description]];
	
}

- (IBAction) toggleEditMode:(id)sender{
	NSLog(@"New edit mode is %d",[editModeCheckbox intValue]);
	[flowFieldContainer setEditMode:[editModeCheckbox intValue]];
}

@end

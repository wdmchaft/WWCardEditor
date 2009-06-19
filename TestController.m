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
	
	WWFlowSubfield *firstName = [WWFlowSubfield editableFieldWithName:@"firstName" placeholder:@"First" initialValue:@"Dan"];
	firstName.font = bigFont;
	
	WWFlowSubfield *nameSpace = [WWFlowSubfield uneditableSpace];
	nameSpace.font = bigFont;
	
	WWFlowSubfield *lastName = [WWFlowSubfield editableFieldWithName:@"lastName" placeholder:@"Last" initialValue:@"Grover"];
	lastName.font = bigFont;
	

	
	WWFlowSubfield *addyLine1 = [WWFlowSubfield editableFieldWithName:@"addressLine1" placeholder:@"Address" initialValue:@"504 Page St"];
	WWFlowSubfield *city = [WWFlowSubfield editableFieldWithName:@"city" placeholder:@"City" initialValue:@"San Francisco"];
	WWFlowSubfield *cityComma = [WWFlowSubfield uneditableFieldWithName:@"cityComma" initialValue:@", "];
	WWFlowSubfield *state = [WWFlowSubfield editableFieldWithName:@"state" placeholder:@"State" initialValue:@"CA"];
	WWFlowSubfield *zipSpace = [WWFlowSubfield uneditableSpace];
	WWFlowSubfield *zip = [WWFlowSubfield editableFieldWithName:@"zip" placeholder:@"ZIP" initialValue:@"94117"];

	
	
	NSArray *fields = [NSArray arrayWithObjects:firstName,nameSpace,lastName,[WWFlowSubfield uneditableNewline],addyLine1,[WWFlowSubfield uneditableNewline],city,cityComma,state,zipSpace,zip,nil];
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

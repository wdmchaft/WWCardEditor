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
	
	WWEditableFlowSubfield *firstName = [[[WWEditableFlowSubfield alloc] initWithName:@"firstName"] autorelease];
	firstName.value = @"Dan";
	firstName.font = bigFont;
	
	WWImmutableStringFlowSubfield *nameSpace = [[[WWImmutableStringFlowSubfield alloc] initWithName:@"nameSpace"] autorelease];
	nameSpace.value = @" ";
	nameSpace.font = bigFont;
	
	WWEditableFlowSubfield *lastName = [[[WWEditableFlowSubfield alloc] initWithName:@"lastName"] autorelease];
	lastName.value = @"Grover";
	lastName.font = bigFont;
	
	
	WWImmutableStringFlowSubfield *newline1 = [[[WWImmutableStringFlowSubfield alloc] initWithName:@"nl"] autorelease];
	newline1.value = @"\n";
	
	WWEditableFlowSubfield *addyLine1 = [[[WWEditableFlowSubfield alloc] initWithName:@"addyLine1"] autorelease];
	addyLine1.value = @"504 Page St";
	
	WWImmutableStringFlowSubfield *newline2 = [[[WWImmutableStringFlowSubfield alloc] initWithName:@"nl2"] autorelease];
	newline2.value = @"\n";
	
	WWEditableFlowSubfield *city = [[[WWEditableFlowSubfield alloc] initWithName:@"city"] autorelease];
	city.value = @"San Francisco";
	
	WWImmutableStringFlowSubfield *cityComma = [[[WWImmutableStringFlowSubfield alloc] initWithName:@"cityComma"] autorelease];
	cityComma.value = @", ";
	
	WWEditableFlowSubfield *state = [[[WWEditableFlowSubfield alloc] initWithName:@"state"] autorelease];
	state.value = @"CA";
	
	WWImmutableStringFlowSubfield *zipSpace = [[[WWImmutableStringFlowSubfield alloc] initWithName:@"zipSpace"] autorelease];
	zipSpace.value = @" ";
	
	WWEditableFlowSubfield *zip = [[[WWEditableFlowSubfield alloc] initWithName:@"zip"] autorelease];
	zip.value = @"94117";
	
	
	NSArray *fields = [NSArray arrayWithObjects:firstName,nameSpace,lastName,newline1,addyLine1,newline2,city,cityComma,state,zipSpace,zip,nil];
	NSLog(@"Setting fields = %@",fields);
	flowFieldContainer.fields = fields;
	
	[self toggleEditMode:nil];

	
	WWFlowFieldRow *flow2 = [[[WWFlowFieldRow alloc] initWithFrame:NSZeroRect] autorelease];
	
	WWEditableFlowSubfield *firstName2 = [[[WWEditableFlowSubfield alloc] initWithName:@"firstName"] autorelease];
	firstName2.value = @"Dan";
	firstName2.font = bigFont;
	
	WWImmutableStringFlowSubfield *nameSpace2 = [[[WWImmutableStringFlowSubfield alloc] initWithName:@"nameSpace"] autorelease];
	nameSpace2.value = @" ";
	nameSpace2.font = bigFont;
	
	WWEditableFlowSubfield *lastName2 = [[[WWEditableFlowSubfield alloc] initWithName:@"lastName"] autorelease];
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
	[cardEditor setNeedsDisplay:YES];

}



- (IBAction) refreshDebugDisplay:(id)sender{
	[debugDisplay setStringValue:[[flowFieldContainer fields] description]];
	
}

- (IBAction) toggleEditMode:(id)sender{
	NSLog(@"New edit mode is %d",[editModeCheckbox intValue]);
	[flowFieldContainer setEditMode:[editModeCheckbox intValue]];
}

@end

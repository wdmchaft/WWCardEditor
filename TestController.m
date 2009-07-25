//
//  TestController.m
//  WWCardEditor
//
//  Created by Dan Grover on 6/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TestController.h"
#import "WWSpacerRow.h"

@implementation TestController


- (void) awakeFromNib{
	NSLog(@"Hi!");
	
	NSFont *bigFont = [NSFont fontWithName:@"Helvetica Bold" size:18];
	
	
	

	
	WWFlowFieldSubfield *firstName = [WWFlowFieldSubfield editableSubfieldWithName:@"firstName" placeholder:@"First" initialValue:@"Dan"];
	WWFlowFieldSubfield *nameSpace = [WWFlowFieldSubfield uneditableSpace];
	WWFlowFieldSubfield *lastName = [WWFlowFieldSubfield editableSubfieldWithName:@"lastName" placeholder:@"Last" initialValue:@"Grover"];
	lastName.font = nameSpace.font = firstName.font = bigFont;
	
	WWFlowFieldRow *nameRow = [[[WWFlowFieldRow alloc] initWithFrame:NSZeroRect] autorelease];
	nameRow.fields = [NSArray arrayWithObjects:firstName, nameSpace, lastName, nil];
	[cardEditor addRow:nameRow];
	
	WWSpacerRow *spacer = [[[WWSpacerRow alloc] init] autorelease];
	spacer.height = 50;
	[cardEditor addRow:spacer];
	
	WWFlowFieldSubfield *addyLine1 = [WWFlowFieldSubfield editableSubfieldWithName:@"addressLine1" placeholder:@"Address" initialValue:@"504 Page St"];
	WWFlowFieldSubfield *city = [WWFlowFieldSubfield editableSubfieldWithName:@"city" placeholder:@"City" initialValue:@"San Francisco"];
	WWFlowFieldSubfield *cityComma = [WWFlowFieldSubfield uneditableSubfieldWithName:@"cityComma" initialValue:@", "];
	WWFlowFieldSubfield *state = [WWFlowFieldSubfield editableSubfieldWithName:@"state" placeholder:@"State" initialValue:@"CA"];
	WWFlowFieldSubfield *zipSpace = [WWFlowFieldSubfield uneditableSpace];
	WWFlowFieldSubfield *zip = [WWFlowFieldSubfield editableSubfieldWithName:@"zip" placeholder:@"ZIP" initialValue:@"94117"];

	WWFlowFieldRow *addressSubrow = [[[WWFlowFieldRow alloc] initWithFrame:NSZeroRect] autorelease];
	addressSubrow.fields = [NSArray arrayWithObjects:addyLine1,[WWFlowFieldSubfield uneditableNewline],city,cityComma,state,zipSpace,zip,nil];
	
	WWKeyValueRow *addressKeyValueRow = [[[WWKeyValueRow alloc] init] autorelease];
	addressKeyValueRow.keyLabel = @"home";
	addressKeyValueRow.valueRowView = addressSubrow;
	[cardEditor addRow:addressKeyValueRow];
		
	WWCheckboxRow *checkboxRow = [[[WWCheckboxRow alloc] init] autorelease];
	checkboxRow.label = @"Beam Me Up";
	checkboxRow.isChecked = YES;
	
	WWKeyValueRow *checkboxKeyValue = [[[WWKeyValueRow alloc] init] autorelease];
	checkboxKeyValue.keyLabel = @"awesome";
	checkboxKeyValue.valueRowView = checkboxRow;
	checkboxRow.font = [NSFont fontWithName:@"Helvetica" size:11];
	[cardEditor addRow:checkboxKeyValue];
	
	
	[cardEditor setRowSpacing:4];
	[cardEditor setNeedsDisplay:YES];
	[self toggleEditMode:nil];

}


- (IBAction) refreshDebugDisplay:(id)sender{
//	[debugDisplay setStringValue:[[flowFieldContainer fields] description]];
	
}

- (IBAction) toggleEditMode:(id)sender{
	NSLog(@"New edit mode is %d",[editModeCheckbox intValue]);
	[cardEditor setEditMode:[editModeCheckbox intValue]];
	[cardEditor setNeedsDisplay:YES];
}


- (IBAction) triggerLayout:(id)sender{
	[cardEditor setNeedsLayout:YES];
	[cardEditor setNeedsDisplay:YES];
}

@end

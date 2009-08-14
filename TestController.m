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
	// Set up bindings
	[[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
	[cardEditor bind:@"backgroundColor" toObject:bgColorWell withKeyPath:@"color" options:nil];
	[cardEditor bind:@"keyLabelColor" toObject:keyColorWell withKeyPath:@"color" options:nil];
	[cardEditor bind:@"rowSpacing" toObject:rowSpacingSlider withKeyPath:@"floatValue" options:nil];
	
	
	// Set up card editor
	NSFont *bigFont = [NSFont fontWithName:@"Helvetica Bold" size:18];
		
	WWFlowFieldSubfield *firstName = [WWFlowFieldSubfield editableSubfieldWithName:@"first" placeholder:@"First" initialValue:@"Dan"];
	WWFlowFieldSubfield *nameSpace = [WWFlowFieldSubfield uneditableSpace];
	WWFlowFieldSubfield *lastName = [WWFlowFieldSubfield editableSubfieldWithName:@"last" placeholder:@"Last" initialValue:@"Grover"];
	lastName.font = nameSpace.font = firstName.font = bigFont;
	
	WWFlowFieldRow *nameRow = [[[WWFlowFieldRow alloc] initWithName:@"name"] autorelease];
	nameRow.subfields = [NSArray arrayWithObjects:firstName, nameSpace, lastName, nil];
	[cardEditor addRow:nameRow];
	
	WWSpacerRow *spacer = [[[WWSpacerRow alloc] init] autorelease];
	spacer.height = 20;
	[cardEditor addRow:spacer];
	

	// Set up address flowfield example with a format string
	NSMutableDictionary *addressFields = [NSMutableDictionary dictionary];
	[addressFields setObject:[WWFlowFieldSubfield editableSubfieldWithName:@"addressLine1" placeholder:@"Address" initialValue:@"504 Page St"]
					  forKey:@"<line1>"];
	
	[addressFields setObject:[WWFlowFieldSubfield editableSubfieldWithName:@"city" placeholder:@"City" initialValue:@"San Francisco"]
					  forKey:@"<city>"];
	
	[addressFields setObject:[WWFlowFieldSubfield editableSubfieldWithName:@"state" placeholder:@"State" initialValue:@"CA"]
					  forKey:@"<state>"];
	
	[addressFields setObject:[WWFlowFieldSubfield editableSubfieldWithName:@"zip" placeholder:@"ZIP" initialValue:@"94117"] 
					  forKey:@"<zip>"];
	
	WWFlowFieldRow *addressSubrow = [[[WWFlowFieldRow alloc] initWithFrame:NSZeroRect] autorelease];
	addressSubrow.subfields = [WWFlowFieldSubfield subfieldsWithFormat:@"<line1>\n<city>, <state> <zip>" tokensAndReplacements:addressFields];
	
	

	// Put the address field inside a key value row
	WWKeyValueRow *addressKeyValueRow = [[[WWKeyValueRow alloc] initWithName:@"homeAddress"] autorelease];
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
	[cardEditor setEditMode:[editModeCheckbox intValue]];
	[cardEditor setNeedsDisplay:YES];
}

- (IBAction) toggleDebugDrawMode:(id)sender{
	[WWCardEditorRow setDebugDrawMode:[debugModeCheckbox intValue]];
	[cardEditor setNeedsDisplay:YES];
}


- (IBAction) triggerLayout:(id)sender{
	[cardEditor setNeedsLayout:YES];
	[cardEditor setNeedsDisplay:YES];
}

@end

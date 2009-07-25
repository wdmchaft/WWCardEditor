//
//  TestController.h
//  WWCardEditor
//
//  Created by Dan Grover on 6/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WWFlowFieldRow.h"
#import "WWCardEditor.h"
#import "WWKeyValueRow.h"
#import "WWCheckboxRow.h"

@interface TestController : NSObject {
	IBOutlet NSTextField *debugDisplay;
	IBOutlet NSButton *editModeCheckbox;
	IBOutlet WWCardEditor *cardEditor;
	
	IBOutlet NSColorWell *bgColorWell;
	IBOutlet NSColorWell *keyColorWell;
	IBOutlet NSSlider *rowSpacingSlider;
	
	IBOutlet NSButton *debugModeCheckbox;
	
}

- (IBAction) toggleDebugDrawMode:(id)sender;
- (IBAction) refreshDebugDisplay:(id)sender;
- (IBAction) toggleEditMode:(id)sender;
- (IBAction) triggerLayout:(id)sender;

@end
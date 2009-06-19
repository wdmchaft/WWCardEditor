//
//  TestController.h
//  WWCardEditor
//
//  Created by Dan Grover on 6/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WWFlowFieldContainer.h"
#import "WWCardEditor.h"

@interface TestController : NSObject {
	IBOutlet WWFlowFieldContainer *flowFieldContainer;
	IBOutlet NSTextField *debugDisplay;
	IBOutlet NSButton *editModeCheckbox;
	IBOutlet WWCardEditor *cardEditor;
}


- (IBAction) refreshDebugDisplay:(id)sender;
- (IBAction) toggleEditMode:(id)sender;

@end

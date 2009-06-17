//
//  WWFlowFieldContainerTextView.h
//  WWCardEditor
//
//  Created by Dan Grover on 6/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WWFlowFieldContainer;

@interface WWFlowFieldContainerTextView : NSTextView{
	WWFlowFieldContainer *container;
}

@property(assign) WWFlowFieldContainer *container;


@end

//
//  WWFlowFieldContainerTextView.m
//  WWCardEditor
//
//  Created by Dan Grover on 6/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WWFlowFieldRowTextView.h"
#import "WWFlowFieldRow.h"

#import "WWFlowFieldRow_Internals.h"
#import "WWCardEditor_Internals.h"

@implementation WWFlowFieldRowTextView 
@synthesize container;


// some logic for selection will need to be put in the text field itself, to prevent the display of even a prospective selection before it is validated by the delegate


- (NSRange)selectionRangeForProposedRange:(NSRange)proposedSelRange granularity:(NSSelectionGranularity)granularity{
	[[container parentEditor] setNeedsDisplay:YES];
	
	if(!container.editMode){
		return proposedSelRange; // If we're not in edit mode, they can select anything they want
	}
	
	if (proposedSelRange.location == NSNotFound){
		NSLog(@"Allowing proposed sel range %@",NSStringFromRange(proposedSelRange));
		return proposedSelRange; // no selection, that's cool.
	}
	
	NSRange oldSelectedCharRange = [self selectedRange];
	NSUInteger startFieldIndex = [container _indexOfFieldForCharOffset:proposedSelRange.location];
	NSUInteger endFieldIndex   = [container _indexOfFieldForCharOffset:proposedSelRange.location + proposedSelRange.length];
	
	if(startFieldIndex == NSNotFound){
		NSLog(@"MODIFIED AT PROPOSED RANGE: No valid field");
		return NSMakeRange(proposedSelRange.location, 0);
	}
	
	WWFlowFieldSubfield *startField = [container.fields objectAtIndex:startFieldIndex];
	WWFlowFieldSubfield *endField = (endFieldIndex < [container.fields count]) ? [container.fields objectAtIndex:endFieldIndex] : nil;
	
	if(![startField editable]){
		// This is allowable if they're really trying to type at the end of a legal, mutable field
		if (!proposedSelRange.length  && ([container _charOffsetForBeginningOfFieldAtIndex:startFieldIndex] == proposedSelRange.location)){
			NSUInteger potentiallyLegalPreviousFieldIndex = startFieldIndex - 1;
			if((potentiallyLegalPreviousFieldIndex >= 0) && (potentiallyLegalPreviousFieldIndex < [container.fields count]) 
			   && [[container.fields objectAtIndex:potentiallyLegalPreviousFieldIndex] editable])
			{
				return proposedSelRange;
			}
		}
		
		// Otherwise block it
		NSLog(@"REJECTED AT PROPOSED RANGE: Trying to edit immutable field");
		return oldSelectedCharRange;
	}
	else if(!endField || !endField.editable){
		if(proposedSelRange.length > [[container _displayedStringForField:startField] length]){ // Only block this if they're not just trying to get the last character of the active field
			NSLog(@"REJECTED AT PROPOSED RANGE (End): Trying to edit immutable field");
			return oldSelectedCharRange;
		}
	}
	
	// Check that we don't cross fields
	NSUInteger startFieldStartChar = [container _charOffsetForBeginningOfFieldAtIndex:startFieldIndex];
	NSUInteger startFieldEndChar = [container _charOffsetForEndOfFieldAtIndex:startFieldIndex];
	
	if(startFieldIndex != endFieldIndex){
		if((startFieldIndex == container.activeField) && (endFieldIndex > startFieldIndex)){
			NSLog(@"MODIFIED AT PROPOSED RANGE: Can't select ahead across fields, only selecting until end of current field.");
			return NSMakeRange(proposedSelRange.location, [[container _displayedStringForField:startField] length] - (proposedSelRange.location - startFieldStartChar));
		}
		else if((startFieldIndex < container.activeField) && (endFieldIndex >= container.activeField)){
			NSUInteger endFieldStartChar = [container _charOffsetForBeginningOfFieldAtIndex:endFieldIndex];
			NSLog(@"MODIFIED AT PROPOSED RANGE: Can't select behind across fields, only selecting from beginning of end field to end of proposed selection");
			return NSMakeRange(endFieldStartChar, proposedSelRange.location + proposedSelRange.length - endFieldStartChar);
		}
	}

	if(startFieldIndex != container.activeField){
		if(proposedSelRange.length == 0){
			NSLog(@"MODIFIED AT PROPOSED RANGE: Changing active field, length = 0");
			return NSMakeRange(startFieldStartChar,0);
		}else{
			NSLog(@"REJECTED AT PROPOSED RANGE: Can't propose a non-zero-length selection in a non-active field");
			return oldSelectedCharRange;
		}
	}
	
	
	// If they're selecting inside a field, and that field is a placeholder, then forbid it and force them to select its entirety before typing
	if((startFieldIndex == endFieldIndex) && [container _fieldShouldBeDisplayedAsPlaceholder:startField]){
		NSLog(@"MODIFIED AT PROPOSED RANGE: Can't select just part of a placeholder");
		return [container _rangeForFieldAtIndex:startFieldIndex];
	}
	
	return proposedSelRange;
}



// Overrides

- (void)selectAll:(id)sender{
	if(container.activeField != NSNotFound){
		[self setSelectedRange:[container _rangeForFieldAtIndex:container.activeField]];
	}
	
}


- (BOOL)resignFirstResponder{
	//container.isRendering = YES;
	//container.activeField = NSNotFound;
	//container.isRendering = NO;
	return YES;
}

@end
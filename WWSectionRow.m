//
//  WWSectionRow.m
//  WWCardEditor
//
//  Created by Dan Grover on 8/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WWSectionRow.h"
#import "WWCardEditor_Internals.h"
#import "WWCardEditor.h"

#define WWSectionRow_InitialTopPadding 5

#pragma mark -

@interface WWSectionRow()
@property(retain) NSMutableArray *_subrows;
@property(retain) NSMutableDictionary *_subrowsByName;
@property(retain) NSButton *_disclosureTriangle;
- (NSDictionary *) _labelAttributes;
- (void) _layoutIfNeeded;
@end

#pragma mark -

@implementation WWSectionRow
@synthesize _disclosureTriangle, _subrowsByName, _subrows;

- (id)initWithName:(NSString *)theName{
    if (self = [super initWithName:theName]){
		_needsLayout = YES;
		
		self.labelFont = [NSFont fontWithName:@"Helvetica Bold" size:11];
		self.label = @"Section";
		
		self._subrowsByName = [NSMutableDictionary dictionary];
		self._subrows = [NSMutableArray array];
		
		self._disclosureTriangle = [[[NSButton alloc] initWithFrame:NSZeroRect] autorelease];
		[_disclosureTriangle setButtonType:NSPushOnPushOffButton];
		[_disclosureTriangle setBezelStyle:NSDisclosureBezelStyle];
		[_disclosureTriangle setTitle:@""];
		[_disclosureTriangle setTarget:self];
		[_disclosureTriangle setAction:@selector(_disclosureChanged)];
		[self addSubview:_disclosureTriangle];
		
		self.collapsed = NO;
    }
	
    return self;
}

- (void) dealloc{
	self._subrows = nil;
	self._subrowsByName = nil;
	self._disclosureTriangle = nil;
	self.label = nil;
	self.labelFont = nil;
	[super dealloc];
}

+ (void) initialize{
	[self exposeBinding:@"subrows"];
	[self exposeBinding:@"subrowsByName"];
	[self exposeBinding:@"labelFont"];
	[self exposeBinding:@"label"];
}

#pragma mark -
#pragma mark Accessors

- (NSDictionary *) _labelAttributes{
	return [NSDictionary dictionaryWithObject:labelFont forKey:NSFontAttributeName];
}

- (NSString *)label {
    return label; 
}

- (void)setLabel:(NSString *)aLabel {
    if (label != aLabel) {
        [label release];
        label = [aLabel retain];
		[self setNeedsDisplay:YES];
    }
}

- (NSFont *)labelFont {
    return labelFont; 
}

- (void)setLabelFont:(NSFont *)aLabelFont {
    if (labelFont != aLabelFont) {
        [labelFont release];
        labelFont = [aLabelFont retain];
		[self setNeedsDisplay:YES];
		_needsLayout = YES;
    }
}


- (NSArray *)subrows{
	return _subrows;
}

- (void) addSubrow:(WWCardEditorRow *)row{
	[self insertSubrow:row atIndex:[_subrows count]];
}


- (void) insertSubrow:(WWCardEditorRow *)row atIndex:(NSUInteger)newRowIndex{
	[self willChangeValueForKey:@"subrowsByName"];
	[self willChangeValueForKey:@"subrows"];
	
	[_subrows insertObject:row atIndex:newRowIndex];
	if([row name]) [_subrowsByName setObject:row forKey:[row name]];
	
	row.parentEditor = parentEditor;
	row.parentRow = self;
	
	[self addSubview:row];
	
	[self didChangeValueForKey:@"subrowsByName"];
	[self didChangeValueForKey:@"subrows"];
	
	_needsLayout = YES;
}


- (void) removeSubrowAtIndex:(NSUInteger)removeRowIndex{
	[self willChangeValueForKey:@"subrowsByName"];
	[self willChangeValueForKey:@"subrows"];
	
	WWCardEditorRow *subrow = [_subrows objectAtIndex:removeRowIndex];
	if ([subrow name]) [_subrowsByName removeObjectForKey:[subrow name]];
	
	[subrow removeFromSuperview];
	
	subrow.parentRow = nil;
	subrow.parentEditor = nil;
	
	[self didChangeValueForKey:@"subrowsByName"];
	[self didChangeValueForKey:@"subrows"];
	
	_needsLayout = YES;
}

- (BOOL)collapsed {
    return collapsed;
}

- (void)setCollapsed:(BOOL)flag {
	if(collapsed != flag){
		_needsLayout = YES;
	}
	
	[_disclosureTriangle setState:!collapsed];
	
    collapsed = flag;
}


#pragma mark -
#pragma mark Drawing & Layout

- (void) _disclosureChanged{
	collapsed = ![_disclosureTriangle state];
	_needsLayout = YES;
	[self _layoutIfNeeded];
}

- (void) _layoutIfNeeded{
	if(_needsLayout){
		CGFloat yCursor = [label sizeWithAttributes:[self _labelAttributes]].height + WWSectionRow_InitialTopPadding;
		
		if(collapsed){
			for(WWCardEditorRow *subrow in _subrows){

				[subrow setHidden:YES];
				[subrow setFrame:NSZeroRect];
			}
		}else{
			for(WWCardEditorRow *subrow in _subrows){
				[subrow setHidden:NO];
				[subrow setFrame:NSMakeRect(0, yCursor, [self frame].size.width, [subrow neededHeight])];
				yCursor += [subrow neededHeight] + [parentEditor rowSpacing];
			}
		}
		
		[_disclosureTriangle setFrame:NSMakeRect(0, 0, 15, 15)];
		
		parentEditor.needsLayout = YES;
		
		_needsLayout = NO;
	}
}


- (void)drawRect:(NSRect)rect {
	[self _layoutIfNeeded];
	
	NSSize labelSize = [label sizeWithAttributes:[self _labelAttributes]];
	CGFloat left = [_disclosureTriangle frame].size.width + 2;
	[label drawInRect:NSMakeRect(left, 0, labelSize.width, labelSize.height) withAttributes:[self _labelAttributes]];
	
	[[NSColor lightGrayColor] set];
	CGFloat lineLeft = left + labelSize.width + 5;
	NSRectFill(NSMakeRect(lineLeft, labelSize.height/2, [self frame].size.width - lineLeft, 1));
	
	[super drawRect:rect];
}

#pragma mark -
#pragma mark Overrides

- (CGFloat) neededHeight{
	CGFloat soFar = [label sizeWithAttributes:[self _labelAttributes]].height + WWSectionRow_InitialTopPadding;
	
	if(!collapsed){
		for(WWCardEditorRow *subrow in _subrows){
			soFar += [subrow neededHeight] + [parentEditor rowSpacing];
		}
	}
	
	return soFar;
}

// focus rects

// principal responders

- (CGFloat) availableWidth{
	return [self frame].size.width;
}

- (void)setParentEditor:(WWCardEditor *)aParentEditor{
	for(WWCardEditorRow *subrow in _subrows){
		[subrow setParentEditor:aParentEditor];
	}
	
	[super setParentEditor:aParentEditor];
}

- (void)setEditMode:(BOOL)flag {
	for(WWCardEditorRow *subrow in _subrows){
		[subrow setEditMode:flag];
	}
	
	[super setEditMode:flag];
}

- (NSArray *) principalResponders{
	NSMutableArray *responders = [NSMutableArray array];
	
	for(WWCardEditorRow *subrow in _subrows){
		[responders addObjectsFromArray:[subrow principalResponders]];
	}
	
	return responders;
}

@end
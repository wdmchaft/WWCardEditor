//
//  NSColor+Extras.m
//  WWCardEditor
//
//  Created by Dan Grover on 6/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NSColor+Extras.h"


@implementation NSColor (Extras)


- (CGColorRef) asCGColor{
	NSColor *deviceColor = [self colorUsingColorSpaceName: NSDeviceRGBColorSpace];
	float components[4];
	[deviceColor getRed: &components[0] green: &components[1] blue: &components[2] alpha: &components[3]];
	return CGColorCreate(CGColorSpaceCreateDeviceRGB(), components);
}

@end
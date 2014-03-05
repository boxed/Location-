//
//  UIColor_L3Extensions.h
//  Weekend Picks
//
//  Created by Justin Miller on 6/18/12.
//  Copyright (c) 2012 MapBox / Development Seed. All rights reserved.
//

// Largely based on Erica Sadun's uicolor-utilities
// https://github.com/erica/uicolor-utilities

#import <UIKit/UIKit.h>

@interface UIColor (L3Extensions)

+ (UIColor *)colorWithHexString:(NSString *)hexString;
- (NSString *)hexStringFromColor;

@end
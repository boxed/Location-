//
//  RIButtonItem.m
//  Shibui
//
//  Created by Jiva DeVoe on 1/12/11.
//  Copyright 2011 Random Ideas, LLC. All rights reserved.
//

#import "RIButtonItem.h"

@implementation RIButtonItem
@synthesize label;
@synthesize action;

+(id)item
{
    return [self new];
}

+(id)itemWithLabel:(NSString *)inLabel
{
    RIButtonItem * newItem = [RIButtonItem item];
    newItem.label = inLabel;
    return newItem;
}

+(id)itemWithLabel:(NSString *)inLabel andAction:(void (^)())action
{
    RIButtonItem * newItem = [RIButtonItem item];
    newItem.label = inLabel;
    newItem.action = action;
    return newItem;
}

@end


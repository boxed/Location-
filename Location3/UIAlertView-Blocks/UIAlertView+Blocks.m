//
//  UIAlertView+Blocks.m
//  Shibui
//
//  Created by Jiva DeVoe on 12/28/10.
//  Copyright 2010 Random Ideas, LLC. All rights reserved.
//

#import "UIAlertView+Blocks.h"
#import <objc/runtime.h>

static NSString *RI_BUTTON_ASS_KEY = @"com.random-ideas.BUTTONS";

@implementation UIAlertView (UIAlertView_Blocks)


+(id)showAlertWithTitle:(NSString *)title
                 message:(NSString *)message
       cancelButtonTitle:(NSString*)cancelButtonLabel
      cancelButtonAction:(void (^)())cancelAction
        otherButtonArray:(NSArray *)otherButtonArray
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title message:message cancelButtonTitle:cancelButtonLabel cancelButtonAction:cancelAction otherButtonArray:otherButtonArray];
    [alert show];
    return alert;
}


+(id)showAlertWithTitle:(NSString *)title
                message:(NSString *)message
      cancelButtonTitle:(NSString*)cancelButtonLabel
     cancelButtonAction:(void (^)())cancelAction
          okButtonTitle:(NSString*)okButtonLabel
         okButtonAction:(void (^)())okAction
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title message:message cancelButtonTitle:cancelButtonLabel cancelButtonAction:cancelAction];
    if ([okButtonLabel length] > 0)
        [alert addButtonWithLabel:okButtonLabel andAction:okAction];
    [alert show];
    return alert;
}


-(id)initWithTitle:(NSString *)inTitle message:(NSString *)inMessage cancelButtonItem:(RIButtonItem *)inCancelButtonItem otherButtonItems:(RIButtonItem *)inOtherButtonItems, ...
{
    NSMutableArray *buttonsArray = [NSMutableArray array];
    
    RIButtonItem *eachItem;
    va_list argumentList;
    if (inOtherButtonItems)
    {
        [buttonsArray addObject: inOtherButtonItems];
        va_start(argumentList, inOtherButtonItems);
        while((eachItem = va_arg(argumentList, RIButtonItem *)))
        {
            [buttonsArray addObject: eachItem];
        }
        va_end(argumentList);
    }

    return [self initWithTitle:inTitle message:inMessage cancelButtonItem:inCancelButtonItem otherButtonArray:buttonsArray];
}

-(id)initWithTitle:(NSString *)inTitle message:(NSString *)inMessage cancelButtonItem:(RIButtonItem *)inCancelButtonItem otherButtonArray:(NSArray *)inOtherButtonArray
{
    if((self = [self initWithTitle:inTitle message:inMessage delegate:self cancelButtonTitle:inCancelButtonItem.label otherButtonTitles:nil]))
    {
        NSMutableArray *buttonsArray;
        if (inOtherButtonArray == nil)
            buttonsArray = [NSMutableArray arrayWithCapacity:2];
        else
            buttonsArray = [inOtherButtonArray mutableCopy];
        
        for(RIButtonItem *item in buttonsArray)
        {
            [self addButtonWithTitle:item.label];
        }
        
        if(inCancelButtonItem)
            [buttonsArray insertObject:inCancelButtonItem atIndex:0];
        
        objc_setAssociatedObject(self, (__bridge const void *)RI_BUTTON_ASS_KEY, buttonsArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [self setDelegate:self];
    }
    return self;
    
}

-(id)initWithTitle:(NSString *)inTitle message:(NSString *)inMessage cancelButtonTitle:(NSString*)inCancelButtonLabel cancelButtonAction:(void (^)())inCancelAction otherButtonArray:(NSArray *)inOtherButtonArray
{
    return [self initWithTitle:inTitle
                       message:inMessage
              cancelButtonItem:[RIButtonItem itemWithLabel:inCancelButtonLabel andAction:inCancelAction]
              otherButtonArray:inOtherButtonArray];
}

-(id)initWithTitle:(NSString *)inTitle message:(NSString *)inMessage cancelButtonTitle:(NSString*)inCancelButtonLabel cancelButtonAction:(void (^)())inCancelAction
{
    return [self initWithTitle:inTitle
                       message:inMessage
              cancelButtonItem:[RIButtonItem itemWithLabel:inCancelButtonLabel andAction:inCancelAction]
              otherButtonArray:nil];
}

- (NSInteger)addButtonItem:(RIButtonItem *)item
{	
    NSMutableArray *buttonsArray = objc_getAssociatedObject(self, (__bridge const void *)RI_BUTTON_ASS_KEY);	
	
	NSInteger buttonIndex = [self addButtonWithTitle:item.label];
	[buttonsArray addObject:item];
	
	return buttonIndex;
}

- (NSInteger)addButtonWithLabel:(NSString *)inLabel andAction:(void (^)())inAction
{
    return [self addButtonItem:[RIButtonItem itemWithLabel:inLabel andAction:inAction]];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // If the button index is -1 it means we were dismissed with no selection
    if (buttonIndex >= 0)
    {
        NSArray *buttonsArray = objc_getAssociatedObject(self, (__bridge const void *)RI_BUTTON_ASS_KEY);
        RIButtonItem *item = buttonsArray[buttonIndex];
        if(item.action)
            item.action();
    }
    
    objc_setAssociatedObject(self, (__bridge const void *)RI_BUTTON_ASS_KEY, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

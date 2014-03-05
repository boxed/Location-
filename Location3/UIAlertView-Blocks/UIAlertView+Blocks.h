//
//  UIAlertView+Blocks.h
//  Shibui
//
//  Created by Jiva DeVoe on 12/28/10.
//  Copyright 2010 Random Ideas, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIButtonItem.h"

@interface UIAlertView (UIAlertView_Blocks)

-(id)initWithTitle:(NSString *)inTitle message:(NSString *)inMessage cancelButtonItem:(RIButtonItem *)inCancelButtonItem otherButtonItems:(RIButtonItem *)inOtherButtonItems, ... NS_REQUIRES_NIL_TERMINATION;
-(id)initWithTitle:(NSString *)inTitle message:(NSString *)inMessage cancelButtonItem:(RIButtonItem *)inCancelButtonItem otherButtonArray:(NSArray *)inOtherButtonArray;
-(id)initWithTitle:(NSString *)inTitle message:(NSString *)inMessage cancelButtonTitle:(NSString*)inCancelButtonLabel cancelButtonAction:(void (^)())inCancelAction otherButtonArray:(NSArray *)inOtherButtonArray;
-(id)initWithTitle:(NSString *)inTitle message:(NSString *)inMessage cancelButtonTitle:(NSString*)inCancelButtonLabel cancelButtonAction:(void (^)())inCancelAction;


+(id)showAlertWithTitle:(NSString *)title
                message:(NSString *)message
      cancelButtonTitle:(NSString*)cancelButtonLabel
     cancelButtonAction:(void (^)())cancelAction
       otherButtonArray:(NSArray *)otherButtonArray;


+(id)showAlertWithTitle:(NSString *)title
                message:(NSString *)message
      cancelButtonTitle:(NSString*)cancelButtonLabel
     cancelButtonAction:(void (^)())cancelAction
      okButtonTitle:(NSString*)okButtonLabel
         okButtonAction:(void (^)())okAction;


- (NSInteger)addButtonItem:(RIButtonItem *)item;
- (NSInteger)addButtonWithLabel:(NSString *)inLabel andAction:(void (^)())inAction;

@end

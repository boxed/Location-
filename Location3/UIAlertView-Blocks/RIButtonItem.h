//
//  RIButtonItem.h
//  Shibui
//
//  Created by Jiva DeVoe on 1/12/11.
//  Copyright 2011 Random Ideas, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIButtonItem : NSObject
{
    NSString *label;
    void (^action)();
}
@property (strong, nonatomic) NSString *label;
@property (strong, nonatomic) void (^action)();

+(id)item;
+(id)itemWithLabel:(NSString *)inLabel;
+(id)itemWithLabel:(NSString *)inLabel andAction:(void (^)())action;

@end

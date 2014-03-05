#import <UIKit/UIKit.h>
#import "L3GeneralDelegate.h"

@class L3SearchViewController;

#pragma mark -

@interface L3SearchViewController : UITableViewController <UITextFieldDelegate> {
    UITextField* txtField;
}

@property (weak) id <L3GeneralDelegate>delegate;

@end
#import <UIKit/UIKit.h>
#import "L3GeneralDelegate.h"

@interface L3BookmarksViewController : UITableViewController {
    NSMutableArray* items;
    UIAlertView* alertView;
}

@property (weak) id <L3GeneralDelegate>delegate;
@property (strong) NSString* path;

@end

#import <UIKit/UIKit.h>
#import "L3GeneralDelegate.h"

@class L3SearchChooserViewController;

@protocol L3SearchChooserDelegate <NSObject>

- (void)searchChooserChoiceMade:(NSDictionary*)choice;
@property (atomic) NSString* customSearch;
@property (strong, nonatomic) NSArray* filterTypes;

@end

#pragma mark -

@interface L3SearchChooserViewController : UITableViewController {
}

+ (L3SearchChooserViewController*)searchChooserViewControllerWithArray:(NSArray*)array;

@property (weak) id <L3GeneralDelegate>delegate;
@property (retain) NSArray* array;

@end
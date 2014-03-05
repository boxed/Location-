#import <UIKit/UIKit.h>
#import "L3GeneralDelegate.h"

@interface L3AnnotationDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextView *moreInfo;
@property (weak, nonatomic) IBOutlet UITableView *folders;
@property (weak) id <L3GeneralDelegate>delegate;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@end

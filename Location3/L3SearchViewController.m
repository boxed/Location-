#import "L3SearchViewController.h"
#import "UIColor+L3Extensions.h"
#import "Misc.h"
#import "L3BookmarksViewController.h"

#define ROW_OFFSET 2 // 1 for the search text field, 1 for the bookmarks entry

@implementation L3SearchViewController

@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStyleBordered target:self action:@selector(apply:)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithHexString:kDarkerTintColorHex];
    
    txtField = [[UITextField alloc] initWithFrame: CGRectMake(10, 10, 310, 29)];
    txtField.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    txtField.autoresizesSubviews = YES;
    [txtField setBorderStyle:UITextBorderStyleNone];
    [txtField setPlaceholder:@"Search"];
    txtField.text = gGlobalState.customSearch;
    txtField.delegate = self;
    txtField.returnKeyType = UIReturnKeySearch;
    txtField.font = [txtField.font fontWithSize:20];
    txtField.clearButtonMode = UITextFieldViewModeAlways;
}

- (IBAction)apply:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];

    gGlobalState.customSearch = txtField.text;
    
    if (txtField.text.length != 0) {
        for (NSMutableDictionary* filterType in gGlobalState.filterTypes) {
            filterType[@"selected"] = [NSNumber numberWithBool:FALSE];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(refreshAndSave:)])
        [self.delegate refreshAndSave:self];
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return gGlobalState.filterTypes.count+ROW_OFFSET; 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SearchCellIdentifier = @"SearchCell";
    static NSString *BookmarksCellIdentifier = @"BookmarksCell";
    static NSString *CellIdentifier = @"FilterTypeCell";
    
    NSString* cellId;
    if (indexPath.row == 0) {
        cellId = CellIdentifier;
    }
    else if (indexPath.row == 1) {
        cellId = BookmarksCellIdentifier;
    }
    else {
        cellId = SearchCellIdentifier;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (indexPath.row == 0) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [cell addSubview:txtField];
        cell.textLabel.text = @"";
        return cell;
    }
    else if (indexPath.row == 1) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"Bookmarks";
        return cell;
    }
    
    cell.textLabel.text  = [[[gGlobalState.filterTypes objectAtIndex:indexPath.row - ROW_OFFSET] objectForKey:@"title"] stringByReplacingOccurrencesOfString:@"-" withString:@" "];
    
    // draw slightly-cropped pin image for cell
    //
    UIImage *pinImage = [[gGlobalState.filterTypes objectAtIndex:indexPath.row - ROW_OFFSET] objectForKey:@"image"];
    
    float dimension = pinImage.size.height * 2/3;
    
    UIGraphicsBeginImageContext(CGSizeMake(dimension, dimension));
    
    [pinImage drawInRect:CGRectMake((dimension - pinImage.size.width) / 2, 0, pinImage.size.width, pinImage.size.height)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();

    cell.imageView.image = image;
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    cell.selectedBackgroundView.backgroundColor = self.navigationController.navigationBar.tintColor;

    cell.accessoryType = ([[[gGlobalState.filterTypes objectAtIndex:indexPath.row - ROW_OFFSET] objectForKey:@"selected"] boolValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
    
    return cell;
}

#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        // don't allow selection of search text row
    }
    else if (indexPath.row == 1) {
        // drill down
        L3BookmarksViewController* viewController = [[L3BookmarksViewController alloc] initWithNibName:nil bundle:nil];
        viewController.delegate = self.delegate;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        BOOL newState = ![gGlobalState.filterTypes[indexPath.row - ROW_OFFSET][@"selected"] boolValue];
        gGlobalState.filterTypes[indexPath.row - ROW_OFFSET][@"selected"] = [NSNumber numberWithBool:newState];
        
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = (newState ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
    }
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self apply:textField];
    
    return YES;
}

@end
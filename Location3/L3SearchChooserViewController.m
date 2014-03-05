#import "L3SearchChooserViewController.h"

@implementation L3SearchChooserViewController

@synthesize delegate;

+ (L3SearchChooserViewController*)searchChooserViewControllerWithArray:(NSArray*)array
{
    L3SearchChooserViewController* s = [[L3SearchChooserViewController alloc] initWithNibName:nil bundle:nil];
    s.array = array;
    return s;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(close:)];
}

- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary* item = _array[indexPath.row];
    NSArray* s = [item[@"display_name"] componentsSeparatedByString:@", "];
    
    NSString* title = [s objectAtIndex:0];
    NSString* description = @"";
    if (s.count > 1) {
        description = [s objectAtIndex:1];
        if (s.count > 2) {
            description = [[description stringByAppendingString:@" "] stringByAppendingString:[s objectAtIndex:2]];
        }
    }

    cell.textLabel.text = title;
    cell.detailTextLabel.text = description;
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    cell.selectedBackgroundView.backgroundColor = self.navigationController.navigationBar.tintColor;

    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(searchChooserChoiceMade:)])
        [self.delegate searchChooserChoiceMade:_array[indexPath.row]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
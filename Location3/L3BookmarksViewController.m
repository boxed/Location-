#import "L3BookmarksViewController.h"
#import "L3GeneralDelegate.h"
#import "Misc.h"
#import "UIColor+L3Extensions.h"
#import "UIAlertView-Blocks/UIAlertView+Blocks.h"
#import "RMMapView.h"

@interface L3BookmarksViewController ()

@end

@implementation L3BookmarksViewController

@synthesize path;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (path == nil) {
        path = @"Bookmarks";
    }
    
    self.navigationController.topViewController.title = path;
    
    items = @[].mutableCopy;
    
    if ([path isEqualToString:@"Bookmarks"]) {
        for (NSString* bookmarkFolder in gGlobalState.bookmarkFolders) {
            if ([bookmarkFolder isEqualToString:@"Bookmarks"]) {
                continue;
            }
            [items addObject:@{@"type": @"folder", @"title": bookmarkFolder}];
        }
    }
    
    for (NSDictionary* bookmark in gGlobalState.bookmarks) {
        if ([path isEqualToString:bookmark[@"bookmarkFolder"]]) {
            [items addObject:@{@"type": @"bookmark", @"title": bookmark[@"title"], @"data":bookmark}];
        }
    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStyleBordered target:self action:@selector(apply:)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithHexString:kDarkerTintColorHex];
}

- (void)apply:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];

    if ([self.delegate respondsToSelector:@selector(refreshAndSave:)])
        [self.delegate refreshAndSave:self];
}

#pragma mark - Table view data source

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)table commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([items[indexPath.row][@"type"] isEqualToString:@"folder"]) {
            NSString* folderName = items[indexPath.row][@"title"];
            alertView = [UIAlertView showAlertWithTitle:@"Confirm delete"
                                                message:[NSString stringWithFormat:@"Do you really want to delete the folder %@ and everything in it?", folderName]
                                      cancelButtonTitle:@"Cancel"
                                     cancelButtonAction:^(void){}
                                          okButtonTitle:@"Delete"
                                         okButtonAction:^(void){
                                             for (NSMutableDictionary* item in gGlobalState.bookmarks) {
                                                 if ([item[@"bookmarkFolder"] isEqualToString:folderName]) {
                                                     [gGlobalState.bookmarks removeObject:item];
                                                     [self.delegate.mapView removeAnnotation:item[@"annotation"]];
                                                 }
                                             }
                                             [gGlobalState.bookmarkFolders removeObject:folderName];
                                             self.delegate.currentAnnotation = nil;
                                             [self apply:self];
                                         }];
        }
        else {
            NSString* bookmarkName = items[indexPath.row][@"title"];
            alertView = [UIAlertView showAlertWithTitle:@"Confirm delete"
                                                message:[NSString stringWithFormat:@"Do you really want to delete the bookmark %@ and everything in it?", bookmarkName]
                                      cancelButtonTitle:@"Cancel"
                                     cancelButtonAction:^(void){}
                                          okButtonTitle:@"Delete"
                                         okButtonAction:^(void){
                                             [gGlobalState.bookmarks removeObject:items[indexPath.row][@"data"]];
                                             [self.delegate.mapView removeAnnotation:self.delegate.currentAnnotation];
                                             self.delegate.currentAnnotation = nil;
                                             [self apply:self];
                                         }];            
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = items[indexPath.row][@"title"];
    if ([items[indexPath.row][@"type"] isEqualToString:@"folder"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        if ([items[indexPath.row][@"data"][@"selected"] boolValue]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([items[indexPath.row][@"type"] isEqualToString:@"folder"]) {
        L3BookmarksViewController *detailViewController = [[L3BookmarksViewController alloc] initWithNibName:nil bundle:nil];
        detailViewController.path = items[indexPath.row][@"title"];
        detailViewController.delegate = self.delegate;
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

        BOOL newState = ![items[indexPath.row][@"data"][@"selected"] boolValue];
        items[indexPath.row][@"data"][@"selected"] = [NSNumber numberWithBool:newState];
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = (newState ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
    }
}

@end

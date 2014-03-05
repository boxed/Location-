#import "L3AnnotationDetailViewController.h"
#import "Misc.h"
#import "UIColor+L3Extensions.h"
#import "L3GeneralDelegate.h"
#import "RMMapView.h"
#import "RMUserLocation.h"

#define DELETE_ALERT_VIEW_TAG 1
#define NAME_ALERT_VIEW_TAG 2

@interface L3AnnotationDetailViewController ()

@end

@implementation L3AnnotationDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString* rightBarButtonTitle;

    NSString* tag = self.delegate.currentAnnotation.userInfo[@"tag"];
    if ([tag isEqualToString:kDroppedPinTag]) {
        rightBarButtonTitle = @"Bookmark";
        self.leftButton.titleLabel.text = @"Remove";
    }
    else if ([tag isEqualToString:kBookmarkTag]) {
        rightBarButtonTitle = @"Save";
        self.leftButton.titleLabel.text = @"Delete";
        self.name.text = self.delegate.currentAnnotation.userInfo[@"title"];
    }
    else {
        // search results, both custom and selected category
        rightBarButtonTitle = @"Bookmark";
        self.leftButton.hidden = YES;
        self.name.text = self.delegate.currentAnnotation.userInfo[@"title"];
    }
    
    self.moreInfo.text = self.delegate.currentAnnotation.userInfo[@"description"];
    self.moreInfo.editable = NO;

    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:rightBarButtonTitle style:UIBarButtonItemStyleBordered target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithHexString:kDarkerTintColorHex];
    
    self.navigationController.topViewController.title = self.delegate.currentAnnotation.userInfo[@"title"];
    
    self.folders.dataSource = self;
    self.folders.delegate = self;
    
    [self.folders setEditing:NO];
    
    int selectedBookmarkIndex = 0;
    for (int i = 0; i != gGlobalState.bookmarkFolders.count; i++) {
        if ([gGlobalState.bookmarkFolders[i] isEqualToString:self.delegate.currentAnnotation.userInfo[@"bookmarkFolder"]]) {
            selectedBookmarkIndex = i;
            break;
        }
    }
    NSIndexPath* pos = [NSIndexPath indexPathForRow:selectedBookmarkIndex inSection:0];
    [self.folders selectRowAtIndexPath:pos animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self.folders scrollToRowAtIndexPath:pos atScrollPosition:UITableViewScrollPositionNone animated:YES];
    

    [self updateControls:self];
}

- (IBAction)cancel:(id)sender
{
    [self.delegate closeDetailView:self];
}

- (IBAction)save:(id)sender
{
    [self.delegate closeDetailView:self];
    
    NSString* selectedFolderName = gGlobalState.bookmarkFolders[[self.folders indexPathForSelectedRow].row];
    assert(![selectedFolderName isEqualToString:@"New folder..."]);
    self.delegate.currentAnnotation.userInfo[@"bookmarkFolder"] = selectedFolderName;
    
    NSString* tag = self.delegate.currentAnnotation.userInfo[@"tag"];
    NSMutableDictionary* userInfo = self.delegate.currentAnnotation.userInfo;
    userInfo[@"marker-color"] = @"#0000FF";
    userInfo[@"tag"] = kBookmarkTag;
    userInfo[@"selected"] = [NSNumber numberWithBool:YES];
    userInfo[@"title"] = self.name.text;
    userInfo[@"q"] = @"bookmark";
    if ([tag isEqualToString:kDroppedPinTag]) {
        // Create new bookmark item
        [gGlobalState.bookmarks addObject:userInfo];
        // Remove item from dropped pin list
        [gGlobalState.droppedPins removeObject:userInfo];
        // Make sure the annotation is redrawn
        [self.delegate.mapView removeAnnotation:self.delegate.currentAnnotation];
        [self.delegate.mapView addAnnotation:self.delegate.currentAnnotation];
    }
    else if ([tag isEqualToString:kBookmarkTag]) {
        // Save changes to existing bookmark
    }
    else {
        // Search results, both custom and selected category
        // create new bookmark item
        [gGlobalState.bookmarks addObject:userInfo];
        // Make sure the annotation is redrawn
        [self.delegate.mapView removeAnnotation:self.delegate.currentAnnotation];
        [self.delegate.mapView addAnnotation:self.delegate.currentAnnotation];
    }
    
    [self.delegate refreshAndSave:self];
}

- (IBAction)updateControls:(id)sender
{
    self.navigationItem.rightBarButtonItem.enabled = self.name.text.length != 0;
}

- (IBAction)remove:(id)sender
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Confirm deletion" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    alertView.tag = DELETE_ALERT_VIEW_TAG;
    [alertView show];
}

- (IBAction)route:(id)sender
{
    self.delegate.routeTarget = self.delegate.currentAnnotation;
    [self.delegate routeFrom:self.delegate.mapView.userLocation.location.coordinate to:coordinateFromUserInfo(self.delegate.currentAnnotation.userInfo)];
    [self cancel:sender];
}

- (IBAction)shareLocation:(id)sender
{
    // TODO: implement share location
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return gGlobalState.bookmarkFolders.count+1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == gGlobalState.bookmarkFolders.count)
        return NO;
    if (indexPath.row == 0)
        return NO;
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row == gGlobalState.bookmarkFolders.count) {
        cell.textLabel.text = @"New folder...";
        cell.textLabel.textColor = [UIColor grayColor];
        cell.showsReorderControl = NO;
    }
    else {
        cell.showsReorderControl = YES;
        cell.textLabel.text = gGlobalState.bookmarkFolders[indexPath.row];
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithHexString:kTintColorHex];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (indexPath.row != 0) {
        cell.indentationLevel = 2;
    }
    else {
        cell.indentationLevel = 0;
    }
    
    return cell;
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == gGlobalState.bookmarkFolders.count) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"New bookmark folder" message:@"Folder name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = NAME_ALERT_VIEW_TAG;
        [alert show];
//        OCPromptView* prompt = [[OCPromptView alloc] initWithPrompt:@"Folder name" delegate:self cancelButtonTitle:@"Cancel" acceptButtonTitle:@"Create"];
//        prompt.tag = NAME_ALERT_VIEW_TAG;
//        [prompt show];
        return nil;
    }
    return indexPath;
}

/*
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    int row = proposedDestinationIndexPath.row;
    if (row == 0) {
        row++;
    }
    if (row == gGlobalState.bookmarkFolders.count) {
        row--;
    }
    return [NSIndexPath indexPathForItem:row inSection:0];
}
*/

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == NAME_ALERT_VIEW_TAG) {
        if (buttonIndex != [alertView cancelButtonIndex]) {
            [gGlobalState.bookmarkFolders addObject:[[alertView textFieldAtIndex:0] text]];
            [self.folders reloadData];
            NSIndexPath* pos = [NSIndexPath indexPathForRow:gGlobalState.bookmarkFolders.count-1 inSection:0];
            [self.folders selectRowAtIndexPath:pos animated:NO scrollPosition:UITableViewScrollPositionNone];
            [self.folders scrollToRowAtIndexPath:pos atScrollPosition:UITableViewScrollPositionNone animated:YES];
        }
    }
    else if (alertView.tag == DELETE_ALERT_VIEW_TAG) {
        if (buttonIndex != [alertView cancelButtonIndex]) {
            [self.delegate closeDetailView:self];
            
            [self.delegate.mapView removeAnnotation:self.delegate.currentAnnotation];
            [gGlobalState.droppedPins removeObject:self.delegate.currentAnnotation.userInfo];
            [gGlobalState.bookmarks removeObject:self.delegate.currentAnnotation.userInfo];
            self.delegate.currentAnnotation = nil;
            [self.delegate refreshAndSave:self];
        }
    }
}

@end

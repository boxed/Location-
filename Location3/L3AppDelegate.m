#import "L3AppDelegate.h"
#import "Misc.h"
#import "UIColor+L3Extensions.h"
#import "KMLParser.h"
#import "L3GeneralDelegate.h"


@implementation L3AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (gGlobalState == nil) {
        gGlobalState = [[L3GlobalState alloc] init];
    }
    
    NSURL *url = (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
    NSLog(@"URL: %@", url);
    if ([url isFileURL])
    {
        // Handle file being passed in
    }
    else
    {
        // Handle custom URL scheme
    }
    [self emptyInbox];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    KMLParser* parser = [[KMLParser alloc] initWithURL:url];
    [parser parseKML];
    NSString* bookmarkFolderName = [url.lastPathComponent componentsSeparatedByString:@"."][0];
    BOOL createFolder = YES;
    for (NSString* b in gGlobalState.bookmarkFolders) {
        if ([bookmarkFolderName isEqualToString:b]) {
            // TODO: ask whether to delete existing items, create with a new name or cancel
            createFolder = NO;
        }
    }
    if (createFolder) {
        [gGlobalState.bookmarkFolders addObject:bookmarkFolderName];
    }
    for (MKPointAnnotation* p in parser.points) {
        CLLocationCoordinate2D pos = p.coordinate;
        NSMutableDictionary* userInfo = @{
                                          @"marker-color": @"#0000FF",
                                          @"marker-size": @"large",
                                          @"marker-symbol": @"circle",
                                          @"tag": kBookmarkTag,
                                          @"selected": [NSNumber numberWithBool:YES],
                                          @"title": p.title,
                                          @"description": @"",
                                          @"q": @"bookmark",
                                          @"latitude": [NSNumber numberWithFloat:pos.latitude],
                                          @"longitude": [NSNumber numberWithFloat:pos.longitude],
                                          @"bookmarkFolder": bookmarkFolderName
                                          }.mutableCopy;
        [gGlobalState.bookmarks addObject:userInfo];
        // TODO: implement
//        [self.mapView addAnnotationForUserInfo:userInfo];
        
//        [self.mapView refreshAndSave:self];
    }
    [self emptyInbox];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // TODO: implement
//    [self.mapView saveState];
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    [coder encodeObject:nil forKey:@"globalState"]; // backwards compatability
    // TODO: implement
//    [self.mapView saveState];
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    L3GlobalState* state = [coder decodeObjectForKey:@"globalState"]; // backwards compatability
    if (state) {
        gGlobalState = state;
    }
    else {
        // TODO: implement
//        [self.mapView restoreState];
    }
    if (gGlobalState == nil) {
        gGlobalState = [[L3GlobalState alloc] init];
    }
    return YES;
}

- (void)emptyInbox
{
    NSFileManager* sharedFM = [NSFileManager defaultManager];
    NSString* inbox = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Inbox"];
    NSArray* contents = [sharedFM contentsOfDirectoryAtPath:inbox error:nil];
    for (NSString* file in contents) {
        [sharedFM removeItemAtPath:[inbox stringByAppendingPathComponent:file] error:nil];
    }
}

@end

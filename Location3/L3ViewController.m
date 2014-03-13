//
//  L3ViewController.m
//  Location3
//
//  Created by Anders Hovmöller on 2013-10-26.
//  Copyright (c) 2013 Anders Hovmöller. All rights reserved.
//

#import "L3ViewController.h"
#import "L3SearchViewController.h"
#import "Misc.h"
#import "UIColor+L3Extensions.h"
#import "L3AnnotationDetailViewController.h"
#import "L3SearchChooserViewController.h"
#import "RouteInstruction.h"


#define kNormalMapID  @"boxed.map-feoeptvi"
#define kRetinaMapID  @"boxed.map-ujmerxab"
#define WEEK_IN_SECONDS 604800

@interface L3ViewController ()

@end

@implementation L3ViewController

@synthesize currentAnnotation;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    requestedRefresh = [NSDate date];
    
    annotationProcessQueue = [[NSOperationQueue alloc] init];

    RMMapboxSource *onlineSource = [[RMMapboxSource alloc] initWithMapID:(([[UIScreen mainScreen] scale] > 1.0) ? kRetinaMapID : kNormalMapID)];
    
    RMMapView *mapView = [[RMMapView alloc] initWithFrame:self.view.bounds andTilesource:onlineSource];
    
    mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    mapView.tileCache = [[RMTileCache alloc] initWithExpiryPeriod:WEEK_IN_SECONDS*4]; // a week cache
    
    mapView.showsUserLocation = YES;
    mapView.hideAttribution = YES;
    mapView.showLogoBug = NO;
    mapView.userTrackingMode = RMUserTrackingModeFollow;
    mapView.delegate = self;
    
    if (gGlobalState == nil) {
        gGlobalState = [[L3GlobalState alloc] init];
    }

    [self.view addSubview:mapView];
    
    self.mapView = mapView;
    
    // Set up location button
    UIButton* toggleLocationButton = [[UIButton alloc] initWithFrame:CGRectMake(5, self.view.bounds.size.height-25, 20, 20)];
    [toggleLocationButton addTarget:self action:@selector(goToUserLocation:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:toggleLocationButton];
    self.toggleLocationButton = toggleLocationButton;
    [self updateTrackingIcon];
    
    // Set up search button
    UIButton* searchButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-40, 20, 40, 40)];
    [searchButton setImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(presentSearch:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:searchButton];
    
    // Misc
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(saveState) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkForRefresh) userInfo:nil repeats:YES];
    
    [self restoreState];
    
    [self checkForRefresh];

    self.mapView.showsUserLocation = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)updateTrackingIcon {
    switch (self.mapView.userTrackingMode) {
        case RMUserTrackingModeNone:
            [self.toggleLocationButton setImage:[UIImage imageNamed:@"TrackingLocationDark.png"] forState:UIControlStateNormal];
            break;
        case RMUserTrackingModeFollow:
            [self.toggleLocationButton setImage:[UIImage imageNamed:@"TrackingLocationOn.png"] forState:UIControlStateNormal];
            break;
        case RMUserTrackingModeFollowWithHeading:
            [self.toggleLocationButton setImage:[UIImage imageNamed:@"TrackingHeadingDark.png"] forState:UIControlStateNormal];
            break;
    }
}

- (IBAction)goToUserLocation:(id)sender {
    switch (self.mapView.userTrackingMode) {
        case RMUserTrackingModeNone:
            self.mapView.userTrackingMode = RMUserTrackingModeFollow;
            [self.toggleLocationButton setImage:[UIImage imageNamed:@"TrackingLocationDark.png"] forState:UIControlStateNormal];
            break;
        case RMUserTrackingModeFollow:
            self.mapView.userTrackingMode = RMUserTrackingModeFollowWithHeading;
            [self.toggleLocationButton setImage:[UIImage imageNamed:@"TrackingHeadingDark.png"] forState:UIControlStateNormal];
            break;
        case RMUserTrackingModeFollowWithHeading:
            [self.toggleLocationButton setImage:[UIImage imageNamed:@"TrackingLocation.png"] forState:UIControlStateNormal];
            self.mapView.userTrackingMode = RMUserTrackingModeNone;
            break;
    }
    [self updateTrackingIcon];
}

- (IBAction)presentSearch:(id)sender
{
    L3SearchViewController *searchController = [[L3SearchViewController alloc] initWithNibName:nil bundle:nil];
    searchController.delegate = self;
    
    UINavigationController *wrapper = [[UINavigationController alloc] initWithRootViewController:searchController];
    wrapper.topViewController.title = @"Search";
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [self presentViewController:wrapper animated:YES completion:nil];
    }
    else {
        CGRect rect = [sender frame];
        self->popover = [[UIPopoverController alloc] initWithContentViewController:wrapper];
        [self->popover presentPopoverFromRect:rect inView:self.mapView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

#pragma mark -

- (BOOL)mapView:(RMMapView *)mapView shouldDragAnnotation:(RMAnnotation *)annotation
{
    return YES;
}

- (void)mapView:(RMMapView *)mapView didDragAnnotation:(RMAnnotation *)annotation withDelta:(CGPoint)delta
{
    annotation.position = CGPointMake(annotation.position.x - delta.x, annotation.position.y - delta.y);
    CLLocationCoordinate2D pos = [self.mapView pixelToCoordinate:annotation.position];
    annotation.userInfo[@"latitude"] = [NSNumber numberWithFloat:pos.latitude];
    annotation.userInfo[@"longitude"] = [NSNumber numberWithFloat:pos.longitude];
    annotation.coordinate = pos;
}

- (void)mapView:(RMMapView *)mapView didEndDragAnnotation:(RMAnnotation *)annotation
{
    if (annotation == self.routeTarget) {
        [self routeFrom:self.mapView.userLocation.location.coordinate to:annotation.coordinate];
    }
}


- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    if ([annotation.userInfo[@"tag"] isEqualToString:kRouteTag]) {
        RMShape* route = [[RMShape alloc] initWithView:self.mapView];
        route.lineWidth = 5;
        route.lineColor = [UIColor colorWithHexString:kRouteColorHex];
        route.lineCap = kCALineCapRound;
        int i = 0;
        
        for (CLLocation *location in [annotation.userInfo objectForKey:@"points"]) {
            if (i > 0){
                [route addLineToCoordinate:location.coordinate];
            }
            else {
                [route moveToCoordinate:location.coordinate];
            }
            i++;
        }
        
        route.zPosition = 0;
        
        return route;
    }
    else if ([annotation isKindOfClass:RMUserLocation.class]) {
        RMMarker* marker = [[RMMarker alloc] initWithUIImage:[RMMapView resourceImageNamed:@"TrackingDot.png"]];
        return marker;
    }
    else {
        RMMarker *marker = [[RMMarker alloc] initWithMapboxMarkerImage:annotation.userInfo[@"marker-symbol"]
                                                          tintColorHex:annotation.userInfo[@"marker-color"]
                                                            sizeString:annotation.userInfo[@"marker-size"]];
        if ([annotation.userInfo[@"tag"] isEqualToString:kDroppedPinTag]) {
//            marker->draggingEnabled = YES;
            // TODO: enable dragging. The API has changed since Mapbox 1.0.3
        }
        marker.zPosition = 10;
        assert(marker);
        marker.canShowCallout = YES;
        //        calloutView.title = annotation.userInfo[@"title"];
        //        calloutView.subtitle = annotation.userInfo[@"description"];
        UIButton* button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [button addTarget:self action:@selector(tapAnnotationDetailButton:) forControlEvents:UIControlEventTouchDown];
        marker.rightCalloutAccessoryView = button;
        
        return marker;
    }
}

- (void)tapOnAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map
{
    if (!annotation.isUserLocationAnnotation) {
        self.currentAnnotation = annotation;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        }
        else {
            L3AnnotationDetailViewController *viewController = [[L3AnnotationDetailViewController alloc] initWithNibName:nil bundle:nil];
            viewController.delegate = self;
            UINavigationController *wrapper = [[UINavigationController alloc] initWithRootViewController:viewController];
            wrapper.preferredContentSize = CGSizeMake(320, 480);
            self->popover = [[UIPopoverController alloc] initWithContentViewController:wrapper];
            self->popover.popoverContentSize = CGSizeMake(320, 480);
            CGPoint pt = [_mapView coordinateToPixel:self.currentAnnotation.coordinate];
            CGRect rect = CGRectMake(pt.x-ANNOTATION_SIZE/2, pt.y-ANNOTATION_SIZE, ANNOTATION_SIZE, ANNOTATION_SIZE);
            [self->popover presentPopoverFromRect:rect inView:self.mapView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
}

- (void)tapAnnotationDetailButton:(id)sender
{
    // iPhone only
    L3AnnotationDetailViewController *viewController = [[L3AnnotationDetailViewController alloc] initWithNibName:nil bundle:nil];
    viewController.delegate = self;
    
    UINavigationController *wrapper = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:wrapper animated:YES completion:nil];
}

- (void)singleTapOnMap:(RMMapView *)map at:(CGPoint)point {
    self.currentAnnotation = nil;
}

- (void)removeAnnotationsForTag:(NSString*)tag
{
    for (RMAnnotation* item in _mapView.annotations) {
        if ([item.userInfo[@"tag"] isEqualToString:tag] && item != self.currentAnnotation) {
            [_mapView removeAnnotation:item];
        }
    }
}

- (RMAnnotation*)addAnnotationForItem:(NSDictionary*)item markerSymbol:(NSString*)markerSymbol q:(NSString*)q tag:(NSString*)tag
{
    NSArray* s = [[item objectForKey:@"display_name"] componentsSeparatedByString:@", "];
    
    NSString* title = [s objectAtIndex:0];
    NSString* description = @"";
    if (s.count > 1) {
        description = [s objectAtIndex:1];
        if (s.count > 2) {
            description = [[description stringByAppendingString:@" "] stringByAppendingString:[s objectAtIndex:2]];
        }
    }
    // TODO: ID of item is item[@"osm_id"], which is an integer/long, could be used to avoid replacing existing markers
    NSMutableDictionary* userInfo = @{
                                      @"marker-symbol": markerSymbol,
                                      @"title": title,
                                      @"description": description,
                                      @"marker-color": @"#FF0000",
                                      @"marker-size": @"large",
                                      @"q": q,
                                      @"tag": tag,
                                      @"latitude": [item objectForKey:@"lat"],
                                      @"longitude": [item objectForKey:@"lon"]}.mutableCopy;
    
    return [self addAnnotationForUserInfo:userInfo];
}

- (RMAnnotation*)addAnnotationForUserInfo:(NSMutableDictionary*)userInfo
{
    CLLocationCoordinate2D pos = coordinateFromUserInfo(userInfo);
    RMAnnotation* annotation = [RMAnnotation annotationWithMapView:_mapView coordinate:pos andTitle:userInfo[@"title"]];
    userInfo[@"annotation"] = annotation;
    annotation.userInfo = userInfo;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
        [_mapView addAnnotation:annotation];
    }];
    return annotation;
}

- (void)addAnnotationsForQuery:(NSString*)q markerSymbol:(NSString*)markerSymbol tag:(NSString*)tag service:(NSString*)service localSearch:(BOOL)isLocalSearch
{
    NSString* viewBox = @"";
    NSString* limit = @"20";
    if (isLocalSearch) {
        viewBox = [NSString stringWithFormat:@"&bounded=1&viewbox=%f,%f,%f,%f", _mapView.latitudeLongitudeBoundingBox.northEast.longitude, _mapView.latitudeLongitudeBoundingBox.northEast.latitude, _mapView.latitudeLongitudeBoundingBox.southWest.longitude, _mapView.latitudeLongitudeBoundingBox.southWest.latitude];
    }
    else {
        limit = @"5";
    }
    NSString* url = [NSString stringWithFormat:@"%@/search.php?q=%@&format=json&limit=%@%@", service, [q urlencode], limit, viewBox];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [urlRequest addValue:@"LocationLocationLocation; iOS App; boxed@killingar.net" forHTTPHeaderField:@"User-Agent"];
    NSLog(@"Searching: %@", url);
    
    if ([tag isEqualToString:kCustomSearchTag]){
        self.animatedProgressView.hidden = NO;
    }
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:annotationProcessQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (data) {
            NSLog(@"Search done: %@", url);
            NSArray* items = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if (items.count == 0 && requestedRefreshUserInitiated && isLocalSearch && [tag isEqualToString:kCustomSearchTag]) {
                [self addAnnotationsForQuery:q markerSymbol:markerSymbol tag:tag service:service localSearch:NO];
                return;
            }
            
            if ((!isLocalSearch && items.count) ||
                (items.count == 1 && requestedRefreshUserInitiated && [tag isEqualToString:kCustomSearchTag])
                ) {
                CLLocationCoordinate2D coordinate;
                coordinate.latitude = [items[0][@"lat"] floatValue];
                coordinate.longitude = [items[0][@"lon"] floatValue];
                RMSphericalTrapezium bounds = self.mapView.latitudeLongitudeBoundingBox;
                
                BOOL isInside = coordinate.longitude > bounds.southWest.longitude && coordinate.longitude < bounds.northEast.longitude && coordinate.latitude > bounds.southWest.latitude && coordinate.latitude < bounds.northEast.latitude;
                if (!isInside) {
                    // This case is for countries. Searching for eg "Australia" always gives me the country even though I have bounded the search.
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showChooser:items];
                    });
                    return;
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self removeAnnotationsForTag:tag];
                for (NSDictionary* item in items) {
                    [self addAnnotationForItem:item markerSymbol:markerSymbol q:q tag:tag];
                }
            });
        }
        else {
            assert(error);
            NSLog(@"Search error: %@, %@ %ld, %@, %@", url, error.domain, (long)error.code, error.description, error.localizedDescription);
            // TODO: add error handling
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.animatedProgressView.hidden = YES;
        });
    }];
}

- (void)addAnnotationsForFilterType:(NSDictionary*)filterType
{
    [self addAnnotationsForQuery:filterType[@"q"] markerSymbol:filterType[@"marker-symbol"] tag:filterType[@"tag"] service:filterType[@"service"] localSearch:YES];
}

- (void)refreshMarkersUserInitiated:(BOOL)isUserInitiated
{
    requestedRefresh = [NSDate date];
    requestedRefreshUserInitiated = isUserInitiated;
    
    if (isUserInitiated) {
        [self showHideBookmarks];
    }
}

- (void)showHideBookmarks
{
    for (NSMutableDictionary* bookmark in gGlobalState.bookmarks) {
        if ([bookmark[@"selected"] boolValue]) {
            if (!bookmark[@"annotation"]) {
                [self addAnnotationForUserInfo:bookmark];
            }
        }
        else {
            if (bookmark[@"annotation"]) {
                [self.mapView removeAnnotation:bookmark[@"annotation"]];
                [bookmark removeObjectForKey:@"annotation"];
            }
        }
    }
}

- (void)checkForRefresh
{
    if ([requestedRefresh timeIntervalSinceNow] <= -1.0) {
        requestedRefresh = nil;
        for (NSDictionary* filterType in gGlobalState.filterTypes) {
            if ([filterType[@"selected"] boolValue]) {
                [self addAnnotationsForFilterType:filterType];
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self removeAnnotationsForTag:filterType[@"tag"]];
                });
            }
        }
        
        if (gGlobalState.customSearch && ![gGlobalState.customSearch isEqualToString:@""]) {
            [self addAnnotationsForQuery:gGlobalState.customSearch markerSymbol:kCustomMarkerSymbol tag:kCustomSearchTag service:kNominatimService localSearch:YES];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self removeAnnotationsForTag:kCustomSearchTag];
            });
        }
    }
}

#pragma mark AlertTableView delegate

- (NSString*)descriptionForItem:(id)inItem
{
    NSDictionary* item = inItem;
    return item[@"title"];
}

- (void)didSelectRowAtIndex:(NSInteger)row withContext:(id)inContext
{
    NSDictionary* context = inContext;
    NSArray* items = context[@"items"];
    NSDictionary* item = items[row];
    [self addAnnotationForItem:item markerSymbol:kCustomMarkerSymbol q:context[@"q"] tag:context[@"tag"]];
}

#pragma mark map view delegate

- (void)afterMapMove:(RMMapView *)map byUser:(BOOL)wasUserAction
{
    if (wasUserAction) {
        [self refreshMarkersUserInitiated:NO];
        if (wasUserAction) {
            _mapView.userTrackingMode = RMUserTrackingModeNone;
            [self updateTrackingIcon];
        }
    }
}

- (void)afterMapZoom:(RMMapView *)map byUser:(BOOL)wasUserAction
{
    if (wasUserAction) {
        [self refreshMarkersUserInitiated:NO];
        if (wasUserAction) {
           _mapView.userTrackingMode = RMUserTrackingModeNone;
            [self updateTrackingIcon];
        }
    }
}


#pragma mark annotation callout delegate

- (void)closeDetailView:(id)sender
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [sender dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self->popover dismissPopoverAnimated:YES];
    }
}

#pragma mark -

- (void)refreshAndSave:(id)sender
{
    [self refreshMarkersUserInitiated:YES];
    [self saveState];
}

- (void)showChooser:(NSArray*)items
{
    L3SearchChooserViewController *searchChooserController = [L3SearchChooserViewController searchChooserViewControllerWithArray:items];
    searchChooserController.delegate = self;
    
    UINavigationController *wrapper = [[UINavigationController alloc] initWithRootViewController:searchChooserController];
    wrapper.topViewController.title = @"Found places";
    
    [self presentViewController:wrapper animated:YES completion:nil];
    self.animatedProgressView.hidden = YES;
}

- (void)searchChooserChoiceMade:(NSDictionary*)choice
{
    RMAnnotation* annotation = [self addAnnotationForItem:choice markerSymbol:kCustomMarkerSymbol q:gGlobalState.customSearch tag:kCustomSearchTag];
    CLLocationCoordinate2D pos = coordinateFromUserInfo(annotation.userInfo);
    [_mapView setCenterCoordinate:pos animated:YES];
    
//    NSArray* boundingbox = choice[@"boundingbox"];
//    if (boundingbox) {
//        CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake([boundingbox[0] floatValue], [boundingbox[2] floatValue]);
//        CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake([boundingbox[1] floatValue], [boundingbox[3] floatValue]);
//        
//        // TODO: Set the correct zoom level. Note that zoomWithLatitudeLongitudeBoundsSouthWest:northEast ends up in weird places
//    }
    
    _mapView.userTrackingMode = RMUserTrackingModeNone;
    [self updateTrackingIcon];
    gGlobalState.customSearch = @"";
}

- (void)viewDidUnload {
    [self setToggleLocationButton:nil];
    [super viewDidUnload];
}

#pragma mark State store/load


- (NSString*)savePath
{
    NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                           inDomains:NSUserDomainMask];
    NSURL* url = urls[0];
    return [url.path stringByAppendingPathComponent:@"gGlobalState"];
}

- (void)saveState
{
    // Add tileSource.tileCount to the stored tile count and reset it
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    //    [defaults setInteger:mapView.tileSource.tileCount+[defaults integerForKey:@"tileCount"] forKey:@"tileCount"];
    //    mapView.tileSource.tileCount = 0;
    CLLocationCoordinate2D centerCoordinate = _mapView.centerCoordinate;
    [defaults setFloat:centerCoordinate.latitude forKey:@"latitude"];
    [defaults setFloat:centerCoordinate.longitude forKey:@"longitude"];
    [defaults setFloat:_mapView.zoom forKey:@"zoom"];
    for (NSMutableDictionary* filterType in gGlobalState.filterTypes) {
        [defaults setBool:[filterType[@"selected"] boolValue] forKey:filterType[@"tag"]];
    }
    
    [defaults synchronize];
    
    assert([NSKeyedArchiver archiveRootObject:gGlobalState toFile:[self savePath]]);
}

- (void)restoreState
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:@"latitude"] == nil) {
        // Initial startup
        _mapView.userTrackingMode = RMUserTrackingModeFollow;
    }
    else {
        CLLocationCoordinate2D centerCoordinate;
        centerCoordinate.latitude = [defaults floatForKey:@"latitude"];
        centerCoordinate.longitude = [defaults floatForKey:@"longitude"];
        if (!isnan(centerCoordinate.latitude) && !isnan(centerCoordinate.longitude)) {
            _mapView.centerCoordinate = centerCoordinate;
            _mapView.zoom = [defaults floatForKey:@"zoom"];
        }
        for (NSMutableDictionary* filterType in gGlobalState.filterTypes) {
            filterType[@"selected"] = [NSNumber numberWithBool:[defaults boolForKey:filterType[@"tag"]]];
        }
    }
    gGlobalState = [NSKeyedUnarchiver unarchiveObjectWithFile:[self savePath]];
    
    if (gGlobalState == nil) {
        gGlobalState = [[L3GlobalState alloc] init];
    }
    
    for (NSMutableDictionary* item in gGlobalState.droppedPins) {
        [self addAnnotationForUserInfo:item];
    }
    for (NSMutableDictionary* item in gGlobalState.bookmarks) {
        if (item[@"selected"]) {
            [self addAnnotationForUserInfo:item];
        }
    }
}

#pragma mark routing
-(NSMutableArray*)decodePolyLine:(NSString*)encodedStr {
    NSMutableString *encoded = [[NSMutableString alloc] initWithCapacity:[encodedStr length]];
    [encoded appendString:encodedStr];
    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
                                options:NSLiteralSearch
                                  range:NSMakeRange(0, [encoded length])];
    NSInteger len = [encoded length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len) {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:location];
    }
    
    return array;
}

- (void)routeFrom:(CLLocationCoordinate2D)start to:(CLLocationCoordinate2D)end
{
    NSString* routingService = @"http://router.project-osrm.org/viaroute";
    NSString* url = [NSString stringWithFormat:@"%@?loc=%f,%f&loc=%f,%f", routingService, start.latitude, start.longitude, end.latitude, end.longitude];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [urlRequest addValue:@"LocationLocationLocation; iOS App; boxed@killingar.net" forHTTPHeaderField:@"User-Agent"];
    NSLog(@"Searching: %@", url);
    
    self.animatedProgressView.hidden = NO;
    
    // TODO: first find nearest points on a road for start and stop positions? or just when we hit an error?
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:annotationProcessQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (data) {
            NSLog(@"Search done: %@", url);
            NSDictionary* items = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSMutableArray* points = [self decodePolyLine:items[@"route_geometry"]];
            NSMutableArray* routeInstructions = [NSMutableArray arrayWithCapacity:[items[@"route_instructions"] count]];
            for (NSArray* instruction in items[@"route_instructions"]) {
                [routeInstructions addObject:[RouteInstruction routeInstructionWithArray:instruction]] ;
            }
            if (points.count == 0) {
                NSLog(@"Route error: got 0 points!");
            }
            else {
                NSMutableDictionary* userInfo = @{
                                                  @"tag": kRouteTag,
                                                  @"route_instructions": routeInstructions,
                                                  @"latitude": [NSString stringWithFormat:@"%f", [points[0] coordinate].latitude],
                                                  @"longitude": [NSString stringWithFormat:@"%f", [points[0] coordinate].longitude],
                                                  @"points": points
                                                  }.mutableCopy;
                
                [self removeAnnotationsForTag:@"route"];
                [self addAnnotationForUserInfo:userInfo];
                [userInfo[@"annotation"] setBoundingBoxFromLocations:points];
            }
        }
        else {
            assert(error);
            NSLog(@"Route error: %@, %@ %ld, %@, %@", url, error.domain, (long)error.code, error.description, error.localizedDescription);
        }
        self.animatedProgressView.hidden = YES;
        [self refreshAndSave:self];
    }];
}



@end

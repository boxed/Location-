//
//  L3ViewController.h
//  Location3
//
//  Created by Anders Hovmöller on 2013-10-26.
//  Copyright (c) 2013 Anders Hovmöller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapBox/MapBox.h>
#import "L3GeneralDelegate.h"

@interface L3ViewController : UIViewController <RMMapViewDelegate, L3GeneralDelegate> {
    UIPopoverController* detailPopup;
    NSOperationQueue* annotationProcessQueue;
    NSDate* requestedRefresh;
    BOOL requestedRefreshUserInitiated;
    UIPopoverController* popover;

}

@property (weak, nonatomic) IBOutlet RMMapView* mapView;
@property (weak, nonatomic) IBOutlet UIButton *toggleLocationButton;
@property (weak, nonatomic) IBOutlet UIView *animatedProgressView;

@end

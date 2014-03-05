#import <Foundation/Foundation.h>
#import <MapBox/MapBox.h>

@interface L3GlobalState : NSObject

@property (atomic) NSMutableArray* bookmarkFolders;
@property (atomic) NSMutableArray* bookmarks;
@property (atomic) NSMutableArray* droppedPins;
@property (atomic) NSString* customSearch;
@property (strong, nonatomic) NSMutableArray *filterTypes;

@end

extern L3GlobalState* gGlobalState;

@protocol L3GeneralDelegate <NSObject>

- (void)refreshAndSave:(id)sender;
- (void)searchChooserChoiceMade:(NSDictionary*)choice;
- (void)closeDetailView:(id)sender;
- (void)routeFrom:(CLLocationCoordinate2D)start to:(CLLocationCoordinate2D)end;
- (RMAnnotation*)addAnnotationForUserInfo:(NSMutableDictionary*)userInfo;

@property (strong, nonatomic) RMAnnotation* currentAnnotation;
@property (weak, nonatomic) RMMapView* mapView;
@property (weak) RMAnnotation* routeTarget;

@end

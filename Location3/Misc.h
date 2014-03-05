#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#define kTintColorHex      @"#2a949e"
#define kDarkerTintColorHex      @"#167f88"
#define kRouteColorHex @"#9b00cb"
#define ANNOTATION_SIZE 40
#define kCustomMarkerSymbol @"circle"
#define kMapQuestService @"http://open.mapquestapi.com/nominatim/v1"
#define kNominatimService @"http://nominatim.openstreetmap.org"

#define WEEK_IN_SECONDS 604800

#define kNormalMapID  @"boxed.map-feoeptvi"
#define kRetinaMapID  @"boxed.map-ujmerxab"

#define kCustomSearchTag @"custom search"
#define kDroppedPinTag @"dropped pin"
#define kBookmarkTag @"bookmark"
#define kRouteTag @"route"

NSMutableDictionary* createFilterTypeWithService(id tag, id markerSymbol, id title, id q, id service);
NSMutableDictionary* createFilterType(id tag, id markerSymbol, id title, id q);
CLLocationCoordinate2D coordinateFromUserInfo(NSDictionary* userInfo);

@interface NSDictionary(subscripts)
- (id)objectAtIndexedSubscript:(NSUInteger)idx;
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;
- (id)objectForKeyedSubscript:(id)key;
@end

@interface NSString (NSString_Extended)
- (NSString *)urlencode;
@end
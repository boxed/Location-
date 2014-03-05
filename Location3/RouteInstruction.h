#import <Foundation/Foundation.h>

@interface RouteInstruction : NSObject

@property int drivingDirection;
@property NSString* wayName;
@property int meters;
@property int positionAsRouteGeometryIndex;
@property int segmentSecons;
@property NSString* lengthWithUnit;
@property NSString* direction;
@property float azimuthDegrees;

+ (id)routeInstructionWithArray:(NSArray*)array;

@end

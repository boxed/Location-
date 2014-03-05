#import "RouteInstruction.h"

@implementation RouteInstruction

+ (id)routeInstructionWithArray:(NSArray*)array
{
    RouteInstruction* obj = [[RouteInstruction alloc] init];
    assert(array.count == 8);
    obj.drivingDirection = [array[0] intValue];
    obj.wayName = array[1];
    obj.meters = [array[2] intValue];
    obj.positionAsRouteGeometryIndex = [array[3] intValue];
    obj.segmentSecons = [array[4] intValue];
    obj.lengthWithUnit = array[5];
    obj.direction = array[6];
    obj.azimuthDegrees = [array[7] floatValue];
    return obj;
}

@end

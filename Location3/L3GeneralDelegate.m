#import "L3GeneralDelegate.h"
#import "Misc.h"

L3GlobalState* gGlobalState = nil;

@implementation L3GlobalState

@synthesize bookmarkFolders;
@synthesize bookmarks;
@synthesize customSearch;
@synthesize filterTypes;

- (id)init {
    self = [super init];
    self.bookmarkFolders = @[@"Bookmarks"].mutableCopy;
    self.bookmarks = @[].mutableCopy;
    self.droppedPins = @[].mutableCopy;

    // Set up filter types
    NSMutableArray* f = [NSMutableArray array];
    [f addObject:createFilterType(@"restaurant",  @"restaurant",  @"Restaurants",   @"[restaurant]")];
    [f addObject:createFilterType(@"fast-food",   @"fast-food",   @"Fast Food",     @"[fast food]")];
    [f addObject:createFilterType(@"bus_stop",    @"bus",         @"Bus Stops",     @"bus stop")];
    [f addObject:createFilterType(@"fuel",        @"fuel",        @"Gas Stations",  @"[fuel]")];
    [f addObject:createFilterType(@"parking",     @"parking",     @"Parking",       @"[parking]")];
    [f addObject:createFilterType(@"bank",        @"bank",        @"ATMs",          @"[atm]")];
    [f addObject:createFilterType(@"cafe",        @"cafe",        @"Cafés",         @"[cafe]")];
    [f addObject:createFilterType(@"grocery",     @"grocery",     @"Supermarkets",  @"[supermarket]")];
    [f addObject:createFilterType(@"pharmacy",    @"pharmacy",    @"Pharmacies",    @"[pharmacy]")];
    [f addObject:createFilterType(@"hospital",    @"hospital",    @"Hospitals",     @"[hospital]")];
    self.filterTypes = f;
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        int version = [coder decodeIntForKey:@"version"];
        if (version == 1) {
            self.bookmarkFolders = [coder decodeObjectForKey:@"bookmarkFolders"];
            self.bookmarks = [coder decodeObjectForKey:@"bookmarks"];
            self.droppedPins = [coder decodeObjectForKey:@"droppedPins"];
            self.customSearch = [coder decodeObjectForKey:@"customSearch"];
            self.filterTypes = [coder decodeObjectForKey:@"filterTypes"];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInt:1 forKey:@"version"];
    [coder encodeObject:self.bookmarkFolders forKey:@"bookmarkFolders"];
    [coder encodeObject:self.bookmarks forKey:@"bookmarks"];
    [coder encodeObject:self.droppedPins forKey:@"droppedPins"];
    [coder encodeObject:self.customSearch forKey:@"customSearch"];
    [coder encodeObject:self.filterTypes forKey:@"filterTypes"];
}

@end

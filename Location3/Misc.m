#import "Misc.h"
#import "RMAnnotation.h"

NSMutableDictionary* createFilterTypeWithService(id tag, id markerSymbol, id title, id q, id service) {
    return @{@"tag": tag, @"marker-symbol": markerSymbol, @"title": title, @"q": q, @"selected": [NSNumber numberWithBool:NO], @"service": service}.mutableCopy;
}

NSMutableDictionary* createFilterType(id tag, id markerSymbol, id title, id q) {
    return createFilterTypeWithService(tag, markerSymbol, title, q, kNominatimService);
}

CLLocationCoordinate2D coordinateFromUserInfo(NSDictionary* userInfo) {
    if ([userInfo valueForKey:@"latitude"]) {
        return CLLocationCoordinate2DMake([userInfo[@"latitude"] floatValue], [userInfo[@"longitude"] floatValue]);
    }
    else {
        return CLLocationCoordinate2DMake([userInfo[@"lat"] floatValue], [userInfo[@"lon"] floatValue]);
    }
}

@implementation NSString (NSString_Extended)
- (NSString *)urlencode {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    unsigned long sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}
@end

@implementation RMAnnotation (RMAnnotation_Extended)
- (id)initWithCoder:(NSCoder*)coder {
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
    
}

@end
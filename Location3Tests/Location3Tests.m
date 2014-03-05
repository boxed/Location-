//
//  Location3Tests.m
//  Location3Tests
//
//  Created by Anders Hovmöller on 2013-10-26.
//  Copyright (c) 2013 Anders Hovmöller. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>

int weekday_from_date(NSDate* date) {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int weekday = [[calendar components:NSWeekdayCalendarUnit fromDate:date] weekday]-2; // -2 because cocoa APIs are stupid and counts sunday as 1, while monday as 0 is the only thing that makes sense
    if (weekday == -1) {
        weekday = 6;
    }
    return weekday;
}

NSArray* monthcalendar(int year, int month) {
    NSDateComponents* comps = [[NSDateComponents alloc] init];
    [comps setDay:1];
    [comps setMonth:month];
    [comps setYear:year];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate* monthDate = [calendar dateFromComponents:comps];

    NSRange r = [calendar rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:monthDate];
    r = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:monthDate];
    int number_of_days_in_month = r.length;
    int weekday = weekday_from_date(monthDate);
    NSMutableArray* result = [@[] mutableCopy];
    NSMutableArray* row = nil;
    for (int day = 1; day != number_of_days_in_month+1; day++) {
        if (row == nil) {
            row = [@[] mutableCopy];
        }
        if (day == 1) {
            // Pad 0s from last month
            for (int x = 0; x != weekday; x++) {
                [row addObject:[NSNumber numberWithInt:0]];
            }
        }
        
        [comps setDay:day];
        NSDate* today = [calendar dateFromComponents:comps];
        [row addObject:[NSNumber numberWithInt:day]];
        if (weekday_from_date(today) == 6) {
            [result addObject:row];
            row = nil;
        }
    }
    
    return result;
}

@interface Location3Tests : XCTestCase

@end

@implementation Location3Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    NSArray* expected = @[@[ @0,  @0,  @0,  @0,  @1,  @2,  @3],
                          @[ @4,  @5,  @6,  @7,  @8,  @9, @10],
                          @[@11, @12, @13, @14, @15, @16, @17],
                          @[@18, @19, @20, @21, @22, @23, @24],
                          @[@25, @26, @27, @28, @29, @30, @31]];

    XCTAssertEqualObjects([monthcalendar(2013, 3) description], [expected description]);
}

@end

//
//  OBAStopAccessEventV2_Tests.m
//  org.onebusaway.iphone
//
//  Created by Aaron Brethorst on 3/25/16.
//  Copyright © 2016 OneBusAway. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBATestHelpers.h"

#import <OBAKit/OBAModelFactory.h>
#import <OBAKit/OBAReferencesV2.h>
#import <OBAKit/OBAStopAccessEventV2.h>

/**
 TODO: WRITE TESTS
 */

@interface OBAStopAccessEventV2_Tests : XCTestCase
@property(nonatomic,strong) OBAModelFactory *modelFactory;
@end

@implementation OBAStopAccessEventV2_Tests

- (void)setUp {
    [super setUp];

    OBAReferencesV2 *references = [[OBAReferencesV2 alloc] init];
    self.modelFactory = [[OBAModelFactory alloc] initWithReferences:references];
}

- (void)testVerifyLoadingOldObjectFromCoding {
    OBAStopAccessEventV2 *archivedObject = [OBATestHelpers unarchiveBundledTestFile:@"RecentStopWithStopIDs.plist"];
    XCTAssertEqualObjects(archivedObject.title, @"I am a title");
    XCTAssertEqualObjects(archivedObject.subtitle, @"I am a subtitle");
    XCTAssertEqualObjects(archivedObject.stopID, @"12345");
}

- (void)testVerifyRoundtrippingOldObjectFromCoding {
    OBAStopAccessEventV2 *archivedObject = [OBATestHelpers unarchiveBundledTestFile:@"RecentStopWithStopIDs.plist"];
    OBAStopAccessEventV2 *archivedObject2 = [OBATestHelpers roundtripObjectThroughNSCoding:archivedObject];

    XCTAssertEqualObjects(archivedObject2.title, @"I am a title");
    XCTAssertEqualObjects(archivedObject2.subtitle, @"I am a subtitle");
    XCTAssertEqualObjects(archivedObject2.stopID, @"12345");
}

- (void)testVerifyLoadingNewObjectFromCoding {
    OBAStopAccessEventV2 *archivedObject = [OBATestHelpers unarchiveBundledTestFile:@"RecentStopWithStopID.plist"];

    XCTAssertEqualObjects(archivedObject.title, @"I am a title");
    XCTAssertEqualObjects(archivedObject.subtitle, @"I am a subtitle");
    XCTAssertEqualObjects(archivedObject.stopID, @"98765");
}

@end

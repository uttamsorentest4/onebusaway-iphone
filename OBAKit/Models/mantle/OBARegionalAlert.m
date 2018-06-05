//
//  OBARegionalAlert.m
//  OBAKit
//
//  Created by Aaron Brethorst on 3/16/17.
//  Copyright © 2017 OneBusAway. All rights reserved.
//

#import <OBAKit/OBARegionalAlert.h>
#import <OBAKit/OBAMacros.h>

@implementation OBARegionalAlert

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];

    if (self) {
        // Mark any alerts older than 24 hours as 'read'.
        _unread = ABS(self.publishedAt.timeIntervalSinceNow) < 86400;
    }

    return self;
}

#pragma mark - MTLJSONSerializing

- (void)setNilValueForKey:(NSString *)key {
    /*
        `unread` isn't actually part of the JSON bolus that gets sent from the
        server. And so originally I wasn't including it in +JSONKeyPathsByPropertyKey.
        Because of that, it wasn't being persisted out when I wrote models out in the
        manager. Now that I've added it, i've also created setNilValueForKey so as
        to override the nil -> falsy conversion that would happen with it.
    */
    if ([key isEqual:@"unread"]) {
        self.unread = YES;
    }
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"unread": @"unread",
             @"identifier": @"id",
             @"title": @"title",
             @"feedName": @"alert_feed_name",
             @"priority": @"priority",
             @"summary": @"summary",
             @"URL": @"url",
             @"alertFeedID": @"alert_feed_id",
             @"publishedAt": @"published_at",
             @"externalID": @"external_id"
             };
}

#pragma mark - Transformers

+ (NSValueTransformer *)publishedAtJSONTransformer {

    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    });

    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError *__autoreleasing *error) {
        return [dateFormatter dateFromString:dateString];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
        return [dateFormatter stringFromDate:date];
    }];
}

#pragma mark - IGListDiffable

- (nonnull id<NSObject>)diffIdentifier {
    return [NSString stringWithFormat:@"%@", @(self.identifier)];
}

- (BOOL)isEqualToDiffableObject:(nullable OBARegionalAlert<IGListDiffable>*)object {
    OBAGuard([object isKindOfClass:OBARegionalAlert.class]) else {
        return NO;
    }

    if (self.unread != object.unread) {
        return NO;
    }

    if (self.identifier != object.identifier) {
        return NO;
    }

    if (![self.title isEqual:object.title]) {
        return NO;
    }

    if (![self.feedName isEqual:object.feedName]) {
        return NO;
    }

    if (self.priority != object.priority) {
        return NO;
    }

    if (![self.summary isEqual:object.summary]) {
        return NO;
    }

    if (![self.URL isEqual:object.URL]) {
        return NO;
    }

    if (self.alertFeedID != object.alertFeedID) {
        return NO;
    }

    if (![self.publishedAt isEqual:object.publishedAt]) {
        return NO;
    }

    if (![self.externalID isEqual:object.externalID]) {
        return NO;
    }

    return YES;
}

@end

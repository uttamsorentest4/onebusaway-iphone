/**
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *         http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "OBAAnalytics.h"
#import <FirebaseAnalytics/FirebaseAnalytics.h>

NSString * const OBAAnalyticsCategoryAppSettings = @"app_settings";
NSString * const OBAAnalyticsCategoryUIAction = @"ui_action";
NSString * const OBAAnalyticsCategoryAccessibility = @"accessibility";
NSString * const OBAAnalyticsCategorySubmit = @"submit";

NSInteger const OBAAnalyticsDimensionVoiceOver = 4;

@interface OBAAnalytics ()
@property(nonatomic,strong) OBAApplication *application;
@end

@implementation OBAAnalytics

- (instancetype)initWithApplication:(OBAApplication*)application {
    self = [super init];

    if (self) {
        _application = application;
        [GAI sharedInstance].logger.logLevel = kGAILogLevelWarning;

        // the default tracker is set to be the first tracker created.
        [GAI.sharedInstance trackerWithTrackingId:_application.googleAnalyticsID];

        [self refreshTrackingStatus];
        [self refreshUserProperties];
    }
    return self;
}

- (void)refreshTrackingStatus {
    [GAI sharedInstance].optOut = !self.OKToTrack;
    [[FIRAnalyticsConfiguration sharedInstance] setAnalyticsCollectionEnabled:self.OKToTrack];
}

- (BOOL)OKToTrack {
    return [self.application.userDefaults boolForKey:OBAOptInToTrackingDefaultsKey];
}

- (void)refreshUserProperties {
    [[GAI sharedInstance].defaultTracker set:[GAIFields customDimensionForIndex:1] value:self.application.modelDao.currentRegion.regionName];

    [FIRAnalytics setUserPropertyString:OBAStringFromBool(UIAccessibilityIsVoiceOverRunning()) forName:@"UsesVoiceOver"];
    [FIRAnalytics setUserPropertyString:OBAStringFromBool([OBATheme useHighContrastUI]) forName:@"UsesHighContrastUI"];

    [[GAI sharedInstance].defaultTracker set:[GAIFields customDimensionForIndex:OBAAnalyticsDimensionVoiceOver] value:(UIAccessibilityIsVoiceOverRunning() ? @"ON" : @"OFF")];
}

+ (void)reportEventWithCategory:(NSString *)category action:(NSString*)action label:(NSString*)label value:(id)value {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (label && value) {
        params[label] = value;
    }
    [FIRAnalytics logEventWithName:[NSString stringWithFormat:@"%@_%@", category, action] parameters:params];

    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createEventWithCategory:category action:action label:label value:value] build]];
}

+ (void)reportViewController:(UIViewController*)viewController {
    // FIRAnalytics automatically tracks this.
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

@end

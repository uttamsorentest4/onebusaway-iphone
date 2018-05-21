//
//  OBAWeatherForecast.h
//  OBAKit
//
//  Created by Aaron Brethorst on 5/20/18.
//  Copyright © 2018 OneBusAway. All rights reserved.
//

@import UIKit;
@import Mantle;

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(WeatherForecast)
@interface OBAWeatherForecast : MTLModel<MTLJSONSerializing>
@property(nonatomic,assign,readonly) CGFloat latitude;
@property(nonatomic,assign,readonly) CGFloat longitude;
@property(nonatomic,assign,readonly) NSUInteger regionIdentifier;
@property(nonatomic,copy,readonly) NSString* regionName;
@property(nonatomic,copy,readonly) NSDate *forecastRetrievedAt;

@property(nonatomic,copy,readonly) NSString *currentSummary;
@property(nonatomic,copy,readonly) NSString *currentSummaryIconName;
@property(nonatomic,assign,readonly) CGFloat currentPrecipProbability;
@property(nonatomic,assign,readonly) CGFloat currentTemperature;
@end

NS_ASSUME_NONNULL_END

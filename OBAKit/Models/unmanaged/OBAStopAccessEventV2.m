/**
 * Copyright (C) 2009-2016 bdferris <bdferris@onebusaway.org>, University of Washington
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <OBAKit/OBAStopAccessEventV2.h>
#import <OBAKit/NSCoder+OBAAdditions.h>

@implementation OBAStopAccessEventV2

#pragma mark - NSCoder Methods

- (id)initWithCoder:(NSCoder*)coder {
    self = [super init];
    if (self) {
        _title = [coder oba_decodeObject:@selector(title)];
        _subtitle = [coder oba_decodeObject:@selector(subtitle)];

        //
        // TODO: eliminate this compatibility code in, say, 2020.
        //
        // Up until 18.2.0, it was possible to encode multiple stop IDs
        // within a single stop access event object. However, this functionality
        // was limited to a single stop ID. As a result, we need to account
        // for this for the foreseeable future.
        NSArray *stopIds = [coder decodeObjectForKey:@"stopIds"];
        if (stopIds.count > 0) {
            _stopID = [stopIds firstObject];
        }
        else {
            _stopID = [coder oba_decodeObject:@selector(stopID)];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
    [coder oba_encodePropertyOnObject:self withSelector:@selector(title)];
    [coder oba_encodePropertyOnObject:self withSelector:@selector(subtitle)];
    [coder oba_encodePropertyOnObject:self withSelector:@selector(stopID)];
}

#pragma mark - Equality

- (BOOL)isEqual:(OBAStopAccessEventV2*)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:self.class]) {
        return NO;
    }

    return self.hash == object.hash;
}

- (NSUInteger)hash {
    return [NSString stringWithFormat:@"%@_%@_%@", self.title, self.subtitle, self.stopID].hash;
}

@end

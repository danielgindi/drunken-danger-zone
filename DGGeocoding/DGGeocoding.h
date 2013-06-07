//
//  DGGeocoding.h
//  DGGeocoding
//
//  Created by Daniel Cohen Gindi on 3/29/13.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import <Foundation/Foundation.h>
#import "DGGeocodingAddressResult.h"

typedef void (^DGGeocodingAddressResultBlock)(NSArray *addressResults, NSString *service); // DGGeocodingAddressResult
typedef void (^DGGeocodingErrorBlock)(NSError *error);

#define DGGeocodingServiceGoogle @"google"
#define DGGeocodingServiceBing @"bing"

@interface DGGeocoding : NSObject

+ (void)setBingKey:(NSString *)key;
+ (NSString *)bingKey;

+ (void)geocodeLocation:(NSString *)queryString withService:(NSString *)service completion:(DGGeocodingAddressResultBlock)completionBlock error:(DGGeocodingErrorBlock)errorBlock;
+ (void)geocodeLocation:(NSString *)queryString withServices:(NSArray *)services completion:(DGGeocodingAddressResultBlock)completionBlock error:(DGGeocodingErrorBlock)errorBlock;

@end

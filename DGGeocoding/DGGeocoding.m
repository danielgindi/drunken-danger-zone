//
//  DGGeocoding.m
//  DGGeocoding
//
//  Created by Daniel Cohen Gindi on 3/29/13.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//
//  The MIT License (MIT)
//  
//  Copyright (c) 2014 Daniel Cohen Gindi (danielgindi@gmail.com)
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE. 
//  

#import "DGGeocoding.h"
#import "DGGeocodingRequest.h"
#import "DGGeocodingAddressComponent.h"

@implementation DGGeocoding

static NSString *s_DGGeocoding_Bing_Key = nil;

+ (void)setBingKey:(NSString *)key
{
    s_DGGeocoding_Bing_Key = key;
}

+ (NSString *)bingKey
{
    return s_DGGeocoding_Bing_Key;
}

+ (void)geocodeLocation:(NSString *)queryString withService:(NSString *)service completion:(DGGeocodingAddressResultBlock)completionBlock error:(DGGeocodingErrorBlock)errorBlock
{
    if ([service isEqualToString:DGGeocodingServiceBing] && s_DGGeocoding_Bing_Key.length)
    {
        NSString *url = [NSString stringWithFormat:@"http://dev.virtualearth.net/REST/v1/Locations?query=%@&includeNeighborhood=0&maxResults=5&culture=%@&key=%@", [DGGeocodingRequest urlEncodedString:queryString], (NSString *)[NSLocale preferredLanguages][0], s_DGGeocoding_Bing_Key];
        [DGGeocodingRequest requestWithUrl:[NSURL URLWithString:url] cachePolicy:NSURLCacheStorageAllowed timeout:10.0 completion:^(NSObject *response) {
            
            NSDictionary *dict = (NSDictionary *)response;
            
            int statusCode = [dict[@"statusCode"] intValue];
            if (statusCode != 200)
            {
                if (errorBlock)
                {
                    errorBlock([NSError errorWithDomain:@"dev.virtualearth.net" code:statusCode userInfo:@{@"desccription": dict[@"statusDescription"]}]);
                }
                return;
            }
            
            NSArray *resourceSets = dict[@"resourceSets"];
            if (!resourceSets.count)
            {
                if (errorBlock)
                {
                    errorBlock([NSError errorWithDomain:@"dev.virtualearth.net" code:200 userInfo:@{@"description": @"no results"}]);
                }
                return;
            }
            
            NSArray *resources = resourceSets[0][@"resources"];
            if (!resources.count)
            {
                if (errorBlock)
                {
                    errorBlock([NSError errorWithDomain:@"dev.virtualearth.net" code:200 userInfo:@{@"description": @"no results"}]);
                }
                return;
            }
            
            NSMutableArray *geocodingResults = [[NSMutableArray alloc] init];
            for (NSDictionary *result in resources)
            {
                DGGeocodingAddressResult *geocodingResult = [[DGGeocodingAddressResult alloc] init];
                
                geocodingResult.address = result[@"address"][@"formattedAddress"];
                
                NSArray *bbox = result[@"bbox"];
                if (bbox)
                {
                    geocodingResult.boundsSouthWestLat = [bbox[0] doubleValue];
                    geocodingResult.boundsSouthWestLon = [bbox[1] doubleValue];
                    geocodingResult.boundsNorthEastLat = [bbox[2] doubleValue];
                    geocodingResult.boundsNorthEastLon = [bbox[3] doubleValue];
                }
                
                NSArray *coordinates = result[@"point"][@"coordinates"];
                geocodingResult.latitude = [coordinates[0] doubleValue];
                geocodingResult.longitude = [coordinates[1] doubleValue];
                
                [geocodingResults addObject:geocodingResult];
            }
            
            if (completionBlock)
            {
                completionBlock(geocodingResults, DGGeocodingServiceBing);
            }
            
        } error:^(NSError *error) {
            
            if (errorBlock)
            {
                errorBlock(error);
            }
            
        } start:YES];
    }
    else // DGGeocodingServiceGoogle
    {
        NSString *url = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?address=%@&sensor=false&language=%@", [DGGeocodingRequest urlEncodedString:queryString], [(NSString *)[NSLocale preferredLanguages][0] stringByReplacingOccurrencesOfString:@"_" withString:@"-"]];
        [DGGeocodingRequest requestWithUrl:[NSURL URLWithString:url] cachePolicy:NSURLCacheStorageAllowed timeout:10.0 completion:^(NSObject *response) {
            
            NSDictionary *dict = (NSDictionary *)response;
            
            NSString *status = dict[@"status"];
            
            if(![status isEqualToString:@"OK"])
            {
                if (errorBlock)
                {
                    errorBlock([NSError errorWithDomain:@"maps.google.com" code:0 userInfo:@{@"status": status}]);
                }
                return;
            }
            
            NSMutableArray *geocodingResults = [[NSMutableArray alloc] init];
            
            NSArray *results = dict[@"results"];
            for (NSDictionary *result in results)
            {
                DGGeocodingAddressResult *geocodingResult = [[DGGeocodingAddressResult alloc] init];
                
                NSMutableArray *components = nil; 
                NSArray *addressComponents = result[@"address_components"];
                for (NSDictionary *addressComponent in addressComponents)
                {
                    if (!components) components = [[NSMutableArray alloc] init];
                    DGGeocodingAddressComponent *component = [[DGGeocodingAddressComponent alloc] init];
                    component.longName = addressComponent[@"long_name"];
                    component.shortName = addressComponent[@"short_name"];
                    component.types = addressComponent[@"types"];
                    [components addObject:component];
                }
                geocodingResult.addressComponents = [components copy];
                geocodingResult.address = result[@"formatted_address"];
                
                NSDictionary *geometry = result[@"geometry"];
                NSDictionary *bounds = geometry[@"bounds"];
                if (bounds)
                {
                    geocodingResult.boundsNorthEastLat = [bounds[@"northeast"][@"lat"] doubleValue];
                    geocodingResult.boundsNorthEastLon = [bounds[@"northeast"][@"lng"] doubleValue];
                    geocodingResult.boundsSouthWestLat = [bounds[@"southwest"][@"lat"] doubleValue];
                    geocodingResult.boundsSouthWestLon = [bounds[@"southwest"][@"lng"] doubleValue];
                }
                
                NSDictionary *viewport = geometry[@"viewport"];
                if (viewport)
                {
                    geocodingResult.viewportNorthEastLat = [viewport[@"northeast"][@"lat"] doubleValue];
                    geocodingResult.viewportNorthEastLon = [viewport[@"northeast"][@"lng"] doubleValue];
                    geocodingResult.viewportSouthWestLat = [viewport[@"southwest"][@"lat"] doubleValue];
                    geocodingResult.viewportSouthWestLon = [viewport[@"southwest"][@"lng"] doubleValue];
                }
                
                NSDictionary *location = geometry[@"location"];
                geocodingResult.latitude = [location[@"lat"] doubleValue];
                geocodingResult.longitude = [location[@"lng"] doubleValue];
                
                [geocodingResults addObject:geocodingResult];
            }
            
            if (completionBlock)
            {
                completionBlock(geocodingResults, DGGeocodingServiceGoogle);
            }
            
        } error:^(NSError *error) {
            
            if (errorBlock)
            {
                errorBlock(error);
            }
            
        } start:YES];
    }
}

+ (void)geocodeLocation:(NSString *)queryString withServices:(NSArray *)services completion:(DGGeocodingAddressResultBlock)completionBlock error:(DGGeocodingErrorBlock)errorBlock
{
    if (services.count == 0)
    {
        services = @[DGGeocodingServiceGoogle];
    }
    
    [self geocodeLocation:queryString withService:services[0] completion:^(NSArray *addressResults, NSString *service) {
        
        if (completionBlock)
        {
            completionBlock(addressResults, service);
        }
        
    } error:^(NSError *error) {
        
        if (services.count <= 1)
        {
            if (errorBlock)
            {
                errorBlock(error);
            }
        }
        else
        {
            NSMutableArray *nextServices = [services mutableCopy];
            [nextServices removeObjectAtIndex:0];
            [self geocodeLocation:queryString withServices:nextServices completion:completionBlock error:errorBlock];
        }
        
    }];
}

@end

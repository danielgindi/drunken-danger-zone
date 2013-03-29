//
//  DGGeocodingAddressResult.h
//  DGGeocoding
//
//  Created by Daniel Cohen Gindi on 3/29/13.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface DGGeocodingAddressResult : NSObject

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSArray *addressComponents; // DGGeocodingAddressComponent
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

@property (nonatomic, assign) double viewportSouthWestLat;
@property (nonatomic, assign) double viewportSouthWestLon;
@property (nonatomic, assign) double viewportNorthEastLat;
@property (nonatomic, assign) double viewportNorthEastLon;
@property (nonatomic, assign) double boundsSouthWestLat;
@property (nonatomic, assign) double boundsSouthWestLon;
@property (nonatomic, assign) double boundsNorthEastLat;
@property (nonatomic, assign) double boundsNorthEastLon;

@property (nonatomic, assign, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign, readonly) MKCoordinateSpan coordinateSpan;
@property (nonatomic, assign, readonly) MKCoordinateRegion coordinateRegion;

// Returns array of DGGeocodingAddressComponent
- (NSArray*)findAddressComponent:(NSString*)typeName;

@end

//
//  DGGeocodingAddressComponent.h
//  DGGeocoding
//
//  Created by Daniel Cohen Gindi on 3/29/13.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DGGeocodingAddressComponent : NSObject

@property (nonatomic, strong) NSString *longName;
@property (nonatomic, strong) NSString *shortName;
@property (nonatomic, strong) NSArray *types;

@end

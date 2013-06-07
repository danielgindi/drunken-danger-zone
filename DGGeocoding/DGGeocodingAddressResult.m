//
//  DGGeocodingAddressResult.m
//  DGGeocoding
//
//  Created by Daniel Cohen Gindi on 3/29/13.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "DGGeocodingAddressResult.h"
#import "DGGeocodingAddressComponent.h"

@implementation DGGeocodingAddressResult

- (CLLocationCoordinate2D)coordinate
{
	return (CLLocationCoordinate2D){_latitude, _longitude};
}

- (MKCoordinateSpan)coordinateSpan
{
	return (MKCoordinateSpan){_viewportNorthEastLat - _viewportSouthWestLat, _viewportNorthEastLon - _viewportSouthWestLon};
}

- (MKCoordinateRegion)coordinateRegion
{
	return (MKCoordinateRegion){self.coordinate, self.coordinateSpan};
}

-(NSArray *)findAddressComponent:(NSString *)typeName
{
	NSMutableArray *matchingComponents = [[NSMutableArray alloc] init];
	
    BOOL isMatch;
    NSString *type;
	for(int i = 0, count = _addressComponents.count, typesCount, j; i < count; i++)
	{
		DGGeocodingAddressComponent *component = _addressComponents[i];
		if(component.types != nil)
		{
            isMatch = NO;
            typesCount = [component.types count];
			for(j = 0; isMatch == NO && j < typesCount; j++)
			{
                type = (component.types)[j];
				if([type isEqualToString:typeName])
				{
					[matchingComponents addObject:component];
					isMatch = YES;
				}
			}
		}
		
	}
	
	return matchingComponents;
}

@end

//
//  DGGeocodingAddressResult.m
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

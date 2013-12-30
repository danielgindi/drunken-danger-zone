//
//  NSString+Trims.h
//  Additions
//
//  Created by Daniel Cohen Gindi on 3/25/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import <Foundation/Foundation.h>

@interface NSString (Trims)

- (NSString *)stringByTrimmingWhitespace;
- (NSString *)stringByTrimmingWhitespaceAndNewlines;

@end

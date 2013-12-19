//
//  DGPhoneNumberFormatter.h
//  DGPhoneNumberFormatter
//  v1.0.1
//
//  Created by Daniel Cohen Gindi on 5/4/12.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//
//  This class is an NSFormatter that can be used like any other Cocoa formatter,
//    to format phone numbers in a manner similar to the iPhone's Phone app.
//  Clarification: This is currently design for formatting number when calling from inside Israel, to either national or international number.
//    Other countries may be supported in the future.

#import <Foundation/Foundation.h>

@interface DGPhoneNumberFormatter : NSFormatter
@end


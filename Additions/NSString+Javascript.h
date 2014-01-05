//
//  NSString+Javascript.h
//  Additions
//
//  Created by Daniel Cohen Gindi on 1/5/14.
//  Copyright (c) 2014 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import <Foundation/Foundation.h>

@interface NSString (Javascript)

- (NSString *)stringByEscapingForJavascriptWithDelimiter:(unichar)delimiter wrapWithDelimiters:(BOOL)wrap;

@end

//
//  NSLocale+RtlDetection.m
//  Additions
//
//  Created by Daniel Cohen Gindi on 6/15/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "NSLocale+RtlDetection.h"

@implementation NSLocale (RtlDetection)

+ (BOOL)isActiveLocaleRtl
{
    static BOOL isRtl = NO;
    static BOOL isRtlFound = NO;
    if (!isRtlFound)
    {
        isRtl = [NSLocale characterDirectionForLanguage:[NSBundle mainBundle].preferredLocalizations[0]] == NSLocaleLanguageDirectionRightToLeft;
        isRtlFound = YES;
    }
    return isRtl;
}

@end

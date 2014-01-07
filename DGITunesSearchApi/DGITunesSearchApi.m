//
//  DGITunesSearchApi.m
//  DGITunesSearchApi
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

#import "DGITunesSearchApi.h"
#import "DGITunesSearchApiRequest.h"

@implementation DGITunesSearchApi

+ (void)searchForTerm:(NSString *)term
            inCountry:(NSString *)country
                media:(NSString *)media
               entity:(NSString *)entity
            attribute:(NSString *)attribute
                limit:(int)limit
                 lang:(NSString *)lang
              version:(NSString *)version
             explicit:(BOOL)includeExplicit
           completion:(DGITunesSearchResultBlock)completionBlock
                error:(DGITunesSearchErrorBlock)errorBlock
{
    NSMutableString *url = [@"https://itunes.apple.com/search?term=" mutableCopy];
    [url appendString:[DGITunesSearchApiRequest urlEncodedString:term]];
    if (country)
    {
        [url appendFormat:@"&country=%@", [DGITunesSearchApiRequest urlEncodedString:country]];
    }
    if (media)
    {
        [url appendFormat:@"&media=%@", [DGITunesSearchApiRequest urlEncodedString:media]];
    }
    if (entity)
    {
        [url appendFormat:@"&entity=%@", [DGITunesSearchApiRequest urlEncodedString:entity]];
    }
    if (attribute)
    {
        [url appendFormat:@"&attribute=%@", [DGITunesSearchApiRequest urlEncodedString:attribute]];
    }
    if (limit > 0)
    {
        [url appendFormat:@"&limit=%d", limit];
    }
    if (lang)
    {
        [url appendFormat:@"&lang=%@", [DGITunesSearchApiRequest urlEncodedString:lang]];
    }
    if (version)
    {
        [url appendFormat:@"&version=%@", [DGITunesSearchApiRequest urlEncodedString:version]];
    }
    [url appendFormat:@"&explicit=%@", includeExplicit ? @"YES" : @"NO"];
    
    [DGITunesSearchApiRequest requestWithUrl:[NSURL URLWithString:url] cachePolicy:NSURLCacheStorageAllowed timeout:6.0 completion:^(NSObject *response) {
        
        BOOL isDictionary = [response isKindOfClass:NSDictionary.class];
        NSDictionary *dict = (NSDictionary *)response;
        
        if (isDictionary && dict[@"resultCount"] && dict[@"results"])
        {
            if (completionBlock)
            {
                completionBlock(dict[@"results"]);
            }
        }
        else
        {
            if (errorBlock)
            {
                errorBlock([NSError errorWithDomain:@"itunes.apple.com" code:0 userInfo:(isDictionary ? dict : nil)]);
            }
        }
        
    } error:^(NSError *error) {
        
        if (errorBlock)
        {
            errorBlock(error);
        }
        
    } start:YES];
}

@end

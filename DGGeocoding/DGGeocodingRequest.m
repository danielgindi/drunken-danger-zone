//
//  DGGeocodingRequest.m
//  DGGeocoding
//
//  Created by Daniel Cohen Gindi on 3/29/13.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//

#import "DGGeocodingRequest.h"

@interface DGGeocodingRequest () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    NSURLConnection * connection;
    NSMutableData * data;
}
@end

@implementation DGGeocodingRequest

- (id)initWithUrl:(NSURL*)url completion:(DGGeocodingRequestJsonResponseBlock)completionBlock error:(DGGeocodingRequestErrorBlock)errorBlock
{
    return [self initWithUrl:url cachePolicy:NSURLCacheStorageAllowed timeout:60 completion:completionBlock error:errorBlock];
}

- (id)initWithUrl:(NSURL *)url cachePolicy:(NSURLRequestCachePolicy)cachePolicy completion:(DGGeocodingRequestJsonResponseBlock)completionBlock error:(DGGeocodingRequestErrorBlock)errorBlock
{
    return [self initWithUrl:url cachePolicy:cachePolicy timeout:60 completion:completionBlock error:errorBlock];
}

- (id)initWithUrl:(NSURL *)url timeout:(NSTimeInterval)timeout completion:(DGGeocodingRequestJsonResponseBlock)completionBlock error:(DGGeocodingRequestErrorBlock)errorBlock
{
    return [self initWithUrl:url cachePolicy:NSURLCacheStorageAllowed timeout:timeout completion:completionBlock error:errorBlock];
}

- (id)initWithUrl:(NSURL *)url cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeout:(NSTimeInterval)timeout completion:(DGGeocodingRequestJsonResponseBlock)completionBlock error:(DGGeocodingRequestErrorBlock)errorBlock
{
    self = [super init];
    if (self)
    {
        _url = url;
        _cachePolicy = cachePolicy;
        _timeout = timeout;
        _completionBlock = [completionBlock copy];
        _errorBlock = [errorBlock copy];
    }
    return self;
}

- (DGGeocodingRequest*)start
{
    if (connection) return self;
    NSURLRequest * request = [[NSURLRequest alloc] initWithURL:_url cachePolicy:_cachePolicy timeoutInterval:_timeout];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    data = [[NSMutableData alloc] init];
    [connection start];
    return self;
}

- (DGGeocodingRequest*)cancel
{
    [connection cancel];
    connection = nil;
    data = nil;
    return self;
}

+ (DGGeocodingRequest*)requestWithUrl:(NSURL*)url completion:(DGGeocodingRequestJsonResponseBlock)completionBlock error:(DGGeocodingRequestErrorBlock)errorBlock start:(BOOL)start
{
    DGGeocodingRequest * req = [[DGGeocodingRequest alloc] initWithUrl:url completion:completionBlock error:errorBlock];
    if (start) [req start];
    return req;
}
+ (DGGeocodingRequest*)requestWithUrl:(NSURL*)url cachePolicy:(NSURLRequestCachePolicy)cachePolicy completion:(DGGeocodingRequestJsonResponseBlock)completionBlock error:(DGGeocodingRequestErrorBlock)errorBlock start:(BOOL)start
{
    DGGeocodingRequest * req = [[DGGeocodingRequest alloc] initWithUrl:url cachePolicy:cachePolicy completion:completionBlock error:errorBlock];
    if (start) [req start];
    return req;
}

+ (DGGeocodingRequest*)requestWithUrl:(NSURL*)url timeout:(NSTimeInterval)timeout completion:(DGGeocodingRequestJsonResponseBlock)completionBlock error:(DGGeocodingRequestErrorBlock)errorBlock start:(BOOL)start
{
    DGGeocodingRequest * req = [[DGGeocodingRequest alloc] initWithUrl:url timeout:timeout completion:completionBlock error:errorBlock];
    if (start) [req start];
    return req;
}

+ (DGGeocodingRequest*)requestWithUrl:(NSURL*)url cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeout:(NSTimeInterval)timeout completion:(DGGeocodingRequestJsonResponseBlock)completionBlock error:(DGGeocodingRequestErrorBlock)errorBlock start:(BOOL)start
{
    DGGeocodingRequest * req = [[DGGeocodingRequest alloc] initWithUrl:url cachePolicy:cachePolicy timeout:timeout completion:completionBlock error:errorBlock];
    if (start) [req start];
    return req;
}

+ (NSString*)urlEncodedString:(NSString*)component
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)component, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
}

#pragma mark - NSURLConnectionDelegate, NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error
{
    if (aConnection == connection)
    {
        if (_errorBlock)
        {
            _errorBlock(error);
        }
    }
}

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)theData
{
    if (aConnection == connection)
    {
        [data appendData:theData];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection
{
    if (aConnection == connection)
    {
        NSError * error = nil;
        NSObject * json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (json && !error)
        {
            if (_completionBlock)
            {
                _completionBlock(json);
            }
        }
        else
        {
            if (_errorBlock)
            {
                _errorBlock(error);
            }
        }
    }
}

@end

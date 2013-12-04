//
//  DGITunesSearchApiRequest.m
//  DGITunesSearchApi
//
//  Created by Daniel Cohen Gindi on 3/29/13.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "DGITunesSearchApiRequest.h"

@interface DGITunesSearchApiRequest () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    NSURLConnection *connection;
    NSMutableData *data;
}
@end

@implementation DGITunesSearchApiRequest

- (id)initWithUrl:(NSURL *)url completion:(DGITunesSearchApiRequestJsonResponseBlock)completionBlock error:(DGITunesSearchApiRequestErrorBlock)errorBlock
{
    return [self initWithUrl:url cachePolicy:NSURLCacheStorageAllowed timeout:60 completion:completionBlock error:errorBlock];
}

- (id)initWithUrl:(NSURL *)url cachePolicy:(NSURLRequestCachePolicy)cachePolicy completion:(DGITunesSearchApiRequestJsonResponseBlock)completionBlock error:(DGITunesSearchApiRequestErrorBlock)errorBlock
{
    return [self initWithUrl:url cachePolicy:cachePolicy timeout:60 completion:completionBlock error:errorBlock];
}

- (id)initWithUrl:(NSURL *)url timeout:(NSTimeInterval)timeout completion:(DGITunesSearchApiRequestJsonResponseBlock)completionBlock error:(DGITunesSearchApiRequestErrorBlock)errorBlock
{
    return [self initWithUrl:url cachePolicy:NSURLCacheStorageAllowed timeout:timeout completion:completionBlock error:errorBlock];
}

- (id)initWithUrl:(NSURL *)url cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeout:(NSTimeInterval)timeout completion:(DGITunesSearchApiRequestJsonResponseBlock)completionBlock error:(DGITunesSearchApiRequestErrorBlock)errorBlock
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

- (DGITunesSearchApiRequest *)start
{
    if (connection) return self;
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:_url cachePolicy:_cachePolicy timeoutInterval:_timeout];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    data = [[NSMutableData alloc] init];
    [connection start];
    return self;
}

- (DGITunesSearchApiRequest *)cancel
{
    [connection cancel];
    connection = nil;
    data = nil;
    return self;
}

+ (DGITunesSearchApiRequest *)requestWithUrl:(NSURL *)url completion:(DGITunesSearchApiRequestJsonResponseBlock)completionBlock error:(DGITunesSearchApiRequestErrorBlock)errorBlock start:(BOOL)start
{
    DGITunesSearchApiRequest *req = [[DGITunesSearchApiRequest alloc] initWithUrl:url completion:completionBlock error:errorBlock];
    if (start) [req start];
    return req;
}

+ (DGITunesSearchApiRequest *)requestWithUrl:(NSURL *)url cachePolicy:(NSURLRequestCachePolicy)cachePolicy completion:(DGITunesSearchApiRequestJsonResponseBlock)completionBlock error:(DGITunesSearchApiRequestErrorBlock)errorBlock start:(BOOL)start
{
    DGITunesSearchApiRequest *req = [[DGITunesSearchApiRequest alloc] initWithUrl:url cachePolicy:cachePolicy completion:completionBlock error:errorBlock];
    if (start) [req start];
    return req;
}

+ (DGITunesSearchApiRequest *)requestWithUrl:(NSURL *)url timeout:(NSTimeInterval)timeout completion:(DGITunesSearchApiRequestJsonResponseBlock)completionBlock error:(DGITunesSearchApiRequestErrorBlock)errorBlock start:(BOOL)start
{
    DGITunesSearchApiRequest *req = [[DGITunesSearchApiRequest alloc] initWithUrl:url timeout:timeout completion:completionBlock error:errorBlock];
    if (start) [req start];
    return req;
}

+ (DGITunesSearchApiRequest *)requestWithUrl:(NSURL *)url cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeout:(NSTimeInterval)timeout completion:(DGITunesSearchApiRequestJsonResponseBlock)completionBlock error:(DGITunesSearchApiRequestErrorBlock)errorBlock start:(BOOL)start
{
    DGITunesSearchApiRequest *req = [[DGITunesSearchApiRequest alloc] initWithUrl:url cachePolicy:cachePolicy timeout:timeout completion:completionBlock error:errorBlock];
    if (start) [req start];
    return req;
}

+ (NSString *)urlEncodedString:(NSString *)component
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)component, NULL, (CFStringRef)@"! *'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
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
        NSError *error = nil;
        NSObject *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
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

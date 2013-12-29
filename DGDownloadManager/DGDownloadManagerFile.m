//
//  DGDownloadManagerFile.m
//  DGDownloadManager
//
//  Created by Daniel Cohen Gindi on 12/29/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "DGDownloadManagerFile.h"
#import "DGDownloadManager.h"

@interface DGDownloadManagerFile () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
@end

@implementation DGDownloadManagerFile
{
    NSURLConnection *_connection;
    NSString *filePath;
    NSFileHandle *fileWriteHandle;
    NSURLRequest *urlRequest;
    BOOL resumeAllowed;
    BOOL connectionFinished;
}

- (id)initWithUrl:(NSURL *)url
{
    self = [super init];
    if (self)
    {
        _requestTimeout = 60.0;
        _cachePolicy = NSURLCacheStorageAllowed;
        _url = url;
    }
    return self;
}

- (id)initWithUrl:(NSURL *)url context:(NSObject *)context
{
    self = [super init];
    if (self)
    {
        _requestTimeout = 60.0;
        _cachePolicy = NSURLCacheStorageAllowed;
        _url = url;
        _context = context;
    }
    return self;
}

- (void)dealloc
{
    [self cancelDownloading];
    [fileWriteHandle closeFile];
    fileWriteHandle = nil;
    if (filePath)
    {
        [[[NSFileManager alloc] init] removeItemAtPath:filePath error:nil];
        filePath = nil;
    }
}

- (NSString *)newTempFilePath
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidStr = CFUUIDCreateString(NULL, uuid);
    
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"download-%@", uuidStr]];
    
    CFRelease(uuidStr);
    CFRelease(uuid);
    
    return path;
}

- (DGDownloadManagerFile *)startDownloadingNow
{
    if (_connection || !_url) return self;
    urlRequest = [[NSURLRequest alloc] initWithURL:_url cachePolicy:_cachePolicy timeoutInterval:_requestTimeout];
    _connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    connectionFinished = NO;
    [_connection start];
    
    [[DGDownloadManager sharedInstance] downloadFile:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:DGDownloadManagerDownloadStartedNotification object:self];
    if (_delegate && [_delegate respondsToSelector:@selector(downloadManagerFileStartedDownload:)])
    {
        [_delegate downloadManagerFileStartedDownload:self];
    }
    
    return self;
}

- (DGDownloadManagerFile *)cancelDownloading
{
    if (!_connection) return self;
    [_connection cancel];
    _connection = nil;
    urlRequest = nil;
    
    [[DGDownloadManager sharedInstance] cancelFileDownload:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:DGDownloadManagerDownloadCancelledNotification object:self];
    if (_delegate && [_delegate respondsToSelector:@selector(downloadManagerFileCancelledDownload:)])
    {
        [_delegate downloadManagerFileCancelledDownload:self];
    }

    return self;
}

- (DGDownloadManagerFile *)resumeDownloadNow
{
    if (_connection) return self;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_url
                                                           cachePolicy:_cachePolicy
                                                       timeoutInterval:_requestTimeout];
    
    if (resumeAllowed)
    {
        [request addValue:[NSString stringWithFormat:@"bytes=%lld-", _downloadedDataLength] forHTTPHeaderField:@"Range"];
    }
    
    urlRequest = [request copy];
    
    _connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    connectionFinished = NO;
    [_connection start];
    
    [[DGDownloadManager sharedInstance] resumeFileDownload:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:DGDownloadManagerDownloadStartedNotification object:self];
    if (_delegate && [_delegate respondsToSelector:@selector(downloadManagerFileStartedDownload:)])
    {
        [_delegate downloadManagerFileStartedDownload:self];
    }
    
    return self;
}

- (DGDownloadManagerFile *)addToDownloadQueue
{
    [[DGDownloadManager sharedInstance] downloadFile:self];
    return self;
}

- (DGDownloadManagerFile *)addToDownloadQueueForResuming
{
    [[DGDownloadManager sharedInstance] resumeFileDownload:self];
    return self;
}

#pragma mark - Accessors

- (BOOL)isComplete
{
    return _expectedContentLength == _downloadedDataLength && connectionFinished;
}

- (BOOL)isDownloading
{
    return _connection != nil;
}

- (NSString *)downloadedFilePath
{
    return filePath;
}

#pragma mark - NSURLConnectionDelegate, NSURLConnectionDataDelegate

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    _suggestedFilename = response.suggestedFilename;
    if (response)
    {
        NSMutableURLRequest *goodRequest = [urlRequest mutableCopy];
        goodRequest.URL = request.URL;
        return goodRequest;
    }
    else
    {
        return request;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _suggestedFilename = response.suggestedFilename;
    _expectedContentLength = response.expectedContentLength;
    
    NSHTTPURLResponse *httpResonse = (NSHTTPURLResponse *)response;
    NSDictionary *headers = [httpResonse allHeaderFields];
    
    resumeAllowed = [[headers valueForKey:@"Accept-Ranges"] hasSuffix:@"bytes"];
    
    long long start = 0;
    
    NSString *contentRange = [headers valueForKey:@"Content-Range"];
    if (contentRange && _downloadedDataLength > 0)
    {
        NSScanner *contentRangeScanner = [NSScanner scannerWithString:contentRange];
        [contentRangeScanner scanString:@"bytes " intoString:nil];
        [contentRangeScanner scanLongLong:&start];
        
        _expectedContentLength += start;
    }
    
    BOOL writerAlreadyExists = fileWriteHandle != nil;
    
    if (!fileWriteHandle)
    {
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        filePath = self.newTempFilePath;
        int tries = 3;
        BOOL success = [fileManager createFileAtPath:filePath contents:nil attributes:nil];
        while (!success && --tries)
        {
            filePath = self.newTempFilePath;
            success = [fileManager createFileAtPath:filePath contents:nil attributes:nil];
        }
        
        if (success)
        {
            fileWriteHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        }
        
        if (!success || !fileWriteHandle)
        {
            [connection cancel];
            _connection = nil;
            filePath = nil;
            [self connection:connection didFailWithError:nil];
        }
    }
    
    if (start > 0L)
    {
        // This is a partial, from resuming the download. Seek to the start position.
        [fileWriteHandle seekToFileOffset:start];
    }
    else if (writerAlreadyExists)
    {
        /*! @discussion In rare cases, for example in the case of an HTTP load where the content type of the load data is multipart/x-mixed-replace, the delegate will receive more than one connection:didReceiveResponse: message. In the event this occurs, delegates should discard all data previously delivered by connection:didReceiveData:, and should be prepared to handle the, potentially different, MIME type reported by the newly reported URL response. */
        
        [fileWriteHandle truncateFileAtOffset:0];
        _downloadedDataLength = 0L;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(downloadManagerFileHeadersReceived:)])
    {
        [_delegate downloadManagerFileHeadersReceived:self];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [fileWriteHandle writeData:data];
    [fileWriteHandle synchronizeFile]; // Prevent memory presure by always flushing to disk
    _downloadedDataLength += data.length;
    
    if (_progressDelegate)
    {
        [_progressDelegate downloadManagerFileProgressChanged:self];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    _connection = nil;
    urlRequest = nil;
    
    [[DGDownloadManager sharedInstance] cancelFileDownload:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:DGDownloadManagerDownloadFailedNotification object:self];
    if (_delegate && [_delegate respondsToSelector:@selector(downloadManagerFileFailedDownload:)])
    {
        [_delegate downloadManagerFileFailedDownload:self];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    _connection = nil;
    urlRequest = nil;
    connectionFinished = YES;
    
    [[DGDownloadManager sharedInstance] cancelFileDownload:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:DGDownloadManagerDownloadFinishedNotification object:self];
    if (_delegate && [_delegate respondsToSelector:@selector(downloadManagerFileFinishedDownload:)])
    {
        [_delegate downloadManagerFileFinishedDownload:self];
    }
}

@end

//
//  DGDownloadManager.m
//  DGDownloadManager.h
//
//  Created by Daniel Cohen Gindi on 12/29/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "DGDownloadManager.h"

@interface DGDownloadManager ()

@end

@implementation DGDownloadManager
{
    NSMutableArray *downloads;
    NSMutableArray *queuedDownloads;
    NSMutableArray *queuedResumes;
    
    int currentDownloadsCount;
    
    // This is used for the gap between queued downloads
    UIBackgroundTaskIdentifier bgTaskId;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        downloads = [[NSMutableArray alloc] init];
        queuedDownloads = [[NSMutableArray alloc] init];
        queuedResumes = [[NSMutableArray alloc] init];
        bgTaskId = UIBackgroundTaskInvalid;
    }
    return self;
}

- (int)totalCurrentDownloads
{
    return currentDownloadsCount + queuedDownloads.count;
}

- (int)totalCurrentQueuedDownloads
{
    return queuedDownloads.count;
}

- (int)totalCurrentInProgressDownloads
{
    return currentDownloadsCount;
}

+ (instancetype)sharedInstance
{
    static id instance = nil;
    if (!instance)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[self alloc] init];
        });
    }
    return instance;
}

- (void)beginBackgroundTask
{
    if (bgTaskId == UIBackgroundTaskInvalid)
    {
        bgTaskId = [UIApplication.sharedApplication beginBackgroundTaskWithExpirationHandler:^{
            bgTaskId = UIBackgroundTaskInvalid;
            [self cancelAllDownloads];
        }];
    }
}

- (void)endBackgroundTaskIfNotNeeded
{
    if (bgTaskId != UIBackgroundTaskInvalid && downloads.count == 0 && queuedDownloads.count == 0)
    {
        [UIApplication.sharedApplication endBackgroundTask:bgTaskId];
        bgTaskId = UIBackgroundTaskInvalid;
    }
}

- (instancetype)downloadFile:(DGDownloadManagerFile *)file
{
    @synchronized(self)
    {
        [self beginBackgroundTask];
        
        if (file.isDownloading) return self; // Return when called from DGDownloadManagerFile
        if (![downloads containsObject:file] && ![queuedDownloads containsObject:file])
        {
            if (_maximumConcurrentDownloads <= 0 || downloads.count < _maximumConcurrentDownloads)
            {
                [downloads addObject:file];
                currentDownloadsCount++;
                [file startDownloadingNow];
            }
            else
            {
                [queuedDownloads addObject:file];
                [queuedResumes addObject:@(NO)];
            }
        }
        
        [self endBackgroundTaskIfNotNeeded];
    }
    return self;
}

- (instancetype)resumeFileDownload:(DGDownloadManagerFile *)file
{
    @synchronized(self)
    {
        [self beginBackgroundTask];
        
        if (file.isDownloading) return self; // Return when called from DGDownloadManagerFile
        if (![downloads containsObject:file] && ![queuedDownloads containsObject:file])
        {
            if (_maximumConcurrentDownloads <= 0 || downloads.count < _maximumConcurrentDownloads)
            {
                [downloads addObject:file];
                currentDownloadsCount++;
                [file resumeDownloadNow];
            }
            else
            {
                [queuedDownloads addObject:file];
                [queuedResumes addObject:@(YES)];
            }
        }
        
        [self endBackgroundTaskIfNotNeeded];
    }
    return self;
}

- (instancetype)cancelFileDownload:(DGDownloadManagerFile *)file
{
    [self beginBackgroundTask];
    @synchronized(self)
    {
        if (file.isDownloading)
        {
            [file cancelDownloading];
        }
        if ([downloads containsObject:file])
        {
            int index = [downloads indexOfObject:file];
            [downloads removeObjectAtIndex:index];
            currentDownloadsCount--;
        }
        else if ([queuedDownloads containsObject:file])
        {
            int index = [queuedDownloads indexOfObject:file];
            [queuedDownloads removeObjectAtIndex:index];
            [queuedResumes removeObjectAtIndex:index];
        }
    }
    [self doNextInQueue];
    [self endBackgroundTaskIfNotNeeded];
    return self;
}

- (void)doNextInQueue
{
    @synchronized(self)
    {
        if (_maximumConcurrentDownloads <= 0 || downloads.count < _maximumConcurrentDownloads)
        {
            DGDownloadManagerFile *file = queuedDownloads.firstObject;
            if (file)
            {
                BOOL resume = [queuedResumes.firstObject boolValue];
                [downloads addObject:file];
                [queuedDownloads removeObjectAtIndex:0];
                [queuedResumes removeObjectAtIndex:0];
                currentDownloadsCount++;
                if (resume)
                {
                    [file startDownloadingNow];
                }
                else
                {
                    [file resumeDownloadNow];
                }
            }
        }
    }
}

- (instancetype)cancelAllDownloads
{
    @synchronized(self)
    {
        [self beginBackgroundTask];
        
        NSArray *currentDownloads = [downloads copy];
        [downloads removeAllObjects];
        [queuedDownloads removeAllObjects];
        [queuedResumes removeAllObjects];
        currentDownloadsCount = 0;
        
        for (DGDownloadManagerFile *file in currentDownloads)
        {
            [file cancelDownloading];
        }
        
        [self endBackgroundTaskIfNotNeeded];
    }
    return self;
}

@end

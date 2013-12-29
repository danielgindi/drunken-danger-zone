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
    
    int totalCurrentDownloads;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        downloads = [[NSMutableArray alloc] init];
        queuedDownloads = [[NSMutableArray alloc] init];
        queuedResumes = [[NSMutableArray alloc] init];
    }
    return self;
}

- (int)totalCurrentDownloads
{
    return totalCurrentDownloads;
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

- (instancetype)downloadFile:(DGDownloadManagerFile *)file
{
    @synchronized(self)
    {
        if (file.isDownloading) return self; // Return when called from DGDownloadManagerFile
        if (![downloads containsObject:file] && ![queuedDownloads containsObject:file])
        {
            if (_maximumConcurrentDownloads <= 0 || downloads.count < _maximumConcurrentDownloads)
            {
                [downloads addObject:file];
                totalCurrentDownloads++;
                [file startDownloadingNow];
            }
            else
            {
                [queuedDownloads addObject:file];
                [queuedResumes addObject:@(NO)];
            }
        }
    }
    return self;
}

- (instancetype)resumeFileDownload:(DGDownloadManagerFile *)file
{
    @synchronized(self)
    {
        if (file.isDownloading) return self; // Return when called from DGDownloadManagerFile
        if (![downloads containsObject:file] && ![queuedDownloads containsObject:file])
        {
            if (_maximumConcurrentDownloads <= 0 || downloads.count < _maximumConcurrentDownloads)
            {
                [downloads addObject:file];
                totalCurrentDownloads++;
                [file resumeDownloadNow];
            }
            else
            {
                [queuedDownloads addObject:file];
                [queuedResumes addObject:@(YES)];
            }
        }
    }
    return self;
}

- (instancetype)cancelFileDownload:(DGDownloadManagerFile *)file
{
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
            totalCurrentDownloads--;
        }
        else if ([queuedDownloads containsObject:file])
        {
            int index = [queuedDownloads indexOfObject:file];
            [queuedDownloads removeObjectAtIndex:index];
            [queuedResumes removeObjectAtIndex:index];
        }
    }
    [self doNextInQueue];
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
                totalCurrentDownloads++;
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

@end

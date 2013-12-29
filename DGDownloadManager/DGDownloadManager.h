//
//  DGDownloadManager.h
//  DGDownloadManager
//
//  Created by Daniel Cohen Gindi on 12/29/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import <Foundation/Foundation.h>
#import "DGDownloadManagerFile.h"

#define DGDownloadManagerDownloadStartedNotification @"DGDownloadManagerDownloadStartedNotification"
#define DGDownloadManagerDownloadFinishedNotification @"DGDownloadManagerDownloadFinishedNotification"
#define DGDownloadManagerDownloadCancelledNotification @"DGDownloadManagerDownloadCancelledNotification"
#define DGDownloadManagerDownloadFailedNotification @"DGDownloadManagerDownloadFailedNotification"

@interface DGDownloadManager : NSObject

@property (nonatomic, assign) int maximumConcurrentDownloads;
@property (nonatomic, assign, readonly) int totalCurrentDownloads;

/*!
 @method sharedInstance
 @brief Returns the singleton instance.
 */
+ (instancetype)sharedInstance;

/*!
 @method downloadFile:
 @brief Add this file to the download queue in the download manager. If the concurrent limit is not reached, then the download will start immediately. */
- (instancetype)downloadFile:(DGDownloadManagerFile *)file;

/*!
 @method resumeFileDownload:
 @brief This will resume the download if stopped or failed in progress. If resume is not supported - it will restart the download. */
- (instancetype)resumeFileDownload:(DGDownloadManagerFile *)file;

/*!
 @method cancelFileDownload:
 @brief Cancels the download or removes from the queue. */
- (instancetype)cancelFileDownload:(DGDownloadManagerFile *)file;

/*!
 @method cancelAllDownloads
 @brief Cancels all downloads and removes them from the queue. */
- (instancetype)cancelAllDownloads;

@end

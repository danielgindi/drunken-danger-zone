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

/*!
 @property maximumConcurrentDownloads
 @brief The maximum concurrent downloads allowed. Downloads that exceed the limit are queued.
 Default is 0, which means no limit.
 */
@property (nonatomic, assign) int maximumConcurrentDownloads;

/*!
 @property totalCurrentDownloads
 @brief Total current downloads (waiting & in-progress).
 */
@property (nonatomic, assign, readonly) int totalCurrentDownloads;

/*!
 @property totalCurrentDownloads
 @brief Total current waiting downloads.
 */
@property (nonatomic, assign, readonly) int totalCurrentQueuedDownloads;

/*!
 @property totalCurrentInProgressDownloads
 @brief Total current in-progress downloads.
 */
@property (nonatomic, assign, readonly) int totalCurrentInProgressDownloads;

/*!
 @property currentDownloads
 @brief Current downloads (waiting & in-progress).
 */
@property (nonatomic, strong, readonly) NSArray *currentDownloads;

/*!
 @property currentQueuedDownloads
 @brief Current waiting downloads.
 */
@property (nonatomic, strong, readonly) NSArray *currentQueuedDownloads;

/*!
 @property currentInProgressDownloads
 @brief Current in-progress downloads.
 */
@property (nonatomic, strong, readonly) NSArray *currentInProgressDownloads;

/*!
 @method sharedInstance
 @brief Returns the singleton instance.
 */
+ (instancetype)sharedInstance;

/*!
 @method downloadFile:
 @brief Add this file to the download queue in the download manager. If the concurrent limit is not reached, then the download will start immediately. */
- (void)downloadFile:(DGDownloadManagerFile *)file;

/*!
 @method resumeFileDownload:
 @brief This will resume the download if stopped or failed in progress. If resume is not supported - it will restart the download. */
- (void)resumeFileDownload:(DGDownloadManagerFile *)file;

/*!
 @method cancelFileDownload:
 @brief Cancels the download or removes from the queue. */
- (void)cancelFileDownload:(DGDownloadManagerFile *)file;

/*!
 @method cancelAllDownloads
 @brief Cancels all downloads and removes them from the queue. */
- (void)cancelAllDownloads;

@end

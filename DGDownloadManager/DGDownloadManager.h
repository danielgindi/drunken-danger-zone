//
//  DGDownloadManager.h
//  DGDownloadManager
//
//  Created by Daniel Cohen Gindi on 12/29/13.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
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
@property (nonatomic, assign) NSUInteger maximumConcurrentDownloads;

/*!
 @property totalCurrentDownloads
 @brief Total current downloads (waiting & in-progress).
 */
@property (nonatomic, assign, readonly) NSUInteger totalCurrentDownloads;

/*!
 @property totalCurrentDownloads
 @brief Total current waiting downloads.
 */
@property (nonatomic, assign, readonly) NSUInteger totalCurrentQueuedDownloads;

/*!
 @property totalCurrentInProgressDownloads
 @brief Total current in-progress downloads.
 */
@property (nonatomic, assign, readonly) NSUInteger totalCurrentInProgressDownloads;

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

//
//  DGDownloadManagerFile.h
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

@class DGDownloadManager, DGDownloadManagerFile;

@protocol DGDownloadManagerFileDelegate <NSObject>

@optional
- (void)downloadManagerFileStartedDownload:(DGDownloadManagerFile *)file;
- (void)downloadManagerFileCancelledDownload:(DGDownloadManagerFile *)file;
- (void)downloadManagerFileHeadersReceived:(DGDownloadManagerFile *)file;
- (void)downloadManagerFileFailedDownload:(DGDownloadManagerFile *)file;
- (void)downloadManagerFileFinishedDownload:(DGDownloadManagerFile *)file;

@end

@protocol DGDownloadManagerFileProgressDelegate <NSObject>

@required
- (void)downloadManagerFileProgressChanged:(DGDownloadManagerFile *)file;

@end

@interface DGDownloadManagerFile : NSObject

/*! @property url
    @brief The url to download */
@property (nonatomic, strong) NSURL *url;

/*! @property context
 @brief This is used to allow specifying any object to internally identify this file. Use freely. */
@property (nonatomic, strong) NSObject *context;

/*! @property cachePolicy
 @brief The cache policy to use when downloading with NSURLConnection
 Default is NSURLCacheStorageAllowed */
@property (nonatomic, assign) NSURLRequestCachePolicy cachePolicy;

/*! @property timeout
 @brief The timeout to use when downloading with NSURLConnection
 Default is 60.0 */
@property (nonatomic, assign) NSTimeInterval requestTimeout;

/*! @property delegate
 @brief A delegate to receive messages */
@property (nonatomic, weak) id<DGDownloadManagerFileDelegate> delegate;

/*! @property progressDelegate
 @brief A delegate to receive progress change messages. Use this only if you really, really need to. This is going to possibly present heavy load on the main thread. It is seperate from the main delegate property, to spare the call to respondsToSelector: from the heavy duty data procedures. */
@property (nonatomic, weak) id<DGDownloadManagerFileProgressDelegate> progressDelegate;

/*! @property allowDownloadInBackground
 @brief Should we allow backgrounding of the app while downloading this file?
 Default is YES */
@property (nonatomic, assign) BOOL allowDownloadInBackground;

/*! @property suggestedFilename
 @brief The file name received from the server.
 This is nil until the file has started receiving data from the server!
 So use this only for files that were downloaded. */
@property (nonatomic, strong, readonly) NSString *suggestedFilename;

/*! @property expectedContentLength
 @brief The expected content length received from the server.
 This is 0 until the file has started receiving data from the server!
 So use this only for files that were downloaded. */
@property (nonatomic, assign, readonly) long long expectedContentLength;

/*! @property downloadedDataLength
 @brief This is the amount of data downloaded so far. Can be used for progress. */
@property (nonatomic, assign, readonly) long long downloadedDataLength;

/*! @property isComplete
 @brief Is this download complete? */
@property (nonatomic, assign, readonly) BOOL isComplete;

/*! @property isDownloading
 @brief Is this download in progress? */
@property (nonatomic, assign, readonly) BOOL isDownloading;

/*! @property downloadedFilePath
 @brief The path of the downloaded file. This property is available only when data is available. */
@property (nonatomic, strong, readonly) NSString *downloadedFilePath;

/*!
 @method initWithUrl:
 @param url The url to download
 */
- (id)initWithUrl:(NSURL *)url;

/*!
 @method initWithUrl: context:
 @param url The url to download
 @param context This is used to allow specifying any object to internally identify this file. Use freely.
 */
- (id)initWithUrl:(NSURL *)url context:(NSObject *)context;

/*!
 @method addToDownloadQueue
 @brief Add this file to the download queue in the download manager. If the concurrent limit is not reached, then the download will start immediately.
 */
- (void)addToDownloadQueue;

/*!
 @method startDownloadingNow
 @brief Starts the download immediately, potentially exceeding the download manager concurrent limit.
 */
- (void)startDownloadingNow;

/*!
 @method cancelDownloading
 @brief Cancels the download or removes from the queue.
 */
- (void)cancelDownloading;

/*!
 @method resumeDownloadNow
 @brief This will resume the download if stopped or failed in progress. If resume is not supported - it will restart the download.
 */
- (void)resumeDownloadNow;

/*!
 @method addToDownloadQueueForResuming
 @brief Add this file to the download queue in the download manager. If the concurrent limit is not reached, then the download will start immediately. This will try to resume the download from where it stopped, if the server supports resume.
 */
- (void)addToDownloadQueueForResuming;

@end

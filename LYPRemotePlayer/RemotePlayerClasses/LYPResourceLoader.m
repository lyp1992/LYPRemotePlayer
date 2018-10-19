//
//  LYPResourceLoader.m
//  LYPRemotePlayer
//
//  Created by laiyp on 2018/10/16.
//  Copyright © 2018 laiyongpeng. All rights reserved.
//

#import "LYPResourceLoader.h"
#import "LYPRemotePlayerDownloader.h"
#import "LYPRemotePlayerAudioFile.h"
#import "NSURL+LYPCustom.h"

@interface LYPResourceLoader ()<LYPRemotePlayerDownloaderDelegate>

@property (nonatomic, strong) LYPRemotePlayerDownloader *downloader;
@property (nonatomic, strong) NSMutableArray <AVAssetResourceLoadingRequest *>*loadRequests;

@end

@implementation LYPResourceLoader

-(LYPRemotePlayerDownloader *)downloader{
    if (!_downloader) {
        _downloader = [[LYPRemotePlayerDownloader alloc]init];
        _downloader.delegate = self;
    }
    return _downloader;
}

-(NSMutableArray<AVAssetResourceLoadingRequest *> *)loadRequests{
    if (!_loadRequests) {
        _loadRequests = [[NSMutableArray alloc]init];
    }
    return _loadRequests;
}

-(BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest{
    NSLog(@"%@",loadingRequest);
    
    [self.loadRequests addObject:loadingRequest];
    
    AVAssetResourceLoadingRequest *lr = self.loadRequests.firstObject;
    NSURL *url = lr.request.URL;
//    1. 拿到url资源，判断本地是否有缓存，如果已经下载完毕，直接加载资源
//    1.1 拿到拼接路劲
//    1.2 判断路劲是否存在
//    1.3. 拿到url对应的路劲是否存在
    if ([LYPRemotePlayerAudioFile fileExistsWithAudioURL:url]) {
        [self handleLoadingRequest:loadingRequest];
        return YES;
    }
//    2. 判断数据有没有下载，如果没有下载，下载，
    long long reuqestOffSet = lr.dataRequest.requestedOffset;
    if (self.downloader.loadedSize == 0) {
        [self.downloader downLoadWithURL:[url lypHttpurl] offset:reuqestOffSet];
        return YES;
    }
    
//    3.o判断数据是不是正在下载，判断是否需要重新下载
//    3.1 当前x请求节点 > 下载节点 + 下载长度 + 容错区间666
//    3.2 当前的请求节点 < 下载节点
    if (reuqestOffSet > self.downloader.offset + self.downloader.loadedSize + 666 || reuqestOffSet < self.downloader.offset) {
        [self.downloader downLoadWithURL:[url lypHttpurl] offset:reuqestOffSet];
        return YES;
    }
    
//    4. 当前数据是正在下载，但是不需要重新下载。
    // 直接处理请求(不一定一次能够完全处理完毕), 另外一个地方处理请求(下载当中)
    [self handleAllLoadingrRequests];
    
    return YES;
}
- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    
    //    [self.loadRequests removeObject:loadingRequest];
    [loadingRequest finishLoading];
}
#pragma mark - LYPRemotePlayerDownloaderDelegate

- (void)reciveNewData {
    [self handleAllLoadingrRequests];
}

/**
 负责处理所有的资源加载请求
 */
-(void)handleAllLoadingrRequests{
    NSMutableArray *deleteRequest = [NSMutableArray array];
    for (AVAssetResourceLoadingRequest *loadingReuqest in self.loadRequests) {
        if ([loadingReuqest isCancelled] || [loadingReuqest isFinished]) {
            [deleteRequest addObject:loadingReuqest];
            continue;
        }
        
           // 1. loadingRequest, 填充内容信息
        loadingReuqest.contentInformationRequest.contentType = self.downloader.contentType;
        loadingReuqest.contentInformationRequest.contentLength = self.downloader.totalSize;
        loadingReuqest.contentInformationRequest.byteRangeAccessSupported = YES;
         // 2. 响应内容数据
        NSData *data = [NSData dataWithContentsOfFile:[LYPRemotePlayerAudioFile tmpAudioFilePath:self.downloader.url] options:NSDataReadingMappedIfSafe error:nil];
        if (data.length == 0) {
            data = [NSData dataWithContentsOfFile:[LYPRemotePlayerAudioFile cacheAudioFilePath:self.downloader.url] options:NSDataReadingMappedIfSafe error:nil];
        }
        if (data.length == 0) {
            break;
        }
        long long requestOffset = loadingReuqest.dataRequest.requestedOffset;
        if (loadingReuqest.dataRequest.currentOffset != 0) {
            requestOffset = loadingReuqest.dataRequest.currentOffset;
        }
        long long requestLength = loadingReuqest.dataRequest.requestedLength;
        long long responseOffset = requestOffset - self.downloader.offset;
        long long responseLength = MIN(self.downloader.offset + self.downloader.loadedSize - requestOffset, requestLength);
        
        NSData *subData = [data subdataWithRange:NSMakeRange(responseOffset, responseLength)];
        
        [loadingReuqest.dataRequest respondWithData:subData];
        
        // 3. 如果响应完毕, 直接完成
        if (responseLength == requestLength) {
            [loadingReuqest finishLoading];
            [deleteRequest addObject:loadingReuqest];
        }
        
    }
    [self.loadRequests removeObjectsInArray:deleteRequest];
}

-(void)handleLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    
    NSURL *url = loadingRequest.request.URL;
    
//    1.获取资源
    NSData *data = [NSData dataWithContentsOfFile:[LYPRemotePlayerAudioFile cacheAudioFilePath:url] options:NSDataReadingMappedIfSafe error:nil];
    loadingRequest.contentInformationRequest.contentType = [LYPRemotePlayerAudioFile contentTypeWithURL:url];
    loadingRequest.contentInformationRequest.contentLength = [LYPRemotePlayerAudioFile fileSizeWithURL:url];
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    long long requestOffset = loadingRequest.dataRequest.requestedOffset;
    long long requestLength = loadingRequest.dataRequest.requestedLength;
    
    NSData *subData = [data subdataWithRange:NSMakeRange(requestOffset, requestLength)];
    [loadingRequest.dataRequest respondWithData:subData];
    [loadingRequest finishLoading];
    
}
@end

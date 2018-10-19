//
//  LYPRemotePlayerDownloader.m
//  LYPRemotePlayer
//
//  Created by laiyp on 2018/10/19.
//  Copyright © 2018 laiyongpeng. All rights reserved.
//

#import "LYPRemotePlayerDownloader.h"
#import "LYPRemotePlayerAudioFile.h"
@interface LYPRemotePlayerDownloader ()<NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSOutputStream *stream;

@end

@implementation LYPRemotePlayerDownloader

- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue new]];
    }
    return _session;
}


-(void)downLoadWithURL:(NSURL *)url offset:(long long)offset{
    
    self.url = url;
    [self cancelAndClean];
    self.offset = offset;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-", offset] forHTTPHeaderField:@"Range"];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
    [task resume];
    
}
- (void)cancelAndClean {
    [self.session invalidateAndCancel];
    self.session = nil;
    
    // 清楚本地临时缓存
    // 1. 临时缓存路径
    // 2. 清楚
    [LYPRemotePlayerAudioFile removeTmpFileWithURL:self.url];
    
    // 重置数据
    self.loadedSize = 0;
    self.offset = 0;
    self.totalSize = 0;
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    NSLog(@"%@", response);
    
    self.contentType = response.allHeaderFields[@"Content-Type"];
    
    NSString *rangeStr = response.allHeaderFields[@"Content-Range"];
    self.totalSize = [[rangeStr componentsSeparatedByString:@"/"].lastObject longLongValue];
    
    
    self.stream = [NSOutputStream outputStreamToFileAtPath:[LYPRemotePlayerAudioFile tmpAudioFilePath:self.url] append:YES];
    [self.stream open];
    
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
    if ([self.delegate respondsToSelector:@selector(reciveNewData)]) {
        [self.delegate reciveNewData];
    }
    self.loadedSize += data.length;
    [self.stream write:data.bytes maxLength:data.length];
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    [self.stream close];
    // 结束之后 == 下载完成
    // 当前已经下载的文件总大小 == 文件真正总大小 , 文件已经被下载完成 => 移动到下载完成文件夹
    if (error == nil) {
        NSLog(@"下载完成");
        if (self.offset == 0) {
            [LYPRemotePlayerAudioFile moveTmpFileToCacheFileWithURL:self.url];
        }
    }else {
        NSLog(@"%@", error);
    }
    
    
}

@end

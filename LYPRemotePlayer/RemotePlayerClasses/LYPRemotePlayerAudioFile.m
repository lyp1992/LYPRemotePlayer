//
//  LYPRemotePlayerAudioFile.m
//  LYPRemotePlayer
//
//  Created by laiyp on 2018/10/19.
//  Copyright © 2018 laiyongpeng. All rights reserved.
//

#import "LYPRemotePlayerAudioFile.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define kCache NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
#define kTmp NSTemporaryDirectory()
@implementation LYPRemotePlayerAudioFile
+ (NSString *)cacheAudioFilePath:(NSURL *)url{
       return [kCache stringByAppendingPathComponent:url.lastPathComponent];
}
+ (NSString *)tmpAudioFilePath:(NSURL *)url{
      return [kTmp stringByAppendingPathComponent:url.lastPathComponent];
}


+ (BOOL)fileExists:(NSString *)path{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (BOOL)fileExistsWithAudioURL:(NSURL *)url{
     return [self fileExists:[self cacheAudioFilePath:url]];
}

+ (NSString *)contentTypeWithURL:(NSURL *)url{
    
    NSString *fileExtension = [self cacheAudioFilePath:url].pathExtension;
    
    CFStringRef contentTypeCF = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef _Nonnull)(fileExtension), NULL);
    NSString *contentType = CFBridgingRelease(contentTypeCF);
    return contentType;
}


+ (long long)fileSizeWithURL:(NSURL *)url{
    NSString *path = [self cacheAudioFilePath:url];
    NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    
    return [fileInfo[NSFileSize] longLongValue];
    
}

+ (void)removeTmpFileWithURL:(NSURL *)url{
    NSString *tmp = [self tmpAudioFilePath:url];
    BOOL isDirectory;
    if ([[NSFileManager defaultManager] fileExistsAtPath:tmp isDirectory:&isDirectory]) {
        
        if (!isDirectory) {
            [[NSFileManager defaultManager] removeItemAtPath:tmp error:nil];
        }
        
    }
}


+ (void)moveTmpFileToCacheFileWithURL:(NSURL *)url{
    NSString *tmp = [self tmpAudioFilePath:url];
    NSString *cache = [self cacheAudioFilePath:url];
    if ([self fileExists:tmp]) {
        [[NSFileManager defaultManager] moveItemAtPath:tmp toPath:cache error:nil];
    }
    
}
@end

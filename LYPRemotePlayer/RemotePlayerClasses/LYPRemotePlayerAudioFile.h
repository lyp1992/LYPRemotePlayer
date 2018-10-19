//
//  LYPRemotePlayerAudioFile.h
//  LYPRemotePlayer
//
//  Created by laiyp on 2018/10/19.
//  Copyright © 2018 laiyongpeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LYPRemotePlayerAudioFile : NSObject

+ (NSString *)cacheAudioFilePath:(NSURL *)url;
+ (NSString *)tmpAudioFilePath:(NSURL *)url;


+ (BOOL)fileExists:(NSString *)path;

+ (BOOL)fileExistsWithAudioURL:(NSURL *)url;

+ (NSString *)contentTypeWithURL:(NSURL *)url;


+ (long long)fileSizeWithURL:(NSURL *)url;

+ (void)removeTmpFileWithURL:(NSURL *)url;


+ (void)moveTmpFileToCacheFileWithURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END

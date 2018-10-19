//
//  LYPRemotePlayerDownloader.h
//  LYPRemotePlayer
//
//  Created by laiyp on 2018/10/19.
//  Copyright © 2018 laiyongpeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LYPRemotePlayerDownloaderDelegate <NSObject>

-(void)reciveNewData;

@end

@interface LYPRemotePlayerDownloader : NSObject

@property (nonatomic, assign) long long loadedSize;
@property (nonatomic, assign) long long offset;
@property (nonatomic, assign) long long totalSize;
@property (nonatomic, copy) NSString *contentType;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, weak) id<LYPRemotePlayerDownloaderDelegate>delegate;

- (void)downLoadWithURL:(NSURL *)url offset:(long long)offset;

@end

NS_ASSUME_NONNULL_END

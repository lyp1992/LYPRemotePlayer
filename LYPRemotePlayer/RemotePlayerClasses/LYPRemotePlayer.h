//
//  LYPRemotePlayer.h
//  LYPRemotePlayer
//
//  Created by laiyp on 2018/10/11.
//  Copyright © 2018 laiyongpeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
播放状态
 - LYPRemoteAudioPlayerStateUnknown: 未知错误
 - LYPRemoteAudioPlayerStateLoading: 正在加载
 - LYPRemoteAudioPlayerStatePlaying: 正在播放
 - LYPRemoteAudioPlayerStateStopped: 播放停止
 - LYPRemoteAudioPlayerStatePause: 播放暂停
 - LYPRemoteAudioPlayerStateFailed: 播放失败
 */
typedef NS_ENUM(NSInteger,LYPRemoteAudioPlayerState){
    LYPRemoteAudioPlayerStateUnknown = 0,
    LYPRemoteAudioPlayerStateLoading   = 1,
    LYPRemoteAudioPlayerStatePlaying   = 2,
    LYPRemoteAudioPlayerStateStopped   = 3,
    LYPRemoteAudioPlayerStatePause     = 4,
    LYPRemoteAudioPlayerStateFailed    = 5
};

@interface LYPRemotePlayer : NSObject

+(instancetype)shareInstance;
-(void)playWithUrl:(NSURL *)url isCashed:(BOOL)isCash;
-(void)pause;
-(void)resume;
-(void)stop;
-(void)seekWithTimeInterval:(NSTimeInterval)TimeInterval;
-(void)seekToProgress:(CGFloat)progress;

@property (nonatomic, assign) float rate;
@property (nonatomic, assign) BOOL muted;
@property (nonatomic, assign) float volume;

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) CGFloat loadProgress;

@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, assign) NSTimeInterval duration;

@property (nonatomic, assign) LYPRemoteAudioPlayerState playerState;
@end

NS_ASSUME_NONNULL_END

//
//  LYPRemotePlayer.m
//  LYPRemotePlayer
//
//  Created by laiyp on 2018/10/11.
//  Copyright © 2018 laiyongpeng. All rights reserved.
//

#import "LYPRemotePlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "LYPResourceLoader.h"
#import "NSURL+LYPCustom.h"
@interface LYPRemotePlayer ()
{
    BOOL _isUserPause;
}
@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) LYPResourceLoader *resourceLoader;

@end

@implementation LYPRemotePlayer
static LYPRemotePlayer *_palyer;
+(instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _palyer = [[self alloc]init];
    });
    return _palyer;
}
-(void)playWithUrl:(NSURL *)url isCashed:(BOOL)isCash{
    
    if ([url isEqual:self.url]) {
//        播放器存在，判断状态
        if (self.playerState == LYPRemoteAudioPlayerStateLoading) {
            return;
        }
        if (self.playerState == LYPRemoteAudioPlayerStatePlaying) {
            return;
        }
//        暂停 -> 恢复播放
        if (self.playerState == LYPRemoteAudioPlayerStatePause) {
            [self resume];
            return;
        }
    }
    self.url = url;
    NSURL *requsetUrl = url;
    if (isCash) {
        requsetUrl = [url lypURL];
    }
//    内部请求三步骤
//    1.资源请求
//    AVAsset *avAsset = [AVAsset assetWithURL:requsetUrl];
    AVURLAsset *avAsset = [AVURLAsset assetWithURL:requsetUrl];
    if (self.avPlayer.currentItem) {
        [self clearObserve];
    }
    self.resourceLoader = [LYPResourceLoader new];
    [avAsset.resourceLoader setDelegate:self.resourceLoader queue:dispatch_get_main_queue()];
//    2.资源组织
    AVPlayerItem *playeritem = [AVPlayerItem playerItemWithAsset:avAsset];
    [playeritem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
     [playeritem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
//    3.资源播放
    self.avPlayer = [[AVPlayer alloc]initWithPlayerItem:playeritem];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playInterrup) name:AVPlayerItemPlaybackStalledNotification object:nil];
}

-(void)pause{
    [self.avPlayer pause];
    if (self.avPlayer) {
        _isUserPause = YES;
        self.playerState = LYPRemoteAudioPlayerStatePause;
    }
}
-(void)resume{
    [self.avPlayer play];
    if (self.avPlayer) {
        _isUserPause = NO;
        self.playerState = LYPRemoteAudioPlayerStatePlaying;
    }
}
-(void)stop{
    [self.avPlayer pause];
    [self clearObserve];
    _isUserPause = YES;
    self.avPlayer = nil;
    self.playerState = LYPRemoteAudioPlayerStateStopped;
}
-(void)seekWithTimeInterval:(NSTimeInterval)TimeInterval{

    //    CMTime 影片时间
    // 影片时间-> 秒
    //CMTimeGetSeconds(<#CMTime time#>);
    // 秒 -> 影片时间
    //CMTimeMake(秒, NSEC_PER_SEC)
    NSTimeInterval timeInterv = CMTimeGetSeconds(self.avPlayer.currentItem.currentTime) + TimeInterval;
    [self.avPlayer seekToTime:CMTimeMakeWithSeconds(timeInterv, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        if (finished) {
            NSLog(@"确定加载这个时间段的数据");
        }else{
            NSLog(@"确定取消这个时间段的数据");
        }
    }];
    
}
-(void)seekToProgress:(CGFloat)progress{
    NSTimeInterval timesec = CMTimeGetSeconds(self.avPlayer.currentItem.duration)*progress;
    [self.avPlayer seekToTime:CMTimeMakeWithSeconds(timesec, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        if (finished) {
            NSLog(@"确定加载这个时间段的数据");
        }else{
            NSLog(@"确定取消这个时间段的数据");
        }
    }];
}

-(void)setRate:(float)rate{
    self.avPlayer.rate = rate;
}
-(void)setMuted:(BOOL)muted{
    self.avPlayer.muted = muted;
}
-(void)setVolume:(float)volume{
    if (volume>0.0) {
        self.avPlayer.muted = NO;
    }
    self.avPlayer.volume = volume;
}

-(CGFloat)progress{
    if (self.duration == 0.0) {
        return 0;
    }
    return self.currentTime/self.duration;
}
-(CGFloat)loadProgress{
    if (self.duration == 0.0) {
        return 0;
    }
    
    CMTimeRange range = [self.avPlayer.currentItem.loadedTimeRanges.lastObject CMTimeRangeValue];
    CMTime loadtime = CMTimeAdd(range.start, range.duration);
    NSTimeInterval loadtimeSec = CMTimeGetSeconds(loadtime);
    
    return (loadtimeSec/self.duration);
}
-(NSTimeInterval)duration{
    NSTimeInterval totalTime = CMTimeGetSeconds(self.avPlayer.currentItem.duration);
    if (isnan(totalTime)) {
        return 0.0;
    }
    return totalTime;
}
-(NSTimeInterval)currentTime{
    NSTimeInterval currentTime = CMTimeGetSeconds(self.avPlayer.currentItem.currentTime);
    if (isnan(currentTime)) {
        return 0.0;
    }
    return currentTime;
}

-(void)playEnd{
    self.playerState = LYPRemoteAudioPlayerStateStopped;
}

-(void)playInterrup{
    self.playerState = LYPRemoteAudioPlayerStatePause;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerStatusUnknown:
            {
                NSLog(@"资源无效");
                self.playerState = LYPRemoteAudioPlayerStateFailed;
                break;
            }
            case AVPlayerStatusReadyToPlay:
            {
                NSLog(@"资源准备好了，z开始播放");
                [self resume];
                break;
            }
            case AVPlayerStatusFailed:
            {
                NSLog(@"资源准备失败");
                self.playerState = LYPRemoteAudioPlayerStateFailed;
                break;
            }
            default:
                break;
        }
    }
    if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        BOOL playbackLikelyToKeepUp = [change[NSKeyValueChangeNewKey] boolValue];
        if (playbackLikelyToKeepUp) {
            NSLog(@"资源加载的可以播放了");
            
            // 具体要不要自动播放, 不能确定;
            // 用户手动暂停优先级, 最高 > 自动播放
            if (!_isUserPause) {
                [self resume];
            }
            
        }else {
            
            NSLog(@"资源正在加载");
            self.playerState = LYPRemoteAudioPlayerStateFailed;
        }
    }
}

-(void)clearObserve{
    [self.avPlayer.currentItem removeObserver:self forKeyPath:@"status"];
    [self.avPlayer.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
-(void)setPlayerState:(LYPRemoteAudioPlayerState)playerState{
    _playerState = playerState;
}
@end

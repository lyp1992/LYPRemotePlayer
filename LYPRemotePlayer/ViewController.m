//
//  ViewController.m
//  LYPRemotePlayer
//
//  Created by laiyp on 2018/10/11.
//  Copyright © 2018 laiyongpeng. All rights reserved.
//

#import "ViewController.h"
#import "RemotePlayerClasses/LYPRemotePlayer.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISlider *playingTime;
@property (weak, nonatomic) IBOutlet UILabel *playedTime;
@property (weak, nonatomic) IBOutlet UILabel *totalTime;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation ViewController

-(NSTimer *)timer{
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop]addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self timer];
}
- (IBAction)play:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://audio.xmcdn.com/group22/M0B/60/85/wKgJM1g1g0ShoPalAJiI5nj3-yY200.m4a"];
    [[LYPRemotePlayer shareInstance]playWithUrl:url isCashed:YES];
}

- (IBAction)pause:(id)sender {
    [[LYPRemotePlayer shareInstance]pause];
}
- (IBAction)resume:(id)sender {
    [[LYPRemotePlayer shareInstance]resume];
}
- (IBAction)stop:(id)sender {
    [[LYPRemotePlayer shareInstance]stop];
}
- (IBAction)fastForWorld:(id)sender {
    [[LYPRemotePlayer shareInstance]seekWithTimeInterval:15];
}
- (IBAction)playerSpeed:(UISlider *)sender {
    [[LYPRemotePlayer shareInstance]seekToProgress:sender.value];
}


- (IBAction)volume:(UISlider *)sender {
    [LYPRemotePlayer shareInstance].volume = sender.value;
}

- (IBAction)mute:(UIButton *)sender {
    
    [LYPRemotePlayer shareInstance].muted = !sender.selected;
}

-(void)update{

    self.playedTime.text = [NSString stringWithFormat:@"%0.2d:%0.2d",(int)[LYPRemotePlayer shareInstance].currentTime/60,(int)[LYPRemotePlayer shareInstance].currentTime%60];
    self.totalTime.text = [NSString stringWithFormat:@"%0.2d:%0.2d",(int)[LYPRemotePlayer shareInstance].duration/60,(int)[LYPRemotePlayer shareInstance].duration%60];
    
    self.playingTime.value = [LYPRemotePlayer shareInstance].progress;
//    NSLog(@"==%ld",(long)[LYPRemotePlayer shareInstance].playerState);
}

@end

//
//  ViewController.m
//  AudioFileServices
//
//  Created by admin on 2018/6/12.
//  Copyright © 2018年 dai. All rights reserved.
//

#import "ViewController.h"
#import "DQAudioPlayer.h"
@interface ViewController ()
@property(nonatomic,strong) DQAudioPlayer *audioPlayer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"01" ofType:@"mp3"];
    self.audioPlayer = [[DQAudioPlayer alloc]initWithPath:filePath];
}
- (IBAction)touchPlay:(id)sender {
    // AudioToolBox  播放音乐
    [self.audioPlayer startPlay];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

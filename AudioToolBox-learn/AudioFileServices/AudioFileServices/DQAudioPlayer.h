//
//  DQAudioPlayer.h
//  AudioFileServices
//
//  Created by admin on 2018/6/12.
//  Copyright © 2018年 dai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DQAudioPlayer : NSObject
- (instancetype)initWithPath:(NSString *)filePath;
- (void)startPlay;
- (void)stop;
@end

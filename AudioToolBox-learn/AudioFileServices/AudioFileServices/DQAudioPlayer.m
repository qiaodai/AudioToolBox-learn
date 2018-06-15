//
//  DQAudioPlayer.m
//  AudioFileServices
//
//  Created by admin on 2018/6/12.
//  Copyright © 2018年 dai. All rights reserved.
//

#import "DQAudioPlayer.h"
#import <AudioToolbox/AudioToolbox.h>

static const UInt32 maxBufferSize = 0x10000;
static const UInt32 minBufferSize = 0x4000;
static const UInt32 maxBufferNum = 3;


@interface DQAudioPlayer()
{
    AudioFileID _audioFile;
    AudioStreamBasicDescription dataFormat;
    AudioQueueRef _queue;
    UInt32 numPacketsToRead;
    AudioStreamPacketDescription *packetDescs;
    AudioQueueBufferRef buffers[maxBufferNum];
    SInt64 packetIndex;
    AudioFileID audioFile;
    UInt32 maxPacketSize;
    UInt32 outBufferSize;
}
@end
@implementation DQAudioPlayer
// 回调函数 CallBack 的实现
static void BufferCallback(void *inUserData,AudioQueueRef inAQ,AudioQueueBufferRef buffer){
    DQAudioPlayer *player = (__bridge DQAudioPlayer*)inUserData;
    for (unsigned int i = 0; i < 3; ++i) {
        if (buffer == player->buffers[i]) {
            NSLog(@"index %d",i);
            break;
        }
    }
    [player audioQueueOutputWithQueue:inAQ queueBuffer:buffer];
}
- (void)audioQueueOutputWithQueue:(AudioQueueRef)audioQueue queueBuffer:(AudioQueueBufferRef)audioQueueBuffer{
    //读取数据包
    UInt32 ioNumBytes = outBufferSize;
    UInt32 ioNumPackets = numPacketsToRead;
    AudioFileReadPacketData(audioFile, NO, &ioNumBytes, packetDescs, packetIndex, &ioNumPackets, audioQueueBuffer->mAudioData);
    //读取成功时
    if(ioNumPackets > 0){
        //将缓冲的容量设置为与读取的音频数据一样大小
        audioQueueBuffer->mAudioDataByteSize = ioNumBytes;
        // 完成给队列配置缓存的处理
        AudioQueueEnqueueBuffer(audioQueue, audioQueueBuffer, ioNumPackets, packetDescs);
        //移动包的位置
        packetIndex += ioNumPackets;
        NSLog(@"... packetIndex = %lld",packetIndex);
    }
}
- (instancetype)initWithPath:(NSString *)filePath{
    self = [super init];
    if (nil != self ){
        UInt32 size;
        OSStatus status = AudioFileOpenURL((__bridge CFURLRef)[NSURL fileURLWithPath:filePath], kAudioFileReadPermission, 0, &audioFile);
        if (status != noErr){
            NSLog(@"*** Error *** filePath:%@--code:%d", filePath,(int)status);
            return self;
        }
        //取得音频数据格式
        size = sizeof(dataFormat);
        AudioFileGetProperty(audioFile, kAudioFilePropertyDataFormat, &size, &dataFormat);
        
        //创建播放用的音频队列
        AudioQueueNewOutput(&dataFormat, BufferCallback, (__bridge void * _Nullable)(self), nil, nil, 0, &_queue);
        size = sizeof(maxPacketSize);
        //读取 最大Packet大小
        AudioFileGetProperty(audioFile, kAudioFilePropertyPacketSizeUpperBound, &size, &maxPacketSize);
        if(dataFormat.mFramesPerPacket != 0){
            Float64 numPacketsPersecond = dataFormat.mSampleRate / dataFormat.mFramesPerPacket;
            outBufferSize = numPacketsPersecond *maxPacketSize;
        }else{
            outBufferSize = maxBufferSize > maxPacketSize ? maxBufferSize : maxPacketSize;
        }
        if (outBufferSize > maxBufferSize && outBufferSize > maxPacketSize){
            outBufferSize = maxBufferSize;
        } else {
            if (outBufferSize < minBufferSize){
                outBufferSize = minBufferSize;
            }
        }
        numPacketsToRead = outBufferSize / maxPacketSize;
        packetDescs = (AudioStreamPacketDescription*)malloc(numPacketsToRead *sizeof(AudioStreamPacketDescription));
        //创建并分配缓存空间
        for (int i = 0; i < maxBufferNum; i++) {
            AudioQueueAllocateBuffer(_queue, outBufferSize, &buffers[i]);
            [self audioQueueOutputWithQueue:_queue queueBuffer:buffers[i]];
        }
        Float32 gain = 1.0;
        //设置音量
        AudioQueueSetParameter(_queue, kAudioQueueParam_Volume, gain);

        
    }
    return self;
}
- (void)startPlay{
    //队列开始处理，此后系统开始自动调用回调（Callback）函数
    AudioQueueStart(_queue, nil);
}
- (void)stop{
    AudioQueueStop(_queue, YES);
}



































@end

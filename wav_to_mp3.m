//
//  wav_to_mp3.m
//  time
//
//  Created by mac on 2017/11/6.
//  Copyright © 2017年 Sion Information Technology Co., Ltd. All rights reserved.
//

#import "wav_to_mp3.h"

#include "lame.h"

@implementation wav_to_mp3

#pragma mark - wav 转 mp3
- (void)audio_PCMtoMP3

{
    
    @try {
        
        int read, write;
        
        FILE *pcm = fopen([_recordUrl cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        
        FILE *mp3 = fopen([_mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        
        const int PCM_SIZE = 8192;
        
        const int MP3_SIZE = 8192;
        
        short int pcm_buffer[PCM_SIZE*2];
        
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        
        lame_set_in_samplerate(lame, 22050);
        
        lame_set_brate(lame, 1024);// 压缩的比特率为128K
        
        lame_set_VBR(lame, vbr_default);
        
        lame_init_params(lame);
        
        do {
            
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            
            if (read == 0)
                
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        
        fclose(mp3);
        
        fclose(pcm);
        
    }
    
    @catch (NSException *exception) {
        
        NSLog(@"%@",[exception description]);
        
    }
    
    @finally {
        
        self.voiceData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:_recordUrl]];
        /**
         *  删除转码之前的文件
         */
        //        [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:_recordUrl] error:nil]; // 生成文件移除原文件
        
    }
    
}

@end

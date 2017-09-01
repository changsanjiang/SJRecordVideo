//
//  SJRecordVideoServer.m
//  SJRecordVideo
//
//  Created by BlueDancer on 2017/9/1.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJRecordVideoServer.h"

#import <GPUImage.h>

#import "GPUImageBeautifyFilter.h"

#import <objc/message.h>

@interface SJRecordVideoServer ()

@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;

@property (nonatomic, strong) GPUImageView *filterView;

@property (nonatomic, strong) GPUImageBeautifyFilter *beautifyFilter;

@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;

@end

@implementation SJRecordVideoServer

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    // 采集 -> 滤镜处理 -> 展示
    
    // 采集
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    [self.videoCamera startCameraCapture];
    
    // 滤镜
    [self.videoCamera addTarget:self.beautifyFilter];
    
    // 展示
    [self.beautifyFilter addTarget:self.filterView];
    
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]);
    
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:[UIScreen mainScreen].bounds.size];
    self.movieWriter.encodingLiveVideo = YES;
    [self.beautifyFilter addTarget:self.movieWriter];
    
    return self;
}

// MARK: Default Lazy

- (GPUImageVideoCamera *)videoCamera {
    if ( _videoCamera ) return _videoCamera;
    _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionFront];
    return _videoCamera;
}

- (GPUImageView *)filterView {
    if ( _filterView ) return _filterView;
    _filterView = [[GPUImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    return _filterView;
}

- (GPUImageBeautifyFilter *)beautifyFilter {
    if ( _beautifyFilter ) return _beautifyFilter;
    _beautifyFilter = [GPUImageBeautifyFilter new];
    return _beautifyFilter;
}

@end



@implementation SJRecordVideoServer (Preview)

- (UIView *)previewView {
    return self.filterView;
}

@end



@implementation SJRecordVideoServer (Record)

/*!
 *  开始录制视频
 */
- (void)startRecordingWithOrientation:(UIDeviceOrientation)orientation {
    self.videoCamera.audioEncodingTarget = self.movieWriter;
    [self.movieWriter startRecording];
}

/*!
 *  完成录制视频
 */
- (void)stopRecordingAndComplate:(void(^)(AVAsset *sandboxAsset, UIImage *coverImage))block {
    [self.beautifyFilter removeTarget:self.movieWriter];
    self.videoCamera.audioEncodingTarget = nil;
    [self.movieWriter finishRecording];
}

@end

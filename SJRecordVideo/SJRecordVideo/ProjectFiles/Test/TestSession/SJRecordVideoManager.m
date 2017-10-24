//
//  SJRecordVideoManager.m
//  SJRecordVideo
//
//  Created by BlueDancer on 2017/9/17.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJRecordVideoManager.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIImageView.h>

@interface SJRecordVideoManager ()

@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureDeviceInput *audioInput;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioOutput;
@property (nonatomic, strong) UIImageView *previewImage;

@end

@implementation SJRecordVideoManager

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
//    AVCaptureDevice *videoDevice = [AVCaptureDevice ]
//    self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:avdevice error:<#(NSError *__autoreleasing *)#>]
    return self;
}

- (__kindof UIView *)previewImage {
    if ( _previewView ) return _previewView;
    _previewView = [UIImageView new];
    return _previewView;
}

@end

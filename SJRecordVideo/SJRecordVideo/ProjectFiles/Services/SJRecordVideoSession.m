//
//  SJRecordVideoSession.m
//  SJRecordVideo
//
//  Created by BlueDancer on 2017/8/3.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJRecordVideoSession.h"

#import <AVFoundation/AVFoundation.h>

#import <AVFoundation/AVCaptureFileOutput.h>

#import "NSTimer+Extension.h"

#import <objc/message.h>


@interface SJRecordVideoSession (AVCaptureFileOutputRecordingDelegateMethods)<AVCaptureFileOutputRecordingDelegate>

- (void)compoundRecordsMedia;

@end


@interface SJRecordVideoSession ()

@property (nonatomic, strong, readonly) AVCaptureSession *session;
@property (nonatomic, strong, readonly) AVCaptureDevice *dbVideoDevice;
@property (nonatomic, strong, readonly) AVCaptureDevice *dbAudioDevice;
@property (nonatomic, strong, readonly) AVCaptureDeviceInput *dbVideoInput;
@property (nonatomic, strong, readonly) AVCaptureDeviceInput *dbAudioInput;
@property (nonatomic, strong, readonly) AVCaptureMovieFileOutput *dbMovieOutput;
@property (nonatomic, strong, readonly) AVCaptureVideoPreviewLayer *dbPreviewLayer;
@property (nonatomic, strong, readonly) NSURL *camera_movieOutURL;
@property (nonatomic, strong, readonly) NSURL *camera_movieFolderURL;

@property (nonatomic, assign, readwrite) NSInteger camera_movieRecordIndex;

@property (nonatomic, strong, readonly) NSTimer *exportProgressTimer;
@property (nonatomic, strong, readwrite) AVAssetExportSession *stoppedExportSession;

@property (nonatomic, strong, readwrite) void(^exportedCallBlock)(AVAsset *asset, UIImage *coverImage);
@property (nonatomic, strong, readwrite) void(^pausedCallBlock)();

@property (nonatomic, assign, readwrite) AVCaptureVideoOrientation orientation;
@property (nonatomic, assign, readwrite) BOOL isStopRecord;

@end

@implementation SJRecordVideoSession

@synthesize session = _session;
@synthesize dbVideoDevice = _dbVideoDevice;
@synthesize dbAudioDevice = _dbAudioDevice;
@synthesize dbVideoInput = _dbVideoInput;
@synthesize dbAudioInput = _dbAudioInput;
@synthesize dbMovieOutput = _dbMovieOutput;
@synthesize dbPreviewLayer = _dbPreviewLayer;
@synthesize camera_movieOutURL = _camera_movieOutURL;
@synthesize exportProgressTimer = _exportProgressTimer;
@synthesize camera_movieFolderURL = _camera_movieFolderURL;

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    [self.session beginConfiguration];
    if ( [self.session canAddInput:self.dbVideoInput] ) [self.session addInput:self.dbVideoInput];
    if ( [self.session canAddInput:self.dbAudioInput] ) [self.session addInput:self.dbAudioInput];
    if ( [self.session canAddOutput:self.dbMovieOutput] ) {
        [self.session addOutput:self.dbMovieOutput];
        AVCaptureConnection *videoConnection = [self.dbMovieOutput connectionWithMediaType:AVMediaTypeVideo];
        if ( videoConnection.isVideoStabilizationSupported ) {
            videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
    }
    [self.session commitConfiguration];
    
    [self.session startRunning];
    
    [self resetcamera_movieFolder];
    
    return self;
}

- (void)dealloc {
    if ( _session.isRunning ) [_session stopRunning];
    NSLog(@"%zd - %s", __LINE__, __func__);
}

// MARK: Public

- (CALayer *)previewLayer {
    if ( ![self.session isRunning] ) [self.session startRunning];
    return self.dbPreviewLayer;
}

// MARK: Private

// MARK: ------
/*!
 *  返回对应位置的 camera
 */
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)postion {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices ) {
        if ( device.position == postion ) return device;
    }
    return nil;
}

/*!
 *  返回当前活跃的 camera
 */
- (AVCaptureDevice *)activeCamera {
    return self.dbVideoInput.device;
}

/*!
 *  返回不活跃的 camera
 */
- (AVCaptureDevice *)inactiveCamera {
    AVCaptureDevice *device = nil;
    if ( self.cameraCount > 1 ) {
        if ( [self activeCamera].position == AVCaptureDevicePositionBack )
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        else
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
    }
    return device;
}

/*!
 *  可用 camera 数量
 */
- (NSUInteger)cameraCount {
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

/*!
 *  是否有超过 1个 摄像头可用
 */
- (BOOL)canSwitchCameras {
    return self.cameraCount > 1;
}

/*!
 *  是否支持对焦
 */
- (BOOL)cameraSupportsTapToFocus {
    return [[self activeCamera] isFocusPointOfInterestSupported];
}

/*!
 *  是否支持曝光
 */
- (BOOL)cameraSupportsTapToExpose {
    return [[self activeCamera] isExposurePointOfInterestSupported];
}

/*!
 *  视频输出路径
 */
- (NSURL *)camera_movieOutURL {
    if ( _camera_movieOutURL ) return _camera_movieOutURL;
    _camera_movieOutURL = [self.camera_movieFolderURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%03zd_db_camera_movie.mov", self.camera_movieRecordIndex]];
    self.camera_movieRecordIndex += 1;
    return _camera_movieOutURL;
}

- (void)resetcamera_movieFolder {
    // 重置记录索引
    self.camera_movieRecordIndex = 0;
    NSString *camera_movieFolderPathStr = [self.camera_movieFolderURL.absoluteString substringFromIndex:7];
    [[NSFileManager defaultManager] removeItemAtPath:camera_movieFolderPathStr error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:camera_movieFolderPathStr withIntermediateDirectories:YES attributes:nil error:nil];
}

- (NSURL *)camera_movieFolderURL {
    if ( _camera_movieFolderURL ) return _camera_movieFolderURL;
    _camera_movieFolderURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"db_camera_movies"];
    return _camera_movieFolderURL;
}

// MARK: ------


// MARK: ------

- (BOOL)cameraHasFlash {
    return [[self activeCamera] hasFlash];
}

- (AVCaptureFlashMode)flashMdoe {
    return [[self activeCamera] flashMode];
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode {
    AVCaptureDevice *device = [self activeCamera];
    
    if ( [device isFlashModeSupported:flashMode] ) {
        NSError *error;
        if ( [device lockForConfiguration:&error] ) {
            device.flashMode = flashMode;
            [device unlockForConfiguration];
        }
        else {
            if ( ![self.delegate respondsToSelector:@selector(deviceConfigurationFailedWithError:)] ) return;
            [self.delegate deviceConfigurationFailedWithError:error];
        }
    }
}

- (BOOL)camerahasTorch {
    return [[self activeCamera] hasTorch];
}

// MARK: ------


// MARK: Lazy

- (AVCaptureSession *)session {
    if ( _session ) return _session;
    _session = [AVCaptureSession new];
    return _session;
}

- (AVCaptureDevice *)dbVideoDevice {
    if ( _dbVideoDevice ) return _dbVideoDevice;
    _dbVideoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    return _dbVideoDevice;
}

- (AVCaptureDevice *)dbAudioDevice {
    if ( _dbAudioDevice ) return _dbAudioDevice;
    _dbAudioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    return _dbAudioDevice;
}

- (AVCaptureDeviceInput *)dbVideoInput {
    if ( _dbVideoInput ) return _dbVideoInput;
    _dbVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.dbVideoDevice error:NULL];
    return _dbVideoInput;
}

- (AVCaptureDeviceInput *)dbAudioInput {
    if ( _dbAudioInput ) return _dbAudioInput;
    _dbAudioInput = [AVCaptureDeviceInput deviceInputWithDevice:self.dbAudioDevice error:NULL];
    return _dbAudioInput;
}

- (AVCaptureMovieFileOutput *)dbMovieOutput {
    if ( _dbMovieOutput ) return  _dbMovieOutput;
    _dbMovieOutput = [AVCaptureMovieFileOutput new];
    return _dbMovieOutput;
}

- (AVCaptureVideoPreviewLayer *)dbPreviewLayer {
    if ( _dbPreviewLayer ) return _dbPreviewLayer;
    _dbPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _dbPreviewLayer.frame = [UIScreen mainScreen].bounds;
    return _dbPreviewLayer;
}

- (NSTimer *)exportProgressTimer {
    if ( _exportProgressTimer ) return _exportProgressTimer;
    __weak typeof(self) _self = self;
    void(^exportProgressBlock)() = ^{
        if ( ![_self.delegate respondsToSelector:@selector(session:exportProgress:)] ) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_self.delegate session:_self exportProgress:_self.stoppedExportSession.progress];
        });
    };
    _exportProgressTimer = [NSTimer sj_scheduledTimerWithTimeInterval:0.1 exeBlock:exportProgressBlock repeats:YES];
    return _exportProgressTimer;
}

@end





@interface SJRecordPreviewView : UIView

@property (nonatomic, assign, readwrite) BOOL tappedFocus;

- (instancetype)initWithSJRecordSession:(SJRecordVideoSession *)recordSession;

@end








@implementation SJRecordVideoSession (Preview)

- (UIView *)previewView {
    SJRecordPreviewView *previewView = objc_getAssociatedObject(self, _cmd);
    if ( previewView ) return previewView;
    previewView = [[SJRecordPreviewView alloc] initWithSJRecordSession:self];
    previewView.tappedFocus = YES;
    objc_setAssociatedObject(self, _cmd, previewView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return previewView;
}

- (void)setTappedFocus:(BOOL)tappedFocus {
    if ( self.tappedFocus == tappedFocus ) return;
    objc_setAssociatedObject(self, @selector(tappedFocus), @(tappedFocus), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [(SJRecordPreviewView *)self.previewView setTappedFocus:tappedFocus];
}

- (BOOL)tappedFocus {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end





















#import <AssetsLibrary/AssetsLibrary.h>

// MARK: Export Assets

@implementation SJRecordVideoSession (ExportAssets)

- (void)exportAssets:(AVAsset *)asset completionHandle:(void(^)(AVAsset *sandBoxAsset, UIImage *previewImage))block; {
    NSLog(@"%@", NSStringFromCGAffineTransform(asset.preferredTransform));
    [self exportAssets:asset presetName:AVAssetExportPresetMediumQuality completionHandle:block];
}

- (void)exportAssets:(AVAsset *)asset presetName:(NSString *)presetName completionHandle:(void(^)(AVAsset *sandBoxAsset, UIImage *previewImage))block {
    NSURL *exportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject URLByAppendingPathComponent:@"_re_.mp4"];
    if ( [[NSFileManager defaultManager] fileExistsAtPath:[exportURL.absoluteString substringFromIndex:7]] ) {
        [[NSFileManager defaultManager] removeItemAtURL:exportURL error:nil];
    }
    self.stoppedExportSession = [AVAssetExportSession exportSessionWithAsset:asset presetName:presetName];
    self.stoppedExportSession.outputURL = exportURL;
    self.stoppedExportSession.outputFileType = AVFileTypeMPEG4;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.exportProgressTimer fire];
    });
    
    __weak typeof(self) _self = self;
    [self.stoppedExportSession exportAsynchronouslyWithCompletionHandler:^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.stoppedExportSession.status == AVAssetExportSessionStatusCancelled ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 删除定时器
                [_exportProgressTimer invalidate];
                _exportProgressTimer = nil;
            });
            return;
        }
        
        [self thumbnailForVideoAtURL:exportURL atTime:kCMTimeZero generatedImage:^(UIImage *image) {
            [self resetcamera_movieFolder];
            AVAsset *asset = [AVAsset assetWithURL:exportURL];
            asset.assetURL = exportURL;
            dispatch_async(dispatch_get_main_queue(), ^{
                if ( block ) block(asset, image);
                // 删除定时器
                [_exportProgressTimer invalidate];
                _exportProgressTimer = nil;
            });
        }];
    }];
}

/*!
 *  @parma  duration    unit is sec.
 *  @parma  diraction   1 is Portrait, 0 is Landscape.
 */
- (void)exportAssets:(AVAsset *)asset maxDuration:(NSInteger)duration direction:(short)direction completionHandle:(void(^)(AVAsset *sandBoxAsset, UIImage *previewImage))block; {
    [self exportAssets:asset presetName:AVAssetExportPresetMediumQuality maxDuration:duration direction:direction completionHandle:block];
}

- (void)exportAssets:(AVAsset *)asset presetName:(NSString *)presetName maxDuration:(NSInteger)duration direction:(short)direction completionHandle:(void (^)(AVAsset *, UIImage *))block {

    NSInteger sourceDuration = asset.duration.value / asset.duration.timescale;
    if ( sourceDuration < duration ) {
        [self exportAssets:asset completionHandle:block];
        return;
    }
    
    AVMutableComposition *compositionM = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *audioTrackM = [compositionM addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *videoTrackM = [compositionM addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    if ( 1 >= direction ) videoTrackM.preferredTransform = CGAffineTransformMakeRotation(M_PI_2);
    
    CMTimeRange cutRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(duration, 1));
    
    AVAssetTrack *assetAudioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    AVAssetTrack *assetVideoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    
    NSError *error;
    [audioTrackM insertTimeRange:cutRange ofTrack:assetAudioTrack atTime:kCMTimeZero error:&error];
    if ( error ) {
        NSLog(@"裁剪出错 error = %@", error);
        return;
    }
    [videoTrackM insertTimeRange:cutRange ofTrack:assetVideoTrack atTime:kCMTimeZero error:&error];
    if ( error ) {
        NSLog(@"裁剪出错 error = %@", error);
        return;
    }
    
    [self exportAssets:compositionM presetName:presetName completionHandle:block];
}

/*!
 *  cancelExport
 */
- (void)cancelExport {
    [self.stoppedExportSession cancelExport];
    if ( ![self.delegate respondsToSelector:@selector(cancelExportWithSession:)] ) return;
    [self.delegate cancelExportWithSession:self];
}

@end


NSNotificationName const ThumbnailNotification = @"ThumbnailNotification";

@implementation SJRecordVideoSession (AVCaptureFileOutputRecordingDelegateMethods)

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    
    if ( error ) {
        NSLog(@"录制报错 : %@", error);
        if ( ![self.delegate respondsToSelector:@selector(mediaCaptureFaieldWithError:)] ) return;
        [self.delegate mediaCaptureFaieldWithError:error];
    }
    else {
        if ( !self.isStopRecord ) {
            if ( _pausedCallBlock ) _pausedCallBlock();
            _pausedCallBlock = nil;
        }
        
        // 合成操作
        if ( self.isStopRecord )  {
            [self compoundRecordsMedia];
        }
    }
    /*!
     *  清空操作
     */
    _camera_movieOutURL = nil;
}

- (void)compoundRecordsMedia {
    NSString *camera_movieFolderPathStr = [_camera_movieFolderURL.absoluteString substringFromIndex:7];
    NSArray<NSString *> *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:camera_movieFolderPathStr error:nil];
    
    // 文件排序
    NSStringCompareOptions comparisonOptions = NSNumericSearch;
    NSArray<NSString *> *resultArr = [items sortedArrayUsingComparator:^NSComparisonResult(NSString * _Nonnull obj1, NSString * _Nonnull obj2) {
        NSRange range = NSMakeRange(0, obj1.length);
        return [obj1 compare:obj2 options:comparisonOptions range:range];
    }];
    
    // 合成操作
    AVMutableComposition *compositionM = [AVMutableComposition composition];
    //            compositionM.naturalSize = CGSizeMake(540, 960);
    
    // video track
    AVMutableCompositionTrack *videoTrackM = [compositionM addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    // audio track
    AVMutableCompositionTrack *audioTrackM = [compositionM addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    // 考虑:
    // 1. 屏幕方向
    // 2. 摄像头方向
    CGAffineTransform preferredTransform = CGAffineTransformIdentity;
    AVCaptureDevicePosition cameraPosition = [self activeCamera].position;
    switch (_orientation ) {
        case AVCaptureVideoOrientationPortrait: {
            preferredTransform = CGAffineTransformMakeRotation(M_PI_2);
        }
            break;
        case AVCaptureVideoOrientationLandscapeLeft: {
            if ( cameraPosition == AVCaptureDevicePositionBack )
                preferredTransform = CGAffineTransformIdentity;
            else
                preferredTransform = CGAffineTransformMakeRotation(M_PI);
        }
            break;
        case AVCaptureVideoOrientationLandscapeRight: {
            if ( cameraPosition == AVCaptureDevicePositionBack )
                preferredTransform = CGAffineTransformMakeRotation(-M_PI);
            else
                preferredTransform = CGAffineTransformIdentity;
        }
            break;
        default:
            break;
    }
    
    videoTrackM.preferredTransform = preferredTransform;
    
    __block CMTime cursorTime = kCMTimeZero;
    
    for ( int i = 0 ; i < resultArr.count ; i ++ ) {
        NSURL *fileURL = [_camera_movieFolderURL URLByAppendingPathComponent:resultArr[i]];
        AVAsset *asset = [AVAsset assetWithURL:fileURL];
        
        // asset track
        AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        AVAssetTrack *audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
        
        // insert
        CMTimeRange range = CMTimeRangeMake(kCMTimeZero, asset.duration);
        NSError *error;
        [videoTrackM insertTimeRange:range ofTrack:videoTrack atTime:cursorTime error:&error];
        if ( error ) NSLog(@"A: error: %@", error);
        [audioTrackM insertTimeRange:range ofTrack:audioTrack atTime:cursorTime error:&error];
        if ( error ) NSLog(@"B: error: %@", error);
        
        cursorTime = compositionM.duration;
    }
    
    // 导出
    [self exportAssets:compositionM completionHandle:^(AVAsset *sandBoxAsset, UIImage *previewImage) {
        if ( _exportedCallBlock ) {
            _exportedCallBlock(sandBoxAsset, previewImage);
            _exportedCallBlock = nil;
        }
    }];
}

@end



// MARK: 录制

@implementation SJRecordVideoSession (Record)

/*!
 *  开始录制视频
 */
- (void)startRecordingWithOrientation:(AVCaptureVideoOrientation)orientation {
    
    self.orientation = orientation;
    
    AVCaptureConnection *videoConnection = [self.dbMovieOutput connectionWithMediaType:AVMediaTypeVideo];
    
    if ( [videoConnection isVideoOrientationSupported] ) {
        videoConnection.videoOrientation = orientation;
    }
    
    AVCaptureDevice *device = [self activeCamera];
    if ( device.isSmoothAutoFocusSupported ) {
        NSError *error;
        if ( [device lockForConfiguration:&error] ) {
            device.smoothAutoFocusEnabled = YES;
            [device unlockForConfiguration];
        }
        else {
            if ( ![self.delegate respondsToSelector:@selector(deviceConfigurationFailedWithError:)] ) return;
            [self.delegate deviceConfigurationFailedWithError:error];
            NSLog(@"start Error: %@", error);
        }
    }
    [self.dbMovieOutput startRecordingToOutputFileURL:self.camera_movieOutURL recordingDelegate:self];
}

/*!
 *  是否在录制
 */
- (BOOL)isRecording {
    return _dbMovieOutput.isRecording;
}

/*!
 *  完成录制视频
 */
- (void)stopRecordingAndComplate:(void(^)(AVAsset *asset, UIImage *coverImage))block {
    self.isStopRecord = YES;
    _exportedCallBlock = block;
    
    if ( [self isRecording] ) [self.dbMovieOutput stopRecording];
    else [self compoundRecordsMedia];
}

/*!
 *  暂停录制
 */
- (void)pauseRecordingAndComplete:(void (^)())block {
    if ( ![self isRecording] ) {
        if ( block ) block();
        return;
    }
    self.isStopRecord = NO;
    [self.dbMovieOutput stopRecording];
    _pausedCallBlock = block;
}

/*!
 *  恢复录制
 */
- (void)resumeRecording {
    [self startRecordingWithOrientation:self.orientation];
}

/*!
 *  重置录制
 */
- (void)resetRecordingAndCallBlock:(void(^)())block {
    [self pauseRecordingAndComplete:^{
        [self resetcamera_movieFolder];
        if ( block ) block();
    }];
}

/*!
 *  生成封面
 *  time is second
 */
- (void)thumbnailForVideoAtURL:(NSURL *)videoURL atTime:(CMTime)time generatedImage:(void(^)(UIImage *image))block {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        AVAsset *asset = [AVAsset assetWithURL:videoURL];
        AVAssetImageGenerator *imageGenerator =
        [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        imageGenerator.maximumSize = CGSizeMake(375, 0.0);
        imageGenerator.appliesPreferredTrackTransform = YES;
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:nil];
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( block ) block(image);
        });
    });
}

/*!
 *  批量生成封面
 */
+ (void)batchGeneratedImageAtURL:(NSURL *)videoURL interval:(short)interval completion:(void(^)(NSArray<UIImage *> *imageArr))block {
    [self batchGeneratedImageWithAsset:[AVAsset assetWithURL:videoURL] interval:interval completion:block];
}

/*!
 *  批量生成封面
 *  interval : 几秒钟截一次图
 */
+ (void)batchGeneratedImageWithAsset:(AVAsset *)asset interval:(short)interval completion:(void(^)(NSArray<UIImage *> *imageArr))block {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *arrM = [NSMutableArray new];
        AVAssetImageGenerator *imageGenerator =
        [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        AVAssetTrack *track = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        imageGenerator.maximumSize = CGSizeMake(track.naturalSize.width, 0.0);
        imageGenerator.appliesPreferredTrackTransform = YES;
        CMTime duration = asset.duration;
        NSInteger second = duration.value / duration.timescale;
        NSInteger count = second / interval;
        if ( 0 == count ) return;
        __block short time = 0;
        for ( int i = 0 ; i < count ; i ++ ) {
            CGImageRef imageRef = [imageGenerator copyCGImageAtTime:CMTimeMake(time, 1) actualTime:NULL error:nil];
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
            [arrM addObject:image];
            time += interval;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( block ) block(arrM.copy);
        });
    });
}
@end




// MARK: 摄像头

@implementation SJRecordVideoSession (Camera)

/*!
 *  切换摄像头
 */
- (BOOL)switchCameras {
    if ( ![self canSwitchCameras] ) return NO;
    [self resetcamera_movieFolder];
    NSError *error;
    AVCaptureDevice *inactiveVideoDevice = [self inactiveCamera];
    AVCaptureDeviceInput *inactiveVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:inactiveVideoDevice error:&error];
    
    if ( inactiveVideoInput ) {
        [self.session beginConfiguration];
        
        [self.session removeInput:_dbVideoInput];
        
        if ( [self.session canAddInput:inactiveVideoInput] ) {
            [self.session addInput:inactiveVideoInput];
            _dbVideoInput = inactiveVideoInput;
        }
        else {
            [self.session addInput:_dbVideoInput];
        }
        
        [self.session commitConfiguration];
    }
    else {
        if ( [self.delegate respondsToSelector:@selector(deviceConfigurationFailedWithError:)] ) [self.delegate deviceConfigurationFailedWithError:error];
        return NO;
    }
    return YES;
}

- (void)setCameraPosition:(AVCaptureDevicePosition)cameraPosition {
    if ( [self activeCamera].position == cameraPosition ) return;
    [self switchCameras];
}

- (AVCaptureDevicePosition)cameraPosition {
    return [self activeCamera].position;
}

@end





// MARK: 闪光灯

@implementation SJRecordVideoSession (Torch)

- (AVCaptureTorchMode)torchMode {
    return [[self activeCamera] torchMode];
}

- (void)setTorchMode:(AVCaptureTorchMode)torchMode {
    AVCaptureDevice *device = [self activeCamera];
    if ( [device isTorchModeSupported:torchMode] ) {
        NSError *error;
        if ( [device lockForConfiguration:&error] ) {
            device.torchMode = torchMode;
            [device unlockForConfiguration];
        }
        else {
            if ( ![self.delegate respondsToSelector:@selector(deviceConfigurationFailedWithError:)] ) return;
            [self.delegate deviceConfigurationFailedWithError:error];
        }
    }
}

@end





// MARK: 对焦 和 曝光

@interface SJRecordVideoSession (FocusAndExposure)

/*!
 *  曝光
 */
- (void)exposeAtPoint:(CGPoint)point;

/*!
 *  对焦
 */
- (void)focusAtPoint:(CGPoint)point;

/*!
 *  恢复自动对焦
 */
- (void)resetFocusAndExposureMode;

@end


@implementation SJRecordVideoSession (FocusAndExposure)

static const NSString *SJCameraAdjustingExposureContext;

- (void)exposeAtPoint:(CGPoint)point {
    AVCaptureDevice *device = [self activeCamera];
    
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    
    if ( [self cameraSupportsTapToExpose] &&
        [device isExposureModeSupported:exposureMode] ) {
        
        NSError *error;
        if ( [device lockForConfiguration:&error] ) {
            device.exposurePointOfInterest = point;
            device.exposureMode = exposureMode;
            
            if ( [device isExposureModeSupported:AVCaptureExposureModeLocked] ) {
                // 监听曝光何时完成
                [device addObserver:self
                         forKeyPath:@"adjustingExposure"
                            options:NSKeyValueObservingOptionNew context:&SJCameraAdjustingExposureContext];
            }
            
            [device unlockForConfiguration];
        }
        else {
            if ( ![self.delegate respondsToSelector:@selector(deviceConfigurationFailedWithError:)] ) return;
            [self.delegate deviceConfigurationFailedWithError:error];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ( context == &SJCameraAdjustingExposureContext ) {
        AVCaptureDevice *device = (AVCaptureDevice *)object;
        
        if ( !device.isAdjustingExposure && // 判断是否在调整曝光等级
            [device isExposureModeSupported:AVCaptureExposureModeLocked] ) {
            [object removeObserver:self forKeyPath:@"adjustingExposure" context:&SJCameraAdjustingExposureContext];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error;
                
                if ( [device lockForConfiguration:&error] ) {
                    device.exposureMode = AVCaptureExposureModeLocked;
                    [device unlockForConfiguration];
                }
                else {
                    if ( ![self.delegate respondsToSelector:@selector(deviceConfigurationFailedWithError:)] ) return;
                    [self.delegate deviceConfigurationFailedWithError:error];
                }
            });
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


- (void)focusAtPoint:(CGPoint)point {
    AVCaptureDevice *device = [self activeCamera];
    if ( [self cameraSupportsTapToFocus] &&
        [device isFocusModeSupported:AVCaptureFocusModeAutoFocus] ) {
        
        NSError *error;
        if ( [device lockForConfiguration:&error] ) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        }
        else {
            if ( ![self.delegate respondsToSelector:@selector(deviceConfigurationFailedWithError:)] ) return;
            [self.delegate deviceConfigurationFailedWithError:error];
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self resetFocusMode];
    });
}

- (void)resetFocusMode {
    AVCaptureDevice *device = [self activeCamera];
    AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;
    if ( device.focusMode == focusMode ) return;
    BOOL canResetFocus = [self cameraSupportsTapToFocus] && [device isFocusModeSupported:focusMode];
    if ( !canResetFocus ) return;
    
    CGPoint centerPoint = CGPointMake(0.5f, 0.5f);
    
    NSError *error;
    if ( [device lockForConfiguration:&error] ) {
        device.focusMode = focusMode;
        device.focusPointOfInterest = centerPoint;
    }
    else {
        if ( ![self.delegate respondsToSelector:@selector(deviceConfigurationFailedWithError:)] ) return;
        [self.delegate deviceConfigurationFailedWithError:error];
    }
}

- (void)resetExposureMode {
    AVCaptureDevice *device = [self activeCamera];
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    if ( device.exposureMode ==  exposureMode ) return;
    
    BOOL canResetExposure = [self cameraSupportsTapToExpose] && [device isExposureModeSupported:exposureMode];
    if ( !canResetExposure ) return;
    
    CGPoint centerPoint = CGPointMake(0.5f, 0.5f);
    NSError *error;
    if ( [device lockForConfiguration:&error] ) {
        device.exposureMode = exposureMode;
        device.exposurePointOfInterest = centerPoint;
        [device unlockForConfiguration];
    }
    else {
        if ( ![self.delegate respondsToSelector:@selector(deviceConfigurationFailedWithError:)] ) return;
        [self.delegate deviceConfigurationFailedWithError:error];
    }
}

- (void)resetFocusAndExposureMode {
    AVCaptureDevice *device = [self activeCamera];
    
    AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;
    BOOL canResetFocus = [self cameraSupportsTapToFocus] && [device isFocusModeSupported:focusMode];
    
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    BOOL canResetExposure = [self cameraSupportsTapToExpose] && [device isExposureModeSupported:exposureMode];
    
    CGPoint centerPoint = CGPointMake(0.5f, 0.5f);
    
    NSError *error;
    if ( [device lockForConfiguration:&error] ) {
        if ( canResetFocus ) {
            device.focusMode = focusMode;
            device.focusPointOfInterest = centerPoint;
        }
        
        if ( canResetExposure ) {
            device.exposureMode = exposureMode;
            device.exposurePointOfInterest = centerPoint;
            [device unlockForConfiguration];
        }
    }
    else {
        if ( ![self.delegate respondsToSelector:@selector(deviceConfigurationFailedWithError:)] ) return;
        [self.delegate deviceConfigurationFailedWithError:error];
    }
}

@end




@interface SJRecordPreviewView ()

/*!
 *  对焦
 */
@property (nonatomic, strong, readonly)  UITapGestureRecognizer *singleTap;

@property (nonatomic, weak,   readwrite) SJRecordVideoSession *recordSession;

@end

@implementation SJRecordPreviewView

@synthesize singleTap = _singleTap;

+ (Class)layerClass {
    return [AVCaptureVideoPreviewLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _SJRecordPreviewSetupView];
    [self _SJRecordPreviewViewAddTaps];
    return self;
}

- (instancetype)initWithSJRecordSession:(SJRecordVideoSession *)recordSession {
    self = [self initWithFrame:[UIScreen mainScreen].bounds];
    if ( !self ) return nil;
    self.recordSession = recordSession;
    if ( ![self.recordSession.session isRunning] ) [self.recordSession.session startRunning];
    [self setSession:self.recordSession.session];
    return self;
}

// MARK: Handle Tap

- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    NSLog(@"tapped");
    CGPoint point = [self captureDevicePointForPoint:[tap locationInView:tap.view]];
    [self.recordSession focusAtPoint:point];
}

- (void)_SJRecordPreviewViewAddTaps {
    [self addGestureRecognizer:self.singleTap];
    
}

// MARK: Setter

- (void)setSession:(AVCaptureSession *)session {
    [(AVCaptureVideoPreviewLayer *)self.layer setSession:session];
}

- (void)setTappedFocus:(BOOL)tappedFocus {
    if ( _tappedFocus == tappedFocus ) return;
    _tappedFocus = tappedFocus;
    _singleTap.enabled = tappedFocus;
}

// MARK: UI

- (void)_SJRecordPreviewSetupView {
    [(AVCaptureVideoPreviewLayer *)self.layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
}

// MARK: Lazy

- (UITapGestureRecognizer *)singleTap {
    if ( _singleTap ) return _singleTap;
    _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    return _singleTap;
}

// MARK: Point

- (CGPoint)captureDevicePointForPoint:(CGPoint)point {
    AVCaptureVideoPreviewLayer *layer =
    (AVCaptureVideoPreviewLayer *)self.layer;
    return [layer captureDevicePointOfInterestForPoint:point];
}

@end

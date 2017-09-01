//
//  SJRecordVideoSession.h
//  SJRecordVideo
//
//  Created by BlueDancer on 2017/8/3.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AVAsset+Extension.h"

extern NSNotificationName const ThumbnailNotification;

@protocol SJRecordVideoSessionDelegate;

@interface SJRecordVideoSession : NSObject

- (instancetype)init;

@property (nonatomic, weak) id <SJRecordVideoSessionDelegate> delegate;

@end


@interface SJRecordVideoSession (Preview)

/*!
 *  frame default is [UIScreen mainScreen].bounds
 */
@property (nonatomic, strong, readonly) UIView *previewView;

/*!
 *  开启对焦
 *  default is YES
 */
@property (nonatomic, assign, readwrite) BOOL tappedFocus;

@end



@protocol SJRecordVideoSessionDelegate <NSObject>

@optional

- (void)deviceConfigurationFailedWithError:(NSError *)error;

- (void)mediaCaptureFaieldWithError:(NSError *)error;

- (void)session:(SJRecordVideoSession *)session exportProgress:(CGFloat)progress;

/*!
 *  导出被取消
 */
- (void)cancelExportWithSession:(SJRecordVideoSession *)session;

@end




// MARK: Export Assets

@interface SJRecordVideoSession (ExportAssets)

/*!
 *  presetName default is AVAssetExportPresetMediumQuality;
 */
- (void)exportAssets:(AVAsset *)asset completionHandle:(void(^)(AVAsset *sandBoxAsset, UIImage *previewImage))block;

- (void)exportAssets:(AVAsset *)asset presetName:(NSString *)presetName completionHandle:(void(^)(AVAsset *sandBoxAsset, UIImage *previewImage))block;

/*!
 *  @parma  duration    unit is sec.
 *  @parma  diraction   1 is Portrait, 0 is Landscape.
 *  presetName default is AVAssetExportPresetMediumQuality;
 */
- (void)exportAssets:(AVAsset *)asset maxDuration:(NSInteger)duration direction:(short)direction completionHandle:(void(^)(AVAsset *sandBoxAsset, UIImage *previewImage))block;

- (void)exportAssets:(AVAsset *)asset presetName:(NSString *)presetName maxDuration:(NSInteger)duration direction:(short)direction completionHandle:(void (^)(AVAsset *sandBoxAsset, UIImage *previewImage))block;

/*!
 *  cancelExport
 */
- (void)cancelExport;

@end










// MARK: 录制

@interface SJRecordVideoSession (Record)

/*!
 *  开始录制视频
 */
- (void)startRecordingWithOrientation:(AVCaptureVideoOrientation)orientation;

/*!
 *  是否在录制
 */
@property (nonatomic, assign, readonly) BOOL isRecording;

/*!
 *  完成录制视频
 */
- (void)stopRecordingAndComplate:(void(^)(AVAsset *sandboxAsset, UIImage *coverImage))block;

/*!
 *  暂停录制
 */
- (void)pauseRecordingAndComplete:(void(^)())block;

/*!
 *  恢复录制
 */
- (void)resumeRecording;

/*!
 *  重置录制
 */
- (void)resetRecordingAndCallBlock:(void(^)())block;

/*!
 *  生成封面
 */
- (void)thumbnailForVideoAtURL:(NSURL *)videoURL atTime:(CMTime)time generatedImage:(void(^)(UIImage *image))block;

/*!
 *  批量生成封面
 *  interval : 几秒钟截一次图
 */
+ (void)batchGeneratedImageAtURL:(NSURL *)videoURL interval:(short)interval completion:(void(^)(NSArray<UIImage *> *imageArr))block;

/*!
 *  批量生成封面
 *  interval : 几秒钟截一次图
 */
+ (void)batchGeneratedImageWithAsset:(AVAsset *)asset interval:(short)interval completion:(void(^)(NSArray<UIImage *> *imageArr))block;

@end



// MARK: 摄像头

@interface SJRecordVideoSession (Camera)

/*!
 *  转换摄像头
 */
- (BOOL)switchCameras;

/*!
 *  摄像头位置
 */
@property (nonatomic, assign, readwrite) AVCaptureDevicePosition cameraPosition;


@end


// MARK: 闪光灯

@interface SJRecordVideoSession (Torch)

/*!
 *  调整闪光灯 和 手电筒模式
 *  摄像机背面的LED灯
 *      当拍摄静态图片时作为闪光灯 flash
 *      当拍摄视频时作为手电筒 torch
 *  - (void)setFlashMode:(AVCaptureFlashMode)flashMode;
 */
@property (nonatomic, assign, readwrite) AVCaptureTorchMode torchMode;

@end


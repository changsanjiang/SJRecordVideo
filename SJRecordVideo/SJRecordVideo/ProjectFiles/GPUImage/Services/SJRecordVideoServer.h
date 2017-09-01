//
//  SJRecordVideoServer.h
//  SJRecordVideo
//
//  Created by BlueDancer on 2017/9/1.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIDevice.h>

@class UIView, AVAsset, UIImage;

@interface SJRecordVideoServer : NSObject

- (instancetype)init;

@end



@interface SJRecordVideoServer (Preview)

/*!
 *  frame default is [UIScreen mainScreen].bounds
 */
@property (nonatomic, strong, readonly) UIView *previewView;


@end



@interface SJRecordVideoServer (Record)

/*!
 *  开始录制视频
 */
- (void)startRecordingWithOrientation:(UIDeviceOrientation)orientation;

/*!
 *  完成录制视频
 */
- (void)stopRecordingAndComplate:(void(^)(AVAsset *sandboxAsset, UIImage *coverImage))block;

@end

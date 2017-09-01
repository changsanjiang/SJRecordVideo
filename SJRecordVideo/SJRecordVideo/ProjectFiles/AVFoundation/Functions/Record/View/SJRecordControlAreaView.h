//
//  SJRecordControlAreaView.h
//  SJRecordVideo
//
//  Created by BlueDancer on 2017/8/3.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SJRecordControlAreaViewBtnTag) {
    SJRecordControlAreaViewBtnTagRecord,
    SJRecordControlAreaViewBtnTagLocal,
    SJRecordControlAreaViewBtnTagEnd,
    SJRecordControlAreaViewBtnTagDel,
};


@protocol SJRecordControlAreaViewDelegate;


NS_ASSUME_NONNULL_BEGIN

@interface SJRecordControlAreaView : UIView

@property (nonatomic, weak,   readwrite) id <SJRecordControlAreaViewDelegate> delegate;

/*!
 *  已录制的时长
 */
@property (nonatomic, assign, readonly) NSInteger recordedDuration;

/*!
 *  重置录制时间
 */
- (void)resetDuration;

/*!
 *  最小录制时间. 单位 秒
 *  if you set its(minDuration and maxDuration), you must call updateRecordFlagLocation method.
 */
@property (nonatomic, assign, readwrite) NSInteger minDuration;
@property (nonatomic, assign, readwrite) NSInteger maxDuration;

/*!
 *  设置完最小值/最大值之后, 需要调用此方法进行UI更新操作
 */
- (void)updateRecordFlagLocation;

/*!
 *  录制按钮启用或关闭
 *  可以在录制结束后, 转码过程中禁用录制按钮, 防止继续录制. 转码结束后开启录制按钮.
 *  default is YES
 */
@property (nonatomic, assign, readwrite) BOOL enableRecordBtn;

/*!
 *  是否在录制
 *  如果在录制, 按钮将显示录制中图片, 否则则是开启录制图片.
 *  default is NO
 */
@property (nonatomic, assign, readwrite) BOOL isRecording;

/*!
 *  设置当前屏幕的方向, 来呈现不同的视图位置或者动画
 */
@property (nonatomic, assign, readwrite) UIDeviceOrientation recordingOrientation;


@end


@protocol SJRecordControlAreaViewDelegate <NSObject>

@optional
- (void)areaView:(SJRecordControlAreaView *)view clickedBtnTag:(SJRecordControlAreaViewBtnTag)tag;

- (void)arrivedMinDurationAreaView:(SJRecordControlAreaView *)view;

- (void)arrivedMaxDurationAreaView:(SJRecordControlAreaView *)view;

@end





@interface SJRecordControlAreaView (SJSelectTimeMode)

/*!
 *  default is NO.
 */
@property (nonatomic, assign, readwrite, getter=isShowSelectTimeView) BOOL showSelectTimeView;
@property (nonatomic, strong, readwrite, nullable) NSString *selectTimeTitle1;
@property (nonatomic, strong, readwrite, nullable) NSString *selectTimeTitle2;

@property (nonatomic, copy, readwrite, nullable) void(^exeSelectTime1Block)();
@property (nonatomic, copy, readwrite, nullable) void(^exeSelectTime2Block)();

/*!
 *  0 or 1.
 *  0 is selectedTime1.
 *  1 is selectedTime2.
 */
@property (nonatomic, assign, readonly) short selectedIndex;

@end

NS_ASSUME_NONNULL_END

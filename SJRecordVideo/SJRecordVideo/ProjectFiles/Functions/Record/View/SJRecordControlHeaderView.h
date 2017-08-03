//
//  SJRecordControlHeaderView.h
//  SJRecordVideo
//
//  Created by BlueDancer on 2017/8/3.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SJRecordControlHeaderViewBtnTag) {
    SJRecordControlHeaderViewBtnTagClose,
    SJRecordControlHeaderViewBtnTagTorch,
    SJRecordControlHeaderViewBtnTagCaptureDirection,
};

@protocol SJRecordControlHeaderViewDelegeta;



@interface SJRecordControlHeaderView : UIView

@property (nonatomic, weak,   readwrite) id <SJRecordControlHeaderViewDelegeta> delegate;

@property (nonatomic, assign, readwrite) UIDeviceOrientation recordingOrientation;

@property (nonatomic, assign, readwrite) BOOL torchSwitch;

@property (nonatomic, assign, readwrite) BOOL hiddenTorch;

@property (nonatomic, assign, readwrite) BOOL hiddenCapture;

@end



@protocol SJRecordControlHeaderViewDelegeta <NSObject>

- (void)headerView:(SJRecordControlHeaderView *)view clickedBtnTag:(SJRecordControlHeaderViewBtnTag)tag;

@end

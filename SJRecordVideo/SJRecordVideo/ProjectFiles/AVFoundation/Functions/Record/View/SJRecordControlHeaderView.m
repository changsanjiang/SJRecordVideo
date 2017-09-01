//
//  SJRecordControlHeaderView.m
//  SJRecordVideo
//
//  Created by BlueDancer on 2017/8/3.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJRecordControlHeaderView.h"

#import "UIView+Extension.h"

#import <Masonry.h>

#import "SJRecordVideoSource.h"

@interface SJRecordControlHeaderView ()

@property (nonatomic, strong, readonly) UIButton *closeBtn;
@property (nonatomic, strong, readonly) UIButton *torchBtn;
@property (nonatomic, strong, readonly) UIButton *captureDirectionBtn;

@end

@implementation SJRecordControlHeaderView

@synthesize closeBtn = _closeBtn;
@synthesize torchBtn = _torchBtn;
@synthesize captureDirectionBtn = _captureDirectionBtn;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _SJRecordControlHeaderViewSetupUI];
    return self;
}

// MARK: Setter

- (void)setTorchSwitch:(BOOL)torchSwitch {
    if ( _torchSwitch == torchSwitch ) return;
    _torchSwitch = torchSwitch;
    _torchBtn.selected = torchSwitch;
}

- (void)setHiddenTorch:(BOOL)hiddenTorch {
    if ( _hiddenTorch == hiddenTorch ) return;
    _hiddenTorch = hiddenTorch;
    CGFloat alpha = 0.001;
    if ( _hiddenTorch ) alpha = 0.001;
    else alpha = 1;
    [UIView animateWithDuration:0.25 animations:^{
        self.torchBtn.alpha = alpha;
    }];
}

- (void)setHiddenCapture:(BOOL)hiddenCapture {
    if ( _hiddenCapture == hiddenCapture ) return;
    _hiddenCapture = hiddenCapture;
    CGFloat alpha = 0.001;
    if ( _hiddenCapture ) alpha = 0.001;
    else alpha = 1;
    [UIView animateWithDuration:0.25 animations:^{
        self.captureDirectionBtn.alpha = alpha;
    }];
}

- (void)setRecordingOrientation:(UIDeviceOrientation)recordingOrientation {
    if ( _recordingOrientation == recordingOrientation ) return;
    _recordingOrientation = recordingOrientation;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (recordingOrientation) {
        case UIDeviceOrientationFaceUp: {
            //            NSLog(@"屏幕朝上平躺");
        }
            break;
            
        case UIDeviceOrientationFaceDown: {
            //            NSLog(@"屏幕朝下平躺");
        }
            break;
            
        case UIDeviceOrientationUnknown: {
            //            NSLog(@"未知方向");
        }
            break;
            
        case UIDeviceOrientationLandscapeLeft: {
            //            NSLog(@"屏幕向左横置");
            transform = CGAffineTransformMakeRotation(M_PI_2);
        }
            break;
            
        case UIDeviceOrientationLandscapeRight: {
            //            NSLog(@"屏幕向右橫置");
            transform = CGAffineTransformMakeRotation(-M_PI_2);
        }
            break;
            
        case UIDeviceOrientationPortrait: {
            //            NSLog(@"屏幕直立");
            transform = CGAffineTransformIdentity;
        }
            break;
            
        case UIDeviceOrientationPortraitUpsideDown: {
            //            NSLog(@"屏幕直立，上下顛倒");
        }
            break;
            
        default: {
            //            NSLog(@"无法辨识");
        }
            break;
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.torchBtn.transform = transform;
        self.closeBtn.transform = transform;
        self.captureDirectionBtn.transform = transform;
    }];
}



// MARK: Actions

- (void)clickedBtn:(UIButton *)btn {
//    NSLog(@"clicked btn");
    if ( ![self.delegate respondsToSelector:@selector(headerView:clickedBtnTag:)] ) return;
    [self.delegate headerView:self clickedBtnTag:btn.tag];
}

// MARK: UI

- (void)_SJRecordControlHeaderViewSetupUI {

    self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5];

    [self addSubview:self.closeBtn];
    [self addSubview:self.torchBtn];
    [self addSubview:self.captureDirectionBtn];
    
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.offset(15);
        make.top.bottom.offset(0);
    }];
    
    [_torchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_closeBtn);
        make.trailing.equalTo(_captureDirectionBtn.mas_leading).offset(-20);
    }];
    
    [_captureDirectionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_closeBtn);
        make.trailing.offset(-15);
    }];
}

- (UIButton *)closeBtn {
    if ( _closeBtn ) return _closeBtn;
    _closeBtn = [UIButton buttonWithImageName:SJGetFileWithName(@"sj_record_video_close")
                                          tag:SJRecordControlHeaderViewBtnTagClose
                                       target:self sel:@selector(clickedBtn:)];
    return _closeBtn;
}

- (UIButton *)torchBtn {
    if ( _torchBtn ) return _torchBtn;
    _torchBtn = [UIButton buttonWithImageName:SJGetFileWithName(@"sj_record_video_torch_off")
                                          tag:SJRecordControlHeaderViewBtnTagTorch
                                       target:self sel:@selector(clickedBtn:)];
    [_torchBtn setImage:[UIImage imageNamed:SJGetFileWithName(@"sj_record_video_torch_on")] forState:UIControlStateSelected];
    return _torchBtn;
}

- (UIButton *)captureDirectionBtn {
    if ( _captureDirectionBtn ) return _captureDirectionBtn;
    _captureDirectionBtn = [UIButton buttonWithImageName:SJGetFileWithName(@"sj_record_video_capture_direction")
                                                     tag:SJRecordControlHeaderViewBtnTagCaptureDirection
                                                  target:self sel:@selector(clickedBtn:)];
    return _captureDirectionBtn;
}

@end

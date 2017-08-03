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

// MARK: Actions

- (void)clickedBtn:(UIButton *)btn {
    NSLog(@"clicked btn");
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
    [_torchBtn setImage:[UIImage imageNamed:@"sj_record_video_torch_on"] forState:UIControlStateSelected];
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

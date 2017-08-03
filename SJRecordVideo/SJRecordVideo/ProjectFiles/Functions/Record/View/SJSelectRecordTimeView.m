//
//  SJSelectRecordTimeView.m
//  SJRecordVideo
//
//  Created by BlueDancer on 2017/8/3.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJSelectRecordTimeView.h"

#import <Masonry.h>

#import "UIView+Extension.h"

@interface SJSelectRecordTimeView ()

@property (nonatomic, strong, readonly) UIView *roundView;
@property (nonatomic, strong, readonly) UIButton *secBtn;
@property (nonatomic, strong, readonly) UIButton *minBtn;

@end

@implementation SJSelectRecordTimeView

@synthesize roundView = _roundView;
@synthesize secBtn = _secBtn;
@synthesize minBtn = _minBtn;


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _SJSelectRecordTimeViewSetupUI];
    return self;
}

// MARK: Setter

- (void)setEnableBtn:(BOOL)enableBtn {
    _enableBtn = enableBtn;
    self.secBtn.enabled = enableBtn;
    self.minBtn.enabled = enableBtn;
}


// MARK: Actions

- (void)clickedBtn:(UIButton *)btn {
    NSLog(@"clicked btn");
    if ( _isRecordingOrPaused ) return;
    switch (btn.tag) {
            // 秒
        case 0: {
            [_secBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.offset(0);
                make.centerX.equalTo(_roundView);
            }];
            
            [_minBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.offset(0);
                make.leading.equalTo(_secBtn.mas_trailing).offset(8);
            }];
            if ( self.clickedSecBtnBlock ) self.clickedSecBtnBlock();
        }
            break;
            // 分钟
        case 1: {
            [_secBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.offset(0);
                make.trailing.equalTo(_minBtn.mas_leading).offset(-8);
            }];
            
            [_minBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.offset(0);
                make.centerX.equalTo(_roundView);
            }];
            if ( self.clickedMinBtnBlock ) self.clickedMinBtnBlock();
        }
            break;
        default:
            break;
    }
    [UIView animateWithDuration:0.25 animations:^{
        [self layoutIfNeeded];
    }];
}

// MARK: UI

- (void)_SJSelectRecordTimeViewSetupUI {
    [self addSubview:self.roundView];
    [_roundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(0);
        make.centerX.equalTo(self);
        make.size.mas_offset(CGSizeMake(5, 5));
    }];
    
    [self addSubview:self.secBtn];
    [self addSubview:self.minBtn];
    
    [_secBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.offset(0);
        make.centerX.equalTo(_roundView);
    }];
    
    [_minBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.offset(0);
        make.leading.equalTo(_secBtn.mas_trailing).offset(8);
    }];
}

- (UIView *)roundView {
    if ( _roundView ) return _roundView;
    _roundView = [UIView roundViewWithBackGroundColor:[UIColor redColor]];
    return _roundView;
}

- (UIButton *)secBtn {
    if ( _secBtn ) return _secBtn;
    _secBtn = [UIButton buttonWithTitle:@"15秒MV"
                             titleColor:[UIColor whiteColor]
                        backgroundColor:[UIColor clearColor]
                                    tag:0
                                 target:self
                                    sel:@selector(clickedBtn:)
                               fontSize:14];
    return _secBtn;
}

- (UIButton *)minBtn {
    if ( _minBtn ) return _minBtn;
    _minBtn = [UIButton buttonWithTitle:@"3分钟"
                             titleColor:[UIColor whiteColor]
                        backgroundColor:[UIColor clearColor]
                                    tag:1
                                 target:self
                                    sel:@selector(clickedBtn:)
                               fontSize:14];
    return _minBtn;
}

@end

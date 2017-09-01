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
@property (nonatomic, strong, readonly) UIButton *modeBtn1;
@property (nonatomic, strong, readonly) UIButton *modeBtn2;

@property (nonatomic, weak, readwrite) UIButton *noSelectBtn;

@end

@implementation SJSelectRecordTimeView

@synthesize roundView = _roundView;
@synthesize modeBtn1 = _modeBtn1;
@synthesize modeBtn2 = _modeBtn2;


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _SJSelectRecordTimeViewSetupUI];
    return self;
}

// MARK: Setter

- (void)setEnableBtns:(BOOL)enableBtns {
    _enableBtns = enableBtns;
    self.modeBtn1.enabled = enableBtns;
    self.modeBtn2.enabled = enableBtns;
    self.noSelectBtn.hidden = !enableBtns;
}

- (void)setBtn1Title:(NSString *)btn1Title {
    _btn1Title = btn1Title;
    [_modeBtn1 setTitle:btn1Title forState:UIControlStateNormal];
}

- (void)setBtn2Title:(NSString *)btn2Title {
    _btn2Title = btn2Title;
    [_modeBtn2 setTitle:btn2Title forState:UIControlStateNormal];
}

// MARK: Actions

- (void)clickedBtn:(UIButton *)btn {
    NSLog(@"clicked btn");
    switch (btn.tag) {
            // 秒
        case 0: {
            [_modeBtn1 mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.offset(0);
                make.centerX.equalTo(_roundView);
            }];
            
            [_modeBtn2 mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.offset(0);
                make.leading.equalTo(_modeBtn1.mas_trailing).offset(8);
            }];
            if ( self.clickedBtn1Block ) self.clickedBtn1Block();
            self.noSelectBtn = _modeBtn2;
        }
            break;
            // 分钟
        case 1: {
            [_modeBtn1 mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.offset(0);
                make.trailing.equalTo(_modeBtn2.mas_leading).offset(-8);
            }];
            
            [_modeBtn2 mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.offset(0);
                make.centerX.equalTo(_roundView);
            }];
            if ( self.clickedBtn2Block ) self.clickedBtn2Block();
            self.noSelectBtn = _modeBtn1;
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
    
    [self addSubview:self.modeBtn1];
    [self addSubview:self.modeBtn2];
    
    [_modeBtn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.offset(0);
        make.centerX.equalTo(_roundView);
    }];
    
    [_modeBtn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.offset(0);
        make.leading.equalTo(_modeBtn1.mas_trailing).offset(8);
    }];
    
    self.noSelectBtn = _modeBtn2;
}

- (UIView *)roundView {
    if ( _roundView ) return _roundView;
    _roundView = [UIView roundViewWithBackGroundColor:[UIColor redColor]];
    return _roundView;
}

- (UIButton *)modeBtn1 {
    if ( _modeBtn1 ) return _modeBtn1;
    _modeBtn1 = [UIButton buttonWithTitle:@""
                             titleColor:[UIColor whiteColor]
                        backgroundColor:[UIColor clearColor]
                                    tag:0
                                 target:self
                                    sel:@selector(clickedBtn:)
                               fontSize:14];
    return _modeBtn1;
}

- (UIButton *)modeBtn2 {
    if ( _modeBtn2 ) return _modeBtn2;
    _modeBtn2 = [UIButton buttonWithTitle:@""
                             titleColor:[UIColor whiteColor]
                        backgroundColor:[UIColor clearColor]
                                    tag:1
                                 target:self
                                    sel:@selector(clickedBtn:)
                               fontSize:14];
    return _modeBtn2;
}

@end

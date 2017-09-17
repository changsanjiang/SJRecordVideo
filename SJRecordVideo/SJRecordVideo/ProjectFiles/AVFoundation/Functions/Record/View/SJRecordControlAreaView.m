//
//  SJRecordControlAreaView.m
//  SJRecordVideo
//
//  Created by BlueDancer on 2017/8/3.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJRecordControlAreaView.h"

#import "NSTimer+Extension.h"

#import "SJSelectRecordTimeView.h"

#import <Masonry.h>

#import <objc/message.h>

#import "UIView+Extension.h"

#import "SJRecordVideoSource.h"

// MARK: 观察处理

@interface SJRecordControlAreaView (DBObservers)

- (void)_SJRecordControlAreaViewObservers;

- (void)_SJRecordControlAreaViewRemoveObservers;

@end

@interface SJRecordControlAreaView ()

@property (nonatomic, strong, readonly) UIProgressView *durationProgressView;
@property (nonatomic, strong, readonly) UIView *flagView;
@property (nonatomic, strong, readonly) UIButton *recordBtn;
@property (nonatomic, strong, readonly) UILabel *durationLabel;
@property (nonatomic, strong, readonly) UIButton *localVideoBtn;
@property (nonatomic, strong, readonly) UIButton *completeBtn;
@property (nonatomic, strong, readonly) UIButton *deleteBtn;
@property (nonatomic, strong, readonly) SJSelectRecordTimeView *selectRecordTimeView;

@property (nonatomic, strong, readonly) NSTimer *observeTimer;
@property (nonatomic, assign, readwrite) NSTimeInterval rec;

@end

@implementation SJRecordControlAreaView

@synthesize durationProgressView = _durationProgressView;
@synthesize recordBtn = _recordBtn;
@synthesize durationLabel = _durationLabel;
@synthesize flagView = _flagView;
@synthesize localVideoBtn = _localVideoBtn;
@synthesize completeBtn = _completeBtn;
@synthesize deleteBtn = _deleteBtn;
@synthesize selectRecordTimeView = _selectRecordTimeView;
@synthesize observeTimer = _observeTimer;


// MARK: 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _SJRecordControlAreaViewSetupUI];
    self.enableRecordBtn = YES;
    [self _SJRecordControlAreaViewObservers];
    self.minDuration = 5;
    self.maxDuration = 15;
    [self updateRecordFlagLocation];
    return self;
}

- (void)dealloc {
    [self _SJRecordControlAreaViewRemoveObservers];
}

// MARK: Setter

- (void)setIsRecording:(BOOL)isRecording {
    _isRecording = isRecording;
    
    // 开始录制
    if ( _isRecording ) {
        NSLog(@"开始录制");
        [self.observeTimer fire];
    }
    // 结束录制
    else {
        NSLog(@"结束录制");
        [_observeTimer invalidate];
        _observeTimer = nil;
    }
    
    self.recordBtn.selected = isRecording;
}

- (void)setRecordingOrientation:(UIDeviceOrientation)recordingOrientation {
    _recordingOrientation = recordingOrientation;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (_recordingOrientation) {
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
            [_durationLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.mas_trailing).offset(-12);
                make.centerY.equalTo(self);
            }];
            [_selectRecordTimeView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(self);
                make.centerY.equalTo(self);
                make.centerX.equalTo(self.mas_leading).offset(35/2 + 8);
                make.height.offset(35);
            }];
            transform = CGAffineTransformMakeRotation(M_PI_2);
        }
            break;
            
        case UIDeviceOrientationLandscapeRight: {
            //            NSLog(@"屏幕向右橫置");
            [_durationLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.mas_leading).offset(12);
                make.centerY.equalTo(self);
            }];
            [_selectRecordTimeView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(self);
                make.centerY.equalTo(self);
                make.centerX.equalTo(self.mas_trailing).offset(-(35/2 + 8));
                make.height.offset(35);
            }];
            transform = CGAffineTransformMakeRotation(-M_PI_2);
        }
            break;
            
        case UIDeviceOrientationPortrait: {
            //            NSLog(@"屏幕直立");
            [_durationLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(_durationProgressView.mas_bottom).offset(4);
            }];
            [_selectRecordTimeView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.offset(0);
                make.width.equalTo(self);
                make.centerX.equalTo(self);
                make.height.offset(35);
            }];
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
        _durationLabel.transform = transform;
        _selectRecordTimeView.transform = transform;
        _localVideoBtn.transform = transform;
        _completeBtn.transform = transform;
    }];
    [UIView animateWithDuration:0.25 animations:^{
        [self layoutIfNeeded];
    }];
}

// MARK: Getter

- (NSInteger)recordedDuration {
    return (NSInteger)_rec;
}


// MARK: Actions

- (void)clickedBtn:(UIButton *)btn {
    if ( ![self.delegate respondsToSelector:@selector(areaView:clickedBtnTag:)] ) return;
    [self.delegate areaView:self clickedBtnTag:btn.tag];
}

// MARK: Public

/*!
 *  重置录制时间
 */
- (void)resetDuration {
    self.rec = 0;
    _recordBtn.enabled = YES;
}

- (void)updateRecordFlagLocation {
    [_flagView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(1);
        make.top.bottom.equalTo(_durationProgressView);
        make.leading.offset(self.csj_w * ((self.minDuration * 1.0) / self.maxDuration));
    }];
}

// MARK: UI

- (void)_SJRecordControlAreaViewSetupUI {
    
    self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5];
    self.durationProgressView.trackTintColor = [UIColor colorWithWhite:1 alpha:0.2];
    self.durationProgressView.progressTintColor = [UIColor redColor];
    
    [self addSubview:self.durationProgressView];
    [self addSubview:self.recordBtn];
    [self addSubview:self.durationLabel];
    [self addSubview:self.flagView];
    [self addSubview:self.localVideoBtn];
    [self addSubview:self.completeBtn];
    [self addSubview:self.deleteBtn];
    [self addSubview:self.selectRecordTimeView];
    
    _completeBtn.alpha = 0.001;
    _deleteBtn.alpha = 0.001;
    _selectRecordTimeView.hidden = YES;
    
    [_durationProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.offset(0);
        make.height.offset(4);
    }];
    
    [_recordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    [_durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(_durationProgressView.mas_bottom).offset(4);
    }];
    
    [_flagView mas_makeConstraints:^(MASConstraintMaker *make) {
        
    }];
    
    [_localVideoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self).multipliedBy(1.6);
        make.centerY.equalTo(self);
    }];
    
    [_completeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_localVideoBtn);
    }];
    
    [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self).multipliedBy(0.4);
        make.centerY.equalTo(self);
    }];
    
    [_selectRecordTimeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(0);
        make.width.equalTo(self);
        make.centerX.equalTo(self);
        make.height.offset(35);
    }];
}

- (UIProgressView *)durationProgressView {
    if ( _durationProgressView ) return _durationProgressView;
    _durationProgressView = [UIProgressView new];
    return _durationProgressView;
}

- (UIButton *)recordBtn {
    if ( _recordBtn ) return _recordBtn;
    _recordBtn = [UIButton buttonWithImageName:SJGetFileWithName(@"sj_record_video_start")
                                           tag:SJRecordControlAreaViewBtnTagRecord
                                        target:self sel:@selector(clickedBtn:)];
    [_recordBtn setImage:[UIImage imageNamed:SJGetFileWithName(@"sj_record_video_pause")] forState:UIControlStateSelected];
    return _recordBtn;
}

- (UILabel *)durationLabel {
    if ( _durationLabel ) return _durationLabel;
    _durationLabel = [UILabel labelWithFontSize:12 textColor:[UIColor whiteColor]];
    _durationLabel.text = @"00:00";
    return _durationLabel;
}

- (UIView *)flagView {
    if ( _flagView ) return _flagView;
    _flagView = [UIView new];
    _flagView.backgroundColor = [UIColor greenColor];
    return _flagView;
}

- (UIButton *)localVideoBtn {
    if ( _localVideoBtn ) return _localVideoBtn;
    _localVideoBtn = [UIButton buttonWithImageName:SJGetFileWithName(@"sj_record_video_local")
                                               tag:SJRecordControlAreaViewBtnTagLocal
                                            target:self
                                               sel:@selector(clickedBtn:)];
    return _localVideoBtn;
}

- (UIButton *)completeBtn {
    if ( _completeBtn ) return _completeBtn;
    _completeBtn = [UIButton buttonWithImageName:SJGetFileWithName(@"sj_record_video_end")
                                             tag:SJRecordControlAreaViewBtnTagEnd
                                          target:self
                                             sel:@selector(clickedBtn:)];
    _completeBtn.backgroundColor = [UIColor clearColor];
    return _completeBtn;
}

- (UIButton *)deleteBtn {
    if ( _deleteBtn ) return _deleteBtn;
    _deleteBtn = [UIButton buttonWithImageName:SJGetFileWithName(@"sj_record_video_del")
                                           tag:SJRecordControlAreaViewBtnTagDel
                                        target:self
                                           sel:@selector(clickedBtn:)];
    _deleteBtn.backgroundColor = [UIColor clearColor];
    return _deleteBtn;
}

- (SJSelectRecordTimeView *)selectRecordTimeView {
    if ( _selectRecordTimeView ) return _selectRecordTimeView;
    _selectRecordTimeView = [SJSelectRecordTimeView new];
    return _selectRecordTimeView;
}

// MARK: Ovi

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateRecordFlagLocation];
}

// MARK: Lazy

- (NSTimer *)observeTimer {
    if ( _observeTimer ) return _observeTimer;
    __weak typeof(self) _self = self;
    void(^exeBlock)() = ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            _self.rec += 0.1;
        });
        
    };
    _observeTimer = [NSTimer sj_scheduledTimerWithTimeInterval:0.1 exeBlock:exeBlock repeats:YES];
    return _observeTimer;
}

@end



// MARK: Observers

@implementation SJRecordControlAreaView (DBObservers)


- (void)_SJRecordControlAreaViewObservers {
    [self addObserver:self forKeyPath:@"rec" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)_SJRecordControlAreaViewRemoveObservers {
    [self removeObserver:self forKeyPath:@"rec"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ( [keyPath isEqualToString:@"rec"] ) {
        
        _selectRecordTimeView.enableBtns = ( 0 == _rec );
        
        _completeBtn.enabled = ( _rec >= _minDuration );
        
        BOOL isRecordingOrPaused = ( 0 != _rec );
        CGFloat localAlpha = 0.001;
        CGFloat completeOrDeleteAlpha = 0.001;
        if ( isRecordingOrPaused ) {
            localAlpha = 0.001;
            completeOrDeleteAlpha = 1;
        }
        else {
            localAlpha = 1;
            completeOrDeleteAlpha = 0.001;
        }
        
        [UIView animateWithDuration:0.25 animations:^{
            _localVideoBtn.alpha = localAlpha;
            _completeBtn.alpha = completeOrDeleteAlpha;
            _deleteBtn.alpha = completeOrDeleteAlpha;
        }];
        
        // time
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.recordedDuration];
        
        self.durationLabel.text = [self.formatter stringFromDate:date];
        
        [self.durationProgressView setProgress:self.rec / self.maxDuration animated:YES];
        
        if ( self.recordedDuration == self.minDuration - 5 ) {
            if ( [self.delegate respondsToSelector:@selector(arrivedMinDurationAreaView:)] ) {
                [self.delegate arrivedMinDurationAreaView:self];
            }
        }
        if ( self.recordedDuration == self.maxDuration ) {
            if ( [self.delegate respondsToSelector:@selector(arrivedMaxDurationAreaView:)] ) {
                [self.delegate arrivedMaxDurationAreaView:self];
            }
            [_observeTimer invalidate];
            _observeTimer = nil;
        }
        
    }
}

- (NSDateFormatter *)formatter {
    NSDateFormatter *formatter = objc_getAssociatedObject(self, _cmd);
    if ( formatter ) return formatter;
    formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"mm:ss";
    return formatter;
}

@end





@implementation SJRecordControlAreaView (SJSelectTimeMode)

- (void)setShowSelectTimeView:(BOOL)showSelectTimeView {
    objc_setAssociatedObject(self, @selector(isShowSelectTimeView), @(showSelectTimeView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.selectRecordTimeView.hidden = !showSelectTimeView;
}

- (BOOL)isShowSelectTimeView {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setSelectTimeTitle1:(NSString *)selectTimeTitle1 {
    objc_setAssociatedObject(self, @selector(selectTimeTitle1), selectTimeTitle1, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.selectRecordTimeView.btn1Title = selectTimeTitle1;
}

- (NSString *)selectTimeTitle1 {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSelectTimeTitle2:(NSString *)selectTimeTitle2 {
    objc_setAssociatedObject(self, @selector(selectTimeTitle2), selectTimeTitle2, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.selectRecordTimeView.btn2Title = selectTimeTitle2;
}

- (NSString *)selectTimeTitle2 {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setExeSelectTime1Block:(void (^)())exeSelectTime1Block {
    if ( exeSelectTime1Block && self.exeSelectTime1Block != exeSelectTime1Block ) { exeSelectTime1Block();} // refresh first block
    objc_setAssociatedObject(self, @selector(exeSelectTime1Block), exeSelectTime1Block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    void(^block)() = [exeSelectTime1Block copy];
    __weak typeof(self) _self = self;
    self.selectRecordTimeView.clickedBtn1Block = ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( block ) block();
        self.selectedIndex = 0;
    };
}

- (void (^)())exeSelectTime1Block {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setExeSelectTime2Block:(void (^)())exeSelectTime2Block {
    objc_setAssociatedObject(self, @selector(exeSelectTime2Block), exeSelectTime2Block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    void(^block)() = [exeSelectTime2Block copy];
    __weak typeof(self) _self = self;
    self.selectRecordTimeView.clickedBtn2Block = ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( block ) block();
        self.selectedIndex = 1;
    };
}

- (void (^)())exeSelectTime2Block {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSelectedIndex:(short)selectedIndex {
    objc_setAssociatedObject(self, @selector(selectedIndex), @(selectedIndex), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (short)selectedIndex {
    return [objc_getAssociatedObject(self, _cmd) shortValue];
}

@end

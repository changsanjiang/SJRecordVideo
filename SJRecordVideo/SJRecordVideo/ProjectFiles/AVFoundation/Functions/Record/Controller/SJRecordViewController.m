//
//  SJRecordViewController.m
//  SJRecordVideo
//
//  Created by BlueDancer on 2017/8/3.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJRecordViewController.h"

#import <Masonry.h>

#import "SJRecordControlHeaderView.h"

#import "SJRecordControlAreaView.h"

#import "SJRecordVideoSession.h"

#import <SVProgressHUD.h>


#pragma mark -

@interface SJRecordViewController ()

@property (nonatomic, strong, readonly) SJRecordControlHeaderView *headerView;
@property (nonatomic, strong, readonly) SJRecordControlAreaView *areaView;
@property (nonatomic, strong, readonly) SJRecordVideoSession *session;

@property (nonatomic, assign, readwrite) BOOL isRecording;
@property (nonatomic, assign, readwrite) UIDeviceOrientation recordingOrientation;

@property (nonatomic, strong, readonly) UIView *fullMaskView;

@end


#pragma mark -

@interface SJRecordViewController (SJRecordVideoSessionDelegateMethods)<SJRecordVideoSessionDelegate>

@end

@implementation SJRecordViewController (SJRecordVideoSessionDelegateMethods)

// 导出进度
- (void)session:(SJRecordVideoSession *)session exportProgress:(CGFloat)progress {
    NSLog(@"exportProgress: %f", progress);
    if ( progress == 1 ) {[SVProgressHUD dismiss]; return;}
    [SVProgressHUD showProgress:progress status:@"正在导出.."];
}

- (void)cancelExportWithSession:(SJRecordVideoSession *)session {
    [SVProgressHUD dismiss];
}

@end


#pragma mark -

@interface SJRecordViewController (SJRecordControlAreaViewDelegateMethods)<SJRecordControlAreaViewDelegate>

@end

#import "SJRecordVideoEnumHeader.h"

#import "SJVideoInfoEditingViewController.h"

#import "SJSelectLovalVideoViewController.h"

@implementation SJRecordViewController (SJRecordControlAreaViewDelegateMethods)

- (void)areaView:(SJRecordControlAreaView *)view clickedBtnTag:(SJRecordControlAreaViewBtnTag)tag {
    switch (tag) {
            
            /*!
             *  点击 录制 按钮
             */
        case SJRecordControlAreaViewBtnTagRecord: {
            
            // 如果超过了设置的最长录制时间. return
            if ( self.areaView.recordedDuration >= self.areaView.maxDuration && !self.isRecording ) return;
            
            
            // notice observer method. 注意观察者方法
            self.isRecording = !self.isRecording;
        }
            break;
            
            /*!
             *  点击 ✅ 按钮
             */
        case SJRecordControlAreaViewBtnTagEnd: {
            
            // 是否超过了设置的最短时间. 否则 return.
            if ( self.areaView.recordedDuration < self.areaView.minDuration ) return;
            
            // 停止 并导出
            [self _stoppedAndExport];
            
        }
            break;
            
            /*!
             *  点击 ❌ 按钮
             */
        case SJRecordControlAreaViewBtnTagDel: {
            
            [self _stoppedAndCancel];
        }
            break;
            /*!
             *  点击 本地 按钮
             */
        case SJRecordControlAreaViewBtnTagLocal: {

            [self _jumpLocalVideo];
        }
            break;
    }
}


- (void)_stoppedAndExport {
    
    // stop
    [self _resetParameters];
    
    // export
    [SVProgressHUD showWithStatus:@"准备导出"];
    [self.view addSubview:self.fullMaskView];
    SJScreenOrientation direction = SJScreenOrientationLandscape;
    if ( self.recordingOrientation == UIDeviceOrientationPortrait ) {
        direction = SJScreenOrientationPortrait;
    }
    __weak typeof(self) _self = self;
    self.areaView.enableRecordBtn = NO;
    [self.session stopRecordingAndComplate:^(AVAsset *asset, UIImage *coverImage) {
        [SVProgressHUD dismiss];
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.fullMaskView removeFromSuperview];
        SJVideoInfoEditingViewController *vc = [[SJVideoInfoEditingViewController alloc] initWithAsset:asset direction:direction];
        vc.coverImage = coverImage;
        [self.navigationController pushViewController:vc animated:YES];
        self.areaView.enableRecordBtn = YES;
    }];
}

- (void)_stoppedAndCancel {
    
    // stop
    [self _resetParameters];
    
    [SVProgressHUD showWithStatus:@"正在取消"];
    [self.view addSubview:self.fullMaskView];
    
    // cancel
    __weak typeof(self) _self = self;
    [self.session resetRecordingAndCallBlock:^{
        [SVProgressHUD dismiss];
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self.fullMaskView removeFromSuperview];
    }];
}

- (void)_jumpLocalVideo {
    SJSelectLovalVideoViewController *vc = [[SJSelectLovalVideoViewController alloc] initWithSession:self.session];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)_resetParameters {
    [self.areaView resetDuration];
    self.recordingOrientation = UIDeviceOrientationPortrait;
    self.isRecording = NO;
}

// 录制到达设置的最高设置时间
- (void)arrivedMaxDurationAreaView:(SJRecordControlAreaView *)view {
    [self.session pauseRecordingAndComplete:^{
        self.isRecording = NO;
        self.areaView.enableRecordBtn = NO;
    }];
}

@end



@interface SJRecordViewController (SJRecordControlHeaderViewDelegetaMethods)<SJRecordControlHeaderViewDelegeta>

@end

// MARK: 通知处理

@interface SJRecordViewController (DBNotifications)

- (void)_SJRecordViewControllerInstallNotifications;

- (void)_SJRecordViewControllerRemoveNotifications;

@end



// MARK: 观察处理

@interface SJRecordViewController (DBObservers)

- (void)_SJRecordViewControllerObservers;

- (void)_SJRecordViewControllerRemoveObservers;

@end



#pragma mark -

@implementation SJRecordViewController

@synthesize fullMaskView = _fullMaskView;
@synthesize headerView = _headerView;
@synthesize areaView = _areaView;
@synthesize session = _session;

// MARK: 生命周期

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if ( !self ) return nil;
    [self _SJRecordViewControllerInstallNotifications];
    [self _SJRecordViewControllerObservers];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _sjSetupView];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    // 录制方向归位
    self.recordingOrientation = [UIDevice currentDevice].orientation;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)dealloc {
    [self _SJRecordViewControllerRemoveObservers];
    [self _SJRecordViewControllerRemoveNotifications];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}

// MARK: UI

- (void)_sjSetupView {
    
    [self.view addSubview:self.session.previewView];
    self.session.previewView.frame = self.view.bounds;
    
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.areaView];
    
    [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.offset(0);
        make.height.offset(64);
    }];
    [_areaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.offset(0);
        make.height.equalTo(self.view).multipliedBy(0.25);
    }];
    
    
    // MARK: Mix UI + Block Start target: AreaView
    
    // 开启选择模式
    _areaView.showSelectTimeView = YES;
    _areaView.selectTimeTitle1 = @"15秒MV";
    _areaView.selectTimeTitle2 = @"3分钟";
    
    __weak typeof(self) _self = self;
    _areaView.exeSelectTime1Block = ^{
        _self.areaView.minDuration = 5;
        _self.areaView.maxDuration = 15;
        // 设置完时间 更新一下标记位置
        [_self.areaView updateRecordFlagLocation];
    };
    
    _areaView.exeSelectTime2Block = ^{
        _self.areaView.maxDuration = 3 * 60;
        [_self.areaView updateRecordFlagLocation];
    };
    
    // MARK: Mix End

}

- (SJRecordControlHeaderView *)headerView {
    if ( _headerView ) return _headerView;
    _headerView = [SJRecordControlHeaderView new];
    _headerView.delegate = self;
    return _headerView;
}

- (SJRecordControlAreaView *)areaView {
    if ( _areaView ) return _areaView;
    _areaView = [SJRecordControlAreaView new];
    _areaView.delegate = self;
    return _areaView;
}

- (UIView *)fullMaskView {
    if ( _fullMaskView ) return _fullMaskView;
    _fullMaskView = [UIView new];
    _fullMaskView.backgroundColor = [UIColor clearColor];
    _fullMaskView.frame = [UIScreen mainScreen].bounds;
    return _fullMaskView;
}

// MARK: Status bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

// MARK: Lazy

- (SJRecordVideoSession *)session {
    if ( _session ) return _session;
    _session = [SJRecordVideoSession new];
    _session.delegate = self;
    return _session;
}


@end




@implementation SJRecordViewController (SJRecordControlHeaderViewDelegetaMethods)

- (void)headerView:(SJRecordControlHeaderView *)view clickedBtnTag:(SJRecordControlHeaderViewBtnTag)tag {
    switch (tag) {
        case SJRecordControlHeaderViewBtnTagClose: {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        case SJRecordControlHeaderViewBtnTagTorch: {
            if ( self.session.torchMode == AVCaptureTorchModeOn )
                self.session.torchMode = AVCaptureTorchModeOff;
            else
                self.session.torchMode = AVCaptureTorchModeOn;
            
            view.torchSwitch = (self.session.torchMode == AVCaptureTorchModeOn);
        }
            break;
        case SJRecordControlHeaderViewBtnTagCaptureDirection: {
            if ( [self.session switchCameras] ) {
                self.isRecording = NO;
                [self.areaView resetDuration];
            }
        }
            break;
        default:
            break;
    }
}

@end



// MARK: 通知处理

@implementation SJRecordViewController (DBNotifications)

- (void)_SJRecordViewControllerInstallNotifications {
    if (![UIDevice currentDevice].generatesDeviceOrientationNotifications) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceOrientationChange:)
                                                 name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)_SJRecordViewControllerRemoveNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleDeviceOrientationChange:(NSNotification *)notification {
    if ( _isRecording ) return;
    if ( _areaView.recordedDuration > 0 ) return;
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
    switch (orientation) {
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
            self.recordingOrientation = orientation;
        }
            break;
            
        case UIDeviceOrientationLandscapeRight: {
//            NSLog(@"屏幕向右橫置");
            self.recordingOrientation = orientation;
        }
            break;
            
        case UIDeviceOrientationPortrait: {
//            NSLog(@"屏幕直立");
            self.recordingOrientation = orientation;
        }
            break;
            
        case UIDeviceOrientationPortraitUpsideDown: {
//            NSLog(@"屏幕直立，上下顛倒");
        }
            break;
            
        default: {
            NSLog(@"无法辨识屏幕方向, 将有可能录制失败..");
        }
            break;
    }
}

@end




// MARK: Observers

@implementation SJRecordViewController (DBObservers)


- (void)_SJRecordViewControllerObservers {
    [self addObserver:self forKeyPath:@"isRecording" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"recordingOrientation" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)_SJRecordViewControllerRemoveObservers {
    [self removeObserver:self forKeyPath:@"isRecording"];
    [self removeObserver:self forKeyPath:@"recordingOrientation"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ( [keyPath isEqualToString:@"isRecording"] ) {
        self.areaView.isRecording = self.isRecording;
        
        // 录制中
        if ( _isRecording ) {
            self.headerView.hiddenTorch = YES;
            self.headerView.hiddenCapture = YES;
            // 开始录制
            if ( 0 == self.areaView.recordedDuration ) {
                // 确定录制方向
                AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationPortrait;
                switch (self.recordingOrientation) {
                    case UIDeviceOrientationLandscapeLeft:
                        orientation = AVCaptureVideoOrientationLandscapeLeft;
                        break;
                    case UIDeviceOrientationLandscapeRight:
                        orientation = AVCaptureVideoOrientationLandscapeRight;
                        break;
                    case UIDeviceOrientationPortrait:
                        orientation = AVCaptureVideoOrientationPortrait;
                        break;
                    default:
                        break;
                }
                [self.session startRecordingWithOrientation:orientation];
            }
            else [self.session resumeRecording];
        }
        
        // 暂停录制
        else {
            [self.session pauseRecordingAndComplete:nil];

            if ( 0 == self.areaView.recordedDuration ) {
                self.headerView.hiddenTorch = (self.session.cameraPosition == AVCaptureDevicePositionFront);
                self.headerView.hiddenCapture = NO;
            }
            else {
                self.headerView.hiddenTorch = YES;
                self.headerView.hiddenCapture = YES;
            }
        }
    }
    else if ( [keyPath isEqualToString:@"recordingOrientation"] ) {
        self.headerView.recordingOrientation = _recordingOrientation;
        self.areaView.recordingOrientation = _recordingOrientation;
    }
}

@end

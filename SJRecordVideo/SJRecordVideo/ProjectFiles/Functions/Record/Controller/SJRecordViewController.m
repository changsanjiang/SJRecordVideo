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


@interface SJRecordViewController (SJRecordVideoSessionDelegateMethods)<SJRecordVideoSessionDelegate>

@end


@interface SJRecordViewController (SJRecordControlAreaViewDelegateMethods)<SJRecordControlAreaViewDelegate>

@end


@interface SJRecordViewController (SJRecordControlHeaderViewDelegetaMethods)<SJRecordControlHeaderViewDelegeta>

@end

@interface SJRecordViewController ()

@property (nonatomic, strong, readonly) SJRecordControlHeaderView *headerView;
@property (nonatomic, strong, readonly) SJRecordControlAreaView *areaView;

@property (nonatomic, strong, readonly) SJRecordVideoSession *session;

@property (nonatomic, assign, readwrite) BOOL isRecording;
@property (nonatomic, assign, readwrite) UIDeviceOrientation recordingOrientation;

@end

@implementation SJRecordViewController

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
    
    [self _SJRecordViewControllerSetupUI];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
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

- (void)_SJRecordViewControllerSetupUI {
    
    [self.view.layer addSublayer:self.session.previewLayer];
    self.session.previewLayer.frame = self.view.bounds;
    
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
    
    _areaView.showSelectTimeView = YES;
    _areaView.selectTimeTitle1 = @"15秒MV";
    _areaView.selectTimeTitle2 = @"3分钟";
    
    __weak typeof(self) _self = self;
    _areaView.exeSelectTime1Block = ^{
        _self.areaView.minDuration = 5;
        _self.areaView.maxDuration = 15;
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

#import "SJRecordVideoEnumHeader.h"

#import "SJVideoInfoEditingViewController.h"

#import "SJSelectLovalVideoViewController.h"

@implementation SJRecordViewController (SJRecordControlAreaViewDelegateMethods)

- (void)areaView:(SJRecordControlAreaView *)view clickedBtnTag:(SJRecordControlAreaViewBtnTag)tag {
    switch (tag) {
        case SJRecordControlAreaViewBtnTagRecord: {
            if ( self.areaView.recordedDuration >= self.areaView.maxDuration && !self.isRecording ) return;
            if ( !self.isRecording ) {
                AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationPortrait;
                switch (_recordingOrientation) {
                    case UIDeviceOrientationLandscapeLeft: {
                        orientation = AVCaptureVideoOrientationLandscapeLeft;
                    }
                        break;
                        
                    case UIDeviceOrientationLandscapeRight: {
                        orientation = AVCaptureVideoOrientationLandscapeRight;
                    }
                        break;
                        
                    case UIDeviceOrientationPortrait: {
                        orientation = AVCaptureVideoOrientationPortrait;
                    }
                        break;
                    default:
                        break;
                }
                [self.session startRecordingWithOrientation:orientation];
                self.isRecording = YES;
            }
            else {
                [self.session pauseRecordingAndComplete:nil];
                self.isRecording = NO;
            }
        }
            break;
        case SJRecordControlAreaViewBtnTagEnd: {
            // stop
            if ( self.areaView.recordedDuration >= self.areaView.minDuration ) {
                __weak typeof(self) _self = self;
                self.areaView.enableRecordBtn = NO;
                [self.session stopRecordingAndComplate:^(AVAsset *asset, UIImage *coverImage) {
                    SJScreenOrientation direction = SJScreenOrientationLandscape;
                    if ( _recordingOrientation == UIDeviceOrientationPortrait ) {
                        direction = SJScreenOrientationPortrait;
                    }
                    SJVideoInfoEditingViewController *vc = [[SJVideoInfoEditingViewController alloc] initWithAsset:asset direction:direction];
                    vc.coverImage = coverImage;
                    [_self.navigationController pushViewController:vc animated:YES];
                    [_self.areaView resetDuration];
                    _self.areaView.enableRecordBtn = YES;
                    _self.isRecording = NO;
                }];
            }
        }
            break;
        case SJRecordControlAreaViewBtnTagLocal: {
            SJSelectLovalVideoViewController *vc = [[SJSelectLovalVideoViewController alloc] initWithSession:self.session];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case SJRecordControlAreaViewBtnTagDel: {
            __weak typeof(self) _self = self;
            [self.session resetRecordingAndCallBlock:^{
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                [self.areaView resetDuration];
                self.isRecording = NO;
            }];
        }
            break;
    }
}

- (void)arrivedMaxDurationAreaView:(SJRecordControlAreaView *)view {
    [self.session pauseRecordingAndComplete:^{
        self.isRecording = NO;
        self.areaView.enableRecordBtn = NO;
    }];
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
        if ( _isRecording ) {
            self.headerView.hiddenTorch = YES;
            self.headerView.hiddenCapture = YES;
        }
        else {
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







// MARK: 转码进度


@implementation SJRecordViewController (SJRecordVideoSessionDelegateMethods)

- (void)session:(SJRecordVideoSession *)session exportProgress:(CGFloat)progress {
    NSLog(@"exportProgress: %f", progress);
    if ( progress == 1 ) {[SVProgressHUD dismiss]; return;}
    [SVProgressHUD showProgress:progress status:@"正在导出.."];
}

- (void)cancelExportWithSession:(SJRecordVideoSession *)session {
    [SVProgressHUD dismiss];
}

@end

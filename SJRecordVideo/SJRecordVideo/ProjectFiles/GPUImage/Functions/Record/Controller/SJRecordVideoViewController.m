//
//  SJRecordVideoViewController.m
//  SJRecordVideo
//
//  Created by BlueDancer on 2017/9/1.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJRecordVideoViewController.h"

#import "UIView+Extension.h"

#import "SJRecordVideoServer.h"

#import "SJRecordControlAreaView.h"

#import "SJRecordControlHeaderView.h"

#import <Masonry.h>

@interface SJRecordVideoViewController (SJRecordControlAreaViewDelegateMethods)<SJRecordControlAreaViewDelegate> @end


@interface SJRecordVideoViewController (SJRecordControlHeaderViewDelegetaMethods)<SJRecordControlHeaderViewDelegeta> @end

@interface SJRecordVideoViewController ()

@property (nonatomic, strong, readonly) SJRecordVideoServer *recordServer;

@property (nonatomic, strong, readonly) SJRecordControlHeaderView *headerView;
@property (nonatomic, strong, readonly) SJRecordControlAreaView *areaView;

@end

@implementation SJRecordVideoViewController

@synthesize recordServer = _recordServer;
@synthesize headerView = _headerView;
@synthesize areaView = _areaView;


// MARK: 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _SJRecordVideoViewControllerSetupUI];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


// MARK: UI

- (void)_SJRecordVideoViewControllerSetupUI {
    [self.view addSubview:self.recordServer.previewView];
    self.recordServer.previewView.frame = self.view.bounds;
    
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
}

// MARK: Lazy

- (SJRecordVideoServer *)recordServer {
    if ( _recordServer )  return _recordServer;
    _recordServer = [SJRecordVideoServer new];
    return _recordServer;
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

@end



#import "SJRecordVideoEnumHeader.h"

#import "SJVideoInfoEditingViewController.h"

#import "SJSelectLovalVideoViewController.h"

@implementation SJRecordVideoViewController (SJRecordControlAreaViewDelegateMethods)

- (void)areaView:(SJRecordControlAreaView *)view clickedBtnTag:(SJRecordControlAreaViewBtnTag)tag {
    switch (tag) {
        case SJRecordControlAreaViewBtnTagRecord: {
            [self.recordServer startRecordingWithOrientation:0];
            view.isRecording = YES;
        }
            break;
        case SJRecordControlAreaViewBtnTagEnd: {
            [self.recordServer stopRecordingAndComplate:^(AVAsset *sandboxAsset, UIImage *coverImage) {
                
            }];
        }
            break;
        case SJRecordControlAreaViewBtnTagLocal: {

        }
            break;
        case SJRecordControlAreaViewBtnTagDel: {
            
        }
            break;
    }
}

- (void)resetParameters {
    [self.areaView resetDuration];
    
}

- (void)arrivedMaxDurationAreaView:(SJRecordControlAreaView *)view {
    
}

@end




@implementation SJRecordVideoViewController (SJRecordControlHeaderViewDelegetaMethods)

- (void)headerView:(SJRecordControlHeaderView *)view clickedBtnTag:(SJRecordControlHeaderViewBtnTag)tag {
    switch (tag) {
        case SJRecordControlHeaderViewBtnTagClose: {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        case SJRecordControlHeaderViewBtnTagTorch: {
            
        }
            break;
        case SJRecordControlHeaderViewBtnTagCaptureDirection: {
            
        }
            break;
        default:
            break;
    }
}

@end

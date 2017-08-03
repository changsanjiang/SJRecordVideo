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

@interface SJRecordViewController ()

@property (nonatomic, strong, readonly) SJRecordControlHeaderView *headerView;

@property (nonatomic, strong, readonly) SJRecordControlAreaView *areaView;

@end

@implementation SJRecordViewController

@synthesize headerView = _headerView;
@synthesize areaView = _areaView;

// MARK: 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _SJRecordViewControllerSetupUI];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

// MARK: UI

- (void)_SJRecordViewControllerSetupUI {
    
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
    return _headerView;
}

- (SJRecordControlAreaView *)areaView {
    if ( _areaView ) return _areaView;
    _areaView = [SJRecordControlAreaView new];
    return _areaView;
}

// MARK: Status bar

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end

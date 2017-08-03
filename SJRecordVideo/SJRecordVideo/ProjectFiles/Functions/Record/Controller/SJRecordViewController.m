//
//  SJRecordViewController.m
//  SJRecordVideo
//
//  Created by BlueDancer on 2017/8/3.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJRecordViewController.h"

#import "SJRecordControlView.h"

#import <Masonry.h>

@interface SJRecordViewController ()

@property (nonatomic, strong, readonly) SJRecordControlView *controlView;

@end

@implementation SJRecordViewController

@synthesize controlView = _controlView;

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
    
    [self.view addSubview:self.controlView];
    [_controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

- (SJRecordControlView *)controlView {
    if ( _controlView ) return _controlView;
    _controlView = [SJRecordControlView new];
    return _controlView;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end

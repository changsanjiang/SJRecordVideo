//
//  SJViewController.m
//  SJRecordVideo
//
//  Created by BlueDancer on 2017/8/3.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJViewController.h"

#import "UIView+Extension.h"

#import "SJRecordViewController.h"

#import "SJRecordNavigationController.h"

#import <SVProgressHUD.h>

#import "SJRecordVideoViewController.h"

@interface SJViewController ()

@property (nonatomic, strong, readonly) UIButton *centerBtn;

@property (nonatomic, strong, readonly) UIButton *GPUImageBtn;

@end

@implementation SJViewController

@synthesize centerBtn = _centerBtn;
@synthesize GPUImageBtn = _GPUImageBtn;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self _SJViewControllerSetupUI];
    
    // Do any additional setup after loading the view.
}

// MARK: Actions

- (void)clickedBtn:(UIButton *)btn {
    
    UIViewController *vc = nil;
    switch (btn.tag) {
        case 0: {
            vc = [SJRecordViewController new];
        }
            break;
        case 1: {
            vc = [SJRecordVideoViewController new];
        }
            break;
        default:
            break;
    }
    
    [SVProgressHUD showWithStatus:@"正在开启.."];
    SJRecordNavigationController *nav = [[SJRecordNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:^{
        [SVProgressHUD dismiss];
    }];
}

// MARK: UI

- (void)_SJViewControllerSetupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.centerBtn];
    _centerBtn.csj_size = CGSizeMake(200, 50);
    _centerBtn.center = self.view.center;
    
    [self.view addSubview:self.GPUImageBtn];
    _GPUImageBtn.frame = _centerBtn.frame;
    _GPUImageBtn.csj_y = _centerBtn.csj_MaxY + 20;
}

- (UIButton *)centerBtn {
    if ( _centerBtn ) return _centerBtn;
    _centerBtn = [UIButton buttonWithTitle:@"录制" titleColor:[UIColor blueColor] backgroundColor:[UIColor clearColor] tag:0 target:self sel:@selector(clickedBtn:) fontSize:14];
    return _centerBtn;
}

- (UIButton *)GPUImageBtn {
    if ( _GPUImageBtn ) return _GPUImageBtn;
    _GPUImageBtn = [UIButton buttonWithTitle:@"GPUImage" titleColor:[UIColor blueColor] tag:1 target:self sel:@selector(clickedBtn:) fontSize:14];
    return _GPUImageBtn;
}
@end

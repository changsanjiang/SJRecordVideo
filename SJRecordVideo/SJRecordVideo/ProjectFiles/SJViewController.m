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

@interface SJViewController ()

@property (nonatomic, strong, readonly) UIButton *centerBtn;

@end

@implementation SJViewController

@synthesize centerBtn = _centerBtn;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self _SJViewControllerSetupUI];
    
    // Do any additional setup after loading the view.
}

// MARK: Actions

- (void)clcikedBtn:(UIButton *)btn {
    SJRecordViewController *vc = [SJRecordViewController new];
    
    SJRecordNavigationController *nav = [[SJRecordNavigationController alloc] initWithRootViewController:vc];

    [self presentViewController:nav animated:YES completion:nil];
}

// MARK: UI

- (void)_SJViewControllerSetupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.centerBtn];
    _centerBtn.csj_size = CGSizeMake(50, 50);
    _centerBtn.center = self.view.center;
}

- (UIButton *)centerBtn {
    if ( _centerBtn ) return _centerBtn;
    _centerBtn = [UIButton buttonWithTitle:@"录制" titleColor:[UIColor blueColor] backgroundColor:[UIColor clearColor] tag:0 target:self sel:@selector(clcikedBtn:) fontSize:14];
    return _centerBtn;
}

@end

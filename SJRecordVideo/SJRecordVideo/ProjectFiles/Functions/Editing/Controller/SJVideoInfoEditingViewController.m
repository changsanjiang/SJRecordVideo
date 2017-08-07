//
//  SJVideoInfoEditingViewController.m
//  SJRecordVideo
//
//  Created by BlueDancer on 2017/8/3.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoInfoEditingViewController.h"

#import "AVAsset+Extension.h"

#import <Masonry.h>

#import <AVKit/AVKit.h>

@interface SJVideoInfoEditingViewController ()

@property (nonatomic, strong, readwrite) AVAsset *asset;
@property (nonatomic, assign, readwrite) SJScreenOrientation direction;
@property (nonatomic, strong, readwrite) AVPlayerViewController *avPlayerVC;

@end

@implementation SJVideoInfoEditingViewController

// MARK: Init

- (instancetype)initWithAsset:(AVAsset *)asset direction:(SJScreenOrientation)direction {
    self = [super init];
    if ( !self ) return nil;
    self.asset = asset;
    self.direction = direction;
    return self;
    
}

// MARK: 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _SJVideoInfoEditingViewControllerSetupUI];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.avPlayerVC.player pause];
}

// MARK: UI

- (void)_SJVideoInfoEditingViewControllerSetupUI {
    
    self.title = @"发布短视频";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.avPlayerVC = [AVPlayerViewController new];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:self.asset];
    self.avPlayerVC.player = [AVPlayer playerWithPlayerItem:item];
    [self.view addSubview:self.avPlayerVC.view];

    [self.avPlayerVC.player play];
    
    [self.avPlayerVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(UIEdgeInsetsMake(8, 8, 8, 8));
    }];
    
}

@end

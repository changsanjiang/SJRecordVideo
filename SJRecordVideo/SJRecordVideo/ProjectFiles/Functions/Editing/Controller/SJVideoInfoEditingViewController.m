//
//  SJVideoInfoEditingViewController.m
//  SJRecordVideo
//
//  Created by BlueDancer on 2017/8/3.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoInfoEditingViewController.h"

#import "AVAsset+Extension.h"

#import <MediaPlayer/MediaPlayer.h>

#import <Masonry.h>

@interface SJVideoInfoEditingViewController ()

@property (nonatomic, strong, readwrite) AVAsset *asset;
@property (nonatomic, strong, readwrite) MPMoviePlayerViewController *playerVC;
@property (nonatomic, assign, readwrite) SJScreenOrientation direction;

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
    [self.playerVC.moviePlayer pause];
}

// MARK: UI

- (void)_SJVideoInfoEditingViewControllerSetupUI {
    
    self.title = @"编辑短视频";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.playerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:self.asset.assetURL];
    
    [[self.playerVC moviePlayer] prepareToPlay];
    [[self.playerVC moviePlayer] play];
    
    self.playerVC.moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
    [self.view addSubview:self.playerVC.view];
    
    [self.playerVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(UIEdgeInsetsMake(8, 8, 8, 8));
    }];
}

@end

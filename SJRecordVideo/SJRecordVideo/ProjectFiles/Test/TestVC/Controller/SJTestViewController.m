//
//  SJTestViewController.m
//  SJRecordVideo
//
//  Created by BlueDancer on 2017/9/17.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJTestViewController.h"

#import "SJRecordVideoManager.h"

@interface SJTestViewController ()

@property (nonatomic, strong, readonly) SJRecordVideoManager *recordVideo;

@end

@implementation SJTestViewController

@synthesize recordVideo = _recordVideo;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _testVCSetupView];
    
    // Do any additional setup after loading the view.
}

- (void)_testVCSetupView {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(clickedRightBarButtonItem)];
    [self.view addSubview:self.recordVideo.previewView];
    self.recordVideo.previewView.frame = self.view.bounds;
}

- (void)clickedRightBarButtonItem {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (SJRecordVideoManager *)recordVideo {
    if ( _recordVideo ) return _recordVideo;
    _recordVideo = [SJRecordVideoManager new];
    return _recordVideo;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

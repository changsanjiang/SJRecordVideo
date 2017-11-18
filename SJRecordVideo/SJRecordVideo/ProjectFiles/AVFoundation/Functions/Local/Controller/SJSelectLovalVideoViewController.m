//
//  SJSelectLovalVideoViewController.m
//  SJRecordVideo
//
//  Created by BlueDancer on 2017/8/3.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJSelectLovalVideoViewController.h"

#import "SJRecordVideoSession.h"

#import <Photos/Photos.h>

#import "SJLoalSelectVideoModel.h"

#import <objc/message.h>

#import "UIView+Extension.h"

#import <Masonry.h>

static NSString * const SJLocalPreviewCollectionViewCellID = @"SJLocalPreviewCollectionViewCell";

@interface SJSelectLovalVideoViewController (UICollectionViewDelegateMethods)<UICollectionViewDelegate>
@property (nonatomic, strong, readonly) UIView *exportingMaskView;
@end

@interface SJSelectLovalVideoViewController (UICollectionViewDataSourceMethods)<UICollectionViewDataSource>
@end


@interface SJSelectLovalVideoViewController ()

@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, strong, readwrite) NSArray<SJLoalSelectVideoModel *> *models;
@property (nonatomic, strong, readwrite) SJRecordVideoSession *session;
@property (nonatomic, strong, readonly) UILabel *tipsLabel;

@end

@implementation SJSelectLovalVideoViewController

@synthesize collectionView = _collectionView;
@synthesize tipsLabel = _tipsLabel;

// MARK: 生命周期

- (instancetype)initWithSession:(SJRecordVideoSession *)session {
    self = [super init];
    if ( !self ) return nil;
    self.session = session;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _SJSelectLovalVideoViewControllerSetupUI];
    
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusAuthorized: {
                PHFetchOptions *options = [PHFetchOptions new];
                options.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:YES]];
                PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:options];
                if ( 0 == assets.count ) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [UIView animateWithDuration:0.25 animations:^{
                            self.tipsLabel.alpha = 1;
                        }];
                    });
                    return;
                }
                PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
                option.resizeMode = PHImageRequestOptionsResizeModeFast;
                option.networkAccessAllowed = YES;
                NSMutableArray <SJLoalSelectVideoModel *> *imagesM = [NSMutableArray new];
                for ( int i = 0 ; i < assets.count ; i ++ ) {
                    [imagesM addObject:[SJLoalSelectVideoModel new]];
                }
                NSMutableArray *tmpArrM = imagesM.mutableCopy;
                __weak typeof(self) _self = self;
                [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [[PHCachingImageManager defaultManager] requestImageForAsset:obj targetSize:CGSizeMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.width / 2) contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                        if ( ![info[@"PHImageResultIsDegradedKey"] boolValue] ) {
                            __strong typeof(_self) self = _self;
                            if ( !self ) return;
                            SJLoalSelectVideoModel *model = imagesM[idx];
                            model.previewImgae = result;
                            model.duration = obj.duration;
                            model.asset = obj;
                            model.direction = obj.pixelWidth < obj.pixelHeight ? SJScreenOrientationPortrait : SJScreenOrientationLandscape;
                            [tmpArrM removeObject:model];
                            if ( tmpArrM.count != 0 ) return;
                            self.models = imagesM;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.collectionView reloadData];
                                self.tipsLabel.alpha = 0.001;
                            });
                        }
                    }];
                }];
            }
                break;
                
            default:
                break;
        }
    }];
    
    // Do any additional setup after loading the view.
}

- (void)dealloc {
    [self.session cancelExport];
}

// MARK: UI

- (void)_SJSelectLovalVideoViewControllerSetupUI {
    
    self.title = @"选取本地视频";
    
    self.navigationItem.rightBarButtonItem = nil;
    
    [self.view addSubview:self.tipsLabel];
    [self.view addSubview:self.collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [_tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
}

- (UICollectionView *)collectionView {
    if ( _collectionView ) return _collectionView;
    
    // create
    _collectionView = [UICollectionView collectionViewWithItemSize:CGSizeMake([UIScreen mainScreen].bounds.size.width / 4, [UIScreen mainScreen].bounds.size.width / 4) backgroundColor:[UIColor grayColor] scrollDirection:UICollectionViewScrollDirectionVertical];
    
    // register
    [_collectionView registerClass:NSClassFromString(SJLocalPreviewCollectionViewCellID) forCellWithReuseIdentifier:SJLocalPreviewCollectionViewCellID];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    return _collectionView;
}

- (UILabel *)tipsLabel {
    if ( _tipsLabel ) return _tipsLabel;
    _tipsLabel = [UILabel labelWithFontSize:14 textColor:[UIColor lightGrayColor] alignment:NSTextAlignmentCenter];
    _tipsLabel.text = @"您本地没有视频..";
    return _tipsLabel;
}

@end

#import "SJVideoInfoEditingViewController.h"
#import <SVProgressHUD.h>
@implementation SJSelectLovalVideoViewController (UICollectionViewDelegateMethods)

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [SVProgressHUD showWithStatus:@"正在导出, 请耐心等待..."];
    [self.view addSubview:self.exportingMaskView];
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    SJLoalSelectVideoModel *model = [cell valueForKey:@"model"];
    PHVideoRequestOptions *options = [PHVideoRequestOptions new];
    options.networkAccessAllowed = YES;
    
    options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        [SVProgressHUD showProgress:progress status:@"从iCloud加载中"];
    };
    
    __weak typeof(self) _self = self;
    [[PHCachingImageManager defaultManager] requestAVAssetForVideo:model.asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        [_self.session exportAssets:asset maxDuration:3 * 60 direction:model.direction completionHandle:^(AVAsset *sandBoxAsset, UIImage *previewImage) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self.exportingMaskView removeFromSuperview];
            SJVideoInfoEditingViewController *vc = [[SJVideoInfoEditingViewController alloc] initWithAsset:sandBoxAsset direction:model.direction];
            vc.coverImage = previewImage;
            [self.navigationController pushViewController:vc animated:YES];
        }];
    }];
}

- (UIView *)exportingMaskView {
    UIView *view = objc_getAssociatedObject(self, _cmd);
    if ( view ) return view;
    view = [UIView new];
    view.frame = self.view.bounds;
    objc_setAssociatedObject(self, _cmd, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return view;
}

@end

@implementation SJSelectLovalVideoViewController (UICollectionViewDataSourceMethods)

// MARK: UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SJLocalPreviewCollectionViewCellID forIndexPath:indexPath];
    [cell setValue:self.models[indexPath.row] forKey:@"model"];
    return cell;
}

@end

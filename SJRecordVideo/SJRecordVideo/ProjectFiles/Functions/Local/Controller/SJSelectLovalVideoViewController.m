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

@end

@implementation SJSelectLovalVideoViewController

@synthesize collectionView = _collectionView;

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
                PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:nil];
                PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
                option.resizeMode = PHImageRequestOptionsResizeModeFast;
                option.networkAccessAllowed = YES;
                NSMutableArray <SJLoalSelectVideoModel *> *imagesM = [NSMutableArray new];
                __weak typeof(self) _self = self;
                [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [[PHCachingImageManager defaultManager] requestImageForAsset:obj targetSize:CGSizeMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.width / 2) contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                        if ( ![info[@"PHImageResultIsDegradedKey"] boolValue] ) {
                            SJLoalSelectVideoModel *model = [SJLoalSelectVideoModel new];
                            model.previewImgae = result;
                            model.duration = obj.duration;
                            model.asset = obj;
                            model.direction = obj.pixelWidth < obj.pixelHeight ? SJScreenOrientationPortrait : SJScreenOrientationLandscape;
                            [imagesM addObject:model];
                            if ( imagesM.count != assets.count ) return;
                            _self.models = imagesM.copy;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [_self.collectionView reloadData];
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
    
    self.title = @"选择视频";
    
    self.navigationItem.rightBarButtonItem = nil;
    
    [self.view addSubview:self.collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
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
 
@end

#import "SJVideoInfoEditingViewController.h"

@implementation SJSelectLovalVideoViewController (UICollectionViewDelegateMethods)

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"clicked item");
    [self.view addSubview:self.exportingMaskView];
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    SJLoalSelectVideoModel *model = [cell valueForKey:@"model"];
    PHVideoRequestOptions *options = [PHVideoRequestOptions new];
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

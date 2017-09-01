//
//  SJVideoInfoEditingViewController.h
//  SJRecordVideo
//
//  Created by BlueDancer on 2017/8/3.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SJRecordVideoEnumHeader.h"

@class AVAsset;

@interface SJVideoInfoEditingViewController : UIViewController

@property (nonatomic, strong, readwrite) UIImage *coverImage;

- (instancetype)initWithAsset:(AVAsset *)asset direction:(SJScreenOrientation)direction;

@end

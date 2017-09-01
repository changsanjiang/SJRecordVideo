//
//  SJLoalSelectVideoModel.h
//  SJRecordVideo
//
//  Created by BlueDancer on 2017/8/3.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import <Photos/PHAsset.h>

#import "SJRecordVideoEnumHeader.h"

@interface SJLoalSelectVideoModel : NSObject

@property (nonatomic, strong) UIImage *previewImgae;
@property (nonatomic, assign) NSInteger duration;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, assign) SJScreenOrientation direction;

@end

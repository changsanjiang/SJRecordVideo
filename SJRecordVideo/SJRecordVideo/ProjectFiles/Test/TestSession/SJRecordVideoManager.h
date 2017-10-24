//
//  SJRecordVideoManager.h
//  SJRecordVideo
//
//  Created by BlueDancer on 2017/9/17.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIView;

@interface SJRecordVideoManager : NSObject

- (instancetype)init;

@property (nonatomic, strong, readonly) UIView *previewView;

@end

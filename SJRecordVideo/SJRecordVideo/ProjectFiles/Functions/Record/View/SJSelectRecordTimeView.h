//
//  SJSelectRecordTimeView.h
//  SJRecordVideo
//
//  Created by BlueDancer on 2017/8/3.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJSelectRecordTimeView : UIView

@property (nonatomic, copy, readwrite) void(^clickedSecBtnBlock)();

@property (nonatomic, copy, readwrite) void(^clickedMinBtnBlock)();

@property (nonatomic, assign, readwrite) BOOL enableBtn;

@property (nonatomic, assign, readwrite) BOOL isRecordingOrPaused;



@end

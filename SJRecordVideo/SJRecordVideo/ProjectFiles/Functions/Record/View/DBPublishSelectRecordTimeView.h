//
//  DBPublishSelectRecordTimeView.h
//  dancebaby
//
//  Created by BlueDancer on 2017/8/2.
//  Copyright © 2017年 hunter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBPublishSelectRecordTimeView : UIView

@property (nonatomic, copy, readwrite) void(^clickedSecBtnBlock)();
@property (nonatomic, copy, readwrite) void(^clickedMinBtnBlock)();

@property (nonatomic, assign, readwrite) BOOL enableBtn;

@property (nonatomic, assign, readwrite) BOOL isRecordingOrPaused;

@end

//
//  SJSelectRecordTimeView.h
//  SJRecordVideo
//
//  Created by BlueDancer on 2017/8/3.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJSelectRecordTimeView : UIView

@property (nonatomic, assign, readwrite) BOOL enableBtns;

@property (nonatomic, strong, readwrite) NSString *btn1Title;
@property (nonatomic, strong, readwrite) NSString *btn2Title;

@property (nonatomic, copy, readwrite) void(^clickedBtn1Block)();
@property (nonatomic, copy, readwrite) void(^clickedBtn2Block)();

@end

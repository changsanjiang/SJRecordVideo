//
//  NSTimer+Extension.h
//  SJRecordVideo
//
//  Created by BlueDancer on 2017/8/3.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>


/*!
 *  一般把timer在主队列启动和释放就行了。 防止在子线程运行循环不启动。。。。
 */
@interface NSTimer (Extension)

+ (instancetype)sj_scheduledTimerWithTimeInterval:(NSTimeInterval)ti exeBlock:(void(^)())block repeats:(BOOL)yesOrNo;

@end

//
//  SJRecordControlView.m
//  SJRecordVideo
//
//  Created by BlueDancer on 2017/8/3.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJRecordControlView.h"

#import "SJRecordControlHeaderView.h"

#import "SJRecordControlAreaView.h"

#import <Masonry.h>

@interface SJRecordControlView ()

@property (nonatomic, strong, readonly) SJRecordControlHeaderView *headerView;

@property (nonatomic, strong, readonly) SJRecordControlAreaView *areaView;

@end

@implementation SJRecordControlView

@synthesize headerView = _headerView;
@synthesize areaView = _areaView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _SJRecordControlViewSetupUI];
    return self;
}

// MARK: UI

- (void)_SJRecordControlViewSetupUI {
    
    self.backgroundColor = [UIColor clearColor];
    
    
    [self addSubview:self.headerView];
    [self addSubview:self.areaView];
    
    
    [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.offset(0);
        make.height.offset(64);
    }];
    [_areaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.offset(0);
        make.height.equalTo(self).multipliedBy(0.25);
    }];
}

- (SJRecordControlHeaderView *)headerView {
    if ( _headerView ) return _headerView;
    _headerView = [SJRecordControlHeaderView new];
    return _headerView;
}

- (SJRecordControlAreaView *)areaView {
    if ( _areaView ) return _areaView;
    _areaView = [SJRecordControlAreaView new];
    return _areaView;
}
@end

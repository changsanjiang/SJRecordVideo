//
//  SJLocalPreviewCollectionViewCell.m
//  SJRecordVideo
//
//  Created by BlueDancer on 2017/8/3.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJLocalPreviewCollectionViewCell.h"

#import "UIView+Extension.h"

#import <Masonry.h>

#import "SJLoalSelectVideoModel.h"

@interface SJLocalPreviewCollectionViewCell ()

@property (nonatomic, strong, readonly) UIImageView *previewImageView;
@property (nonatomic, strong, readonly) UILabel *durationLabel;

@property (nonatomic, strong, readonly) NSDateFormatter *dateFormatter;

@end

@implementation SJLocalPreviewCollectionViewCell

@synthesize previewImageView = _previewImageView;
@synthesize durationLabel = _durationLabel;
@synthesize dateFormatter = _dateFormatter;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _SJLocalPreviewCollectionViewCellSetupUI];
    return self;
}

- (void)setModel:(SJLoalSelectVideoModel *)model {
    _model = model;
    _previewImageView.image = model.previewImgae;
    _durationLabel.text = [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:model.duration]];
}

// MARK: UI

- (void)_SJLocalPreviewCollectionViewCellSetupUI {
    
    [self.contentView addSubview:self.previewImageView];
    [self.contentView addSubview:self.durationLabel];
    
    
    [_previewImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(UIEdgeInsetsMake(2, 2, 2, 2));
    }];
    
    [_durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.trailing.offset(-4);
    }];
}

- (UIImageView *)previewImageView {
    if ( _previewImageView ) return _previewImageView;
    _previewImageView = [UIImageView imageViewWithImageStr:@"" viewMode:UIViewContentModeScaleAspectFill];
    return _previewImageView;
}

- (UILabel *)durationLabel {
    if ( _durationLabel ) return _durationLabel;
    _durationLabel = [UILabel labelWithFontSize:12 textColor:[UIColor whiteColor] alignment:NSTextAlignmentRight];
    return _durationLabel;
}

- (NSDateFormatter *)dateFormatter {
    if ( _dateFormatter ) return _dateFormatter;
    _dateFormatter = [NSDateFormatter new];
    _dateFormatter.dateFormat = @"mm:ss";
    return _dateFormatter;
}

@end

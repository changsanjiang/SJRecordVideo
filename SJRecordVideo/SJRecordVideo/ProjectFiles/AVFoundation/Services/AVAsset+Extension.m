//
//  AVAsset+Extension.m
//  dancebaby
//
//  Created by BlueDancer on 2017/7/15.
//  Copyright © 2017年 hunter. All rights reserved.
//

#import "AVAsset+Extension.h"

#import <objc/message.h>

@implementation AVAsset (Extension)

- (NSURL *)assetURL {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAssetURL:(NSURL *)assetURL {
    objc_setAssociatedObject(self, @selector(assetURL), assetURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

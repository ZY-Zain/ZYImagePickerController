//
//  ZYCollectionViewCell.m
//  ZYImagePickerControllerDemo
//
//  Created by ZhiYong_Huang on 2017/2/16.
//  Copyright © 2017年 ZY_Zain. All rights reserved.
//

#import "ZYCollectionViewCell.h"
@interface ZYCollectionViewCell ()

@end

@implementation ZYCollectionViewCell

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        NSLog(@"1");
        [self setup];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        NSLog(@"2");
        [self setup];
    }
    return self;
}

-(instancetype)init {
    if (self = [super init]) {
        NSLog(@"3");
        [self setup];
    }
    return self;
}
 
-(void)setup {
    [self.contentView addSubview:self.imageVew];

    [self.imageVew setTranslatesAutoresizingMaskIntoConstraints:false];
    NSLayoutConstraint *Left = [NSLayoutConstraint constraintWithItem:self.imageVew attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *Rigth = [NSLayoutConstraint constraintWithItem:self.imageVew attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    NSLayoutConstraint *Bottom = [NSLayoutConstraint constraintWithItem:self.imageVew attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.imageVew attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [self.contentView addConstraints:@[Left, Rigth, Bottom, top]];
}

-(UIImageView *)imageVew {
    if (_imageVew == nil) {
        _imageVew = [[UIImageView alloc] init];
    }
    return _imageVew;
}

@end

//
//  ZYImagePickerController.h
//  textRuntime
//
//  Created by ZhiYong_Huang on 2016/5/15.
//  Copyright © 2016年 ZY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZYImagePickerController;
@protocol ZYImagePickerControllerDelegate <NSObject>
@optional
/**
 *  选择图片时的代理回调  返回是否可以选择该图片
 *
 *  @param picker picker
 *  @param image  被选择的图片
 *
 *  @return 返回BOOL 是否能选择这张图片
 */
- (BOOL)imagePickerController:(ZYImagePickerController *)picker shouldSelectImage:(UIImage*)image;
/**
 *  选择图片完成后并点击确定按钮的时候调用  需要注意的是，在这个代理回调方法中 需要手动dismiss pickerController
 *
 *  @param picker    picker
 *  @param imagesArr 选择的所有图片的数组
 */
- (void)imagePickerController:(ZYImagePickerController *)picker clickFinishSelectPhotoWithImages:(NSArray <UIImage *> *)imagesArr;
/**
 *  点击取消按钮的时候调用
 *
 *  @param picker picker
 */
- (void)imagePickerControllerClickCancel :(ZYImagePickerController *)picker ;
/**
 *  选择的图片超过上限的时候调用
 *
 *  @param picker   picker
 *  @param masCount 当前设定的最大图片上限数量
 */
- (void)imagePickerController:(ZYImagePickerController *)picker selectImageOverMaxCount:(NSInteger)masCount;
@end

@interface ZYImagePickerController : UIImagePickerController
/**
 *  保存了选择的所有照片
 */
@property(nonatomic, strong) NSArray <UIImage *>*imagesArr;
/**
 *  设置最大的选择图片上下，如果传0 则是没有限制  默认是0
 */
@property(nonatomic, assign) NSInteger maxImageCount;
/**
 *  底部确定按钮的文字，默认是"确定"
 */
@property(nonatomic, copy) NSString *doneButtonTitle;
/**
 *  代理
 */
@property(nonatomic, weak) id<ZYImagePickerControllerDelegate> myDelegate;
@end

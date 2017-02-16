//
//  ViewController.m
//  ZYImagePickerControllerDemo
//
//  Created by ZhiYong_Huang on 2017/2/16.
//  Copyright © 2017年 ZY_Zain. All rights reserved.
//

#import "ViewController.h"
#import "ZYImagePickerController.h"
#import "ZYCollectionViewCell.h"

#define cellReuseIdentifier @"identifierCell"
@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource, ZYImagePickerControllerDelegate>
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) UICollectionViewFlowLayout * flowLayout;
@property(nonatomic, strong) NSArray <UIImage *> *selectImageArr;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"点击弹出相册选择器" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:button];
    button.frame = CGRectMake(self.view.bounds.size.width * 0.5 - 100, 100 * 0.5 - 20, 200, 40);

    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(8, 100, self.view.bounds.size.width - 16, self.view.bounds.size.height) collectionViewLayout:self.flowLayout];

    self.flowLayout.minimumLineSpacing = 10;
    self.flowLayout.minimumInteritemSpacing = 10;
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat itemWidth = (screenWidth - 20 - 16) / 3.0;
    self.flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);

    [self.collectionView registerClass:[ZYCollectionViewCell class] forCellWithReuseIdentifier:cellReuseIdentifier];
    self.collectionView.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;

    [self.view addSubview:self.collectionView];
}

-(void)clickButton:(UIButton *)button {
    ZYImagePickerController *picker = [[ZYImagePickerController alloc] init];
    picker.myDelegate = self;
    //设置最大的可选图片数量
    picker.maxImageCount = 9;
    //设置右下角显示的按钮文字
    picker.doneButtonTitle = @"确定";
    [self presentViewController:picker animated:true completion:nil];
}

#pragma mark - ZYImagePickerControllerDelegate
/**
 *  点击取消按钮的代理回调
 *
 *  @param picker picker
 */
-(void)imagePickerControllerClickCancel:(ZYImagePickerController *)picker {
    [picker dismissViewControllerAnimated:true completion:nil];
}

/**
 *  选择完图片后 点击确定按钮的代理回调
 *
 *  @param picker    picker
 *  @param imagesArr 保存用户选择了的所有图片的数组
 */
-(void)imagePickerController:(ZYImagePickerController *)picker clickFinishSelectPhotoWithImages:(NSArray<UIImage *> *)imagesArr {
    [picker dismissViewControllerAnimated:YES completion:^{

    }];
    self.selectImageArr = imagesArr.copy;
    NSLog(@"imagesArr.count = %ld",imagesArr.count);
    [self.collectionView reloadData];
}

/**
 *  用户选择的图片数量超过 设定的图片数量时的代理回调
 *
 *  @param picker   picker
 *  @param maxCount 设定好的最大图片选择数量
 */
-(void)imagePickerController:(ZYImagePickerController *)picker selectImageOverMaxCount:(NSInteger)maxCount {
    NSString* message = [NSString stringWithFormat:@"你最多只能选择%ld张图片喔!", (long)maxCount];

    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil, nil];

    [alert show];
}


#pragma mark - collectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"count = %ld",self.selectImageArr.count);
    return self.selectImageArr.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZYCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellReuseIdentifier forIndexPath:indexPath];

    cell.imageVew.image = self.selectImageArr[indexPath.row];
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

#智勇第三方 ZYImagePickerController 系统相册 多选照片
----
##简介
====
很多项目往往是需要用户从相册中选择多张图片的。此时如果用系统原生的UIImagePickerController，就只能一张一张的来选择，如果最多能选择9张 甚至跟多的时候，系统原生的控件就不行了。
<br><br><br>
我这里分享的这个第三方，就能简单方便的解决了系统原生控件不能多选照片的不足。控件集成的是系统的UIImagePickerController，所以跟使用系统原生的 差别不大，起码性能上不会有差距。不像其他一些第三方，虽然看上去跟使用系统选择相册的界面一样，但实际上却是获取了相册中所有的图片对象，然后模仿系统控件的界面来进行布局。这样的不好是需要一次性获取相册中的所有图片，如果相册中有超过1000张图片，想想这个时候的内存会怎样。
<br><br><br><br>
整个第三方主要依赖于runtime进行时去修改系统级别的控件的显示界面和功能，所以不管用不用的上，大家都可以下载代码来研究一下。此Demo也可以算得上是对runtime的一个入门级别的运用讲解。
<br><br><br>
值得一提的是，整个Demo中，注释非常的详细，特别是关于runtime方面的注释。就算用不上这个功能，也可以下载Demo来看一下，有值得学习地方!
<br><br><br>
Demo下载完就可以直接模拟器就可以直接运行，并不需要配置其他东西或者真机运行。看完Demo后，如果觉得对你有帮助的，记得来帮忙点个星喔！  你们的点星，是我更新更多第三方的动力！
<br>
====
历史版本更新:
V1.0 第一版本
V1.1 修复当相册中有大于100张图片时 出现的重用问题
====
##快速接入
====
```Objective-C
/**
 *  点击弹出系统相册的按钮的响应方法
 *
 *  @param button 按钮
 */
-(void)clickShowPickerControllerButtonAction:(UIButton *)button {
    ZYImagePickerController *picker = [[ZYImagePickerController alloc] init];
    picker.myDelegate = self;
    //设置最大的可选图片数量 默认为0 是无限制数量选择选择
    picker.maxImageCount = 9;
    //设置右下角显示的按钮文字  可以不设置  默认的字体就是 确定
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
```
====
###Demo介绍图
![img](http://wx2.sinaimg.cn/mw690/7ef5f86agy1fct6vm2p2qg205k0a0tzl.gif "Demo介绍")

//
//  ZYImagePickerController.m
//  textRuntime
//
//  Created by ZhiYong_Huang on 2016/5/15.
//  Copyright © 2016年 ZY. All rights reserved.
//

#import "ZYImagePickerController.h"
#import <objc/runtime.h>
#define ZYImagePickerControllerKey @"attachKey"
#define ZYBottomDoneButtonKey @"doneButtonKey"
@interface ZYImagePickerController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
/**
 *  相册中 展示图片时用的View的类型  基类是UICollectionView
 */
@property(nonatomic, strong) Class PUCollectionView;
/**
 *  PUCollectionView中 单独显示每一张图片的View类型
 */
@property(nonatomic, strong) Class PUPhotoView;
/**
 *  当前正在显示的PUCollection 因为PUCollection类型只有在运行的时候 才会存在 所以这里只能使用的他基类 去指向他 因为是系统管理的控件 所以只能用weak 不能强引用 否则内存泄露
 */
@property(nonatomic, weak) UICollectionView *collectionView;
/**
 *  原始PUCollectionView的代理对象  因为下面会用运行时方法 替换掉PUCollectionView的代理对象  但之后 又有需求是要调用PUCollectionView的原来的代理方法  所以这里需要引用着PUCollectionView原来的代理对象 之后直接调用这个对象的对应的代理方法就可以了
 */
@property(nonatomic, strong) id PUCollectionViewLastDelegate;
/**
 *  保存了当前选择的所有图片，内部使用
 */
@property(nonatomic, strong) NSMutableArray <UIImage *> *allImagesArr;
/**
 *  保存了当前选择的所有图片对应的所有indexPath
 */
@property(nonatomic, strong) NSMutableArray <NSIndexPath *> *allIndexPathsArr;
/**
 *  当前选择的图片对应的indexPath
 */
@property(nonatomic, strong) NSIndexPath *currentIndexPath;
/**
 *  底部View 里面有确定按钮
 */
@property(nonatomic, strong) UIView *bottomView;
/**
 *  底部确定按钮
 */
@property(nonatomic, strong) UIButton *doneButton;
@end

@implementation ZYImagePickerController

-(instancetype)init {
    if (self = [super init]) {
        [self setup];
        
    }
    return self;
}

-(void)setup {
    self.delegate = self;

    //运用进行时方法 进行函数指针对换
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // PUCollectionView代理对象的共同基类(PUPhotosGridViewController)。
        Class targetClass = [NSClassFromString(@"PUPhotosGridViewController") class];
        //返回一个指定的方法  也就是m1方法就等同于后面这个方法
        Method m1 = class_getInstanceMethod([self class], @selector(override_collectionView:cellForItemAtIndexPath:));

        //给一个指定的类(targetClass上面传进来的字符串 转换成类class)  添加一个指定的方法@selector里面的方法    方法的实现(调用getImplementation方法传入一个方法 然后返回这个方法的实现)    方法的参数和返回类型(调用getTypeEncoding方法 传入一个方法 返回这个方法所需要的参数和返回类型 并且是字符串类型)
        class_addMethod(targetClass, @selector(override_collectionView:cellForItemAtIndexPath:), method_getImplementation(m1), method_getTypeEncoding(m1));

        //提取两个方法m2方法是自己重写的覆盖方法    m3方法 是系统的原有方法
        Method m2 = class_getInstanceMethod(targetClass, @selector(override_collectionView:cellForItemAtIndexPath:));
        Method m3 = class_getInstanceMethod(targetClass, @selector(collectionView:cellForItemAtIndexPath:));

        //将连个方法交流 也就是调用m2方法时 同时调用m3方法
        method_exchangeImplementations(m2, m3);
        /*
         上面做了这么多 最终就是为了 当PUCollectionView调用代理方法的时候 就是调用代理对象的方法 而代理对象的基类是PUPhotosGridViewController  也就是最终调用的是PUPhotosGridViewController 的方法  而上面就获取了这个类型  然后用运行时给这个类型 添加了一个方法 就是我们下面自己新写的覆盖方法override_collectionView:cellForItemAtIndexPath:    然后再提取出PUPhotosGridViewController原有的collectionView:cellForItemAtIndexPath:方法出来  将两个方法的Imp对换  Imp可以认定为函数的指针地址   从此之后PUPhotosGridViewController只要调用系统原来的collectionView:cellForItemAtIndexPath:实际却是调用了我们在这里新写的覆盖方法  而如果我们手动取PUPhotosGridViewController来调用我们新写的覆盖方法override_collectionView:cellForItemAtIndexPath:实际 却是调用了系统原来的collectionView:cellForItemAtIndexPath:方法
         */
    });
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupBottomView];
}

-(void)setupBottomView {
    //初始化bottomView
    self.bottomView.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1];
    [self.view addSubview:self.bottomView];
    [self.bottomView setTranslatesAutoresizingMaskIntoConstraints:false];
    NSLayoutConstraint *bottomLeft = [NSLayoutConstraint constraintWithItem:self.bottomView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *bottomRigth = [NSLayoutConstraint constraintWithItem:self.bottomView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    NSLayoutConstraint *bottomBottom = [NSLayoutConstraint constraintWithItem:self.bottomView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *bottomHeigth = [NSLayoutConstraint constraintWithItem:self.bottomView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:44];
    [self.view addConstraints:@[bottomLeft, bottomRigth, bottomBottom]];
    [self.bottomView addConstraint:bottomHeigth];

    //初始化doneButton
    [self.bottomView addSubview:self.doneButton];
    [self.doneButton addTarget:self action:@selector(clickSuerButton:) forControlEvents:UIControlEventTouchUpInside];
    if (self.doneButtonTitle == nil || [self.doneButtonTitle isEqualToString:@""]) {
        //默认按钮显示 确定 文字
        self.doneButtonTitle = @"确定";
    }
    [self.doneButton setTitle:self.doneButtonTitle forState:UIControlStateNormal];

    [self.doneButton setTranslatesAutoresizingMaskIntoConstraints:false];
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:self.doneButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.bottomView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *rigth = [NSLayoutConstraint constraintWithItem:self.doneButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.bottomView attribute:NSLayoutAttributeRight multiplier:1 constant:-15];
    [self.bottomView addConstraints:@[centerY, rigth]];
    self.doneButton.enabled = NO;

    //分割线
    UIView *speakView = [[UIView alloc] init];
    speakView.backgroundColor = [UIColor lightGrayColor];
    [self.bottomView addSubview:speakView];
    [speakView setTranslatesAutoresizingMaskIntoConstraints:false];
    NSLayoutConstraint *viewLeft = [NSLayoutConstraint constraintWithItem:speakView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.bottomView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *viewRigth = [NSLayoutConstraint constraintWithItem:speakView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.bottomView attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    NSLayoutConstraint *viewTop = [NSLayoutConstraint constraintWithItem:speakView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.bottomView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *viewHeigth= [NSLayoutConstraint constraintWithItem:speakView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:1];
    [self.bottomView addConstraints:@[viewLeft, viewRigth, viewTop]];
    [speakView addConstraint:viewHeigth];
}

#pragma mark - 按钮的响应方法
-(void)clickSuerButton:(UIButton *)button {
    if ([self.myDelegate respondsToSelector:@selector(imagePickerController:clickFinishSelectPhotoWithImages:)]) {
        [self.myDelegate imagePickerController:self clickFinishSelectPhotoWithImages:self.allImagesArr.copy];
    }
}

#pragma mark - navigationControllerDelegate
-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UITableView *tableView;
    UIView *collection;
    for (UIView *i in viewController.view.subviews) {
        if ([i isKindOfClass:[UITableView class]]) {
            tableView = (UITableView *)i;
        }
        if ([i isKindOfClass:self.PUCollectionView]) {
            collection = i;
        }
    }


    CGFloat heigth = [UIScreen mainScreen].bounds.size.height;

    if (tableView != nil) {
        //这里高度只能取屏幕高度 然后减去底部确定按钮的高度44  不能取会tableView原来的高度来减  因为这里修改高度后 还会再调用这个willShow的方法 此时取出来的tableView.frame.size.heigth是已经减了44的高度 然后又再次减  就减了2次高度了  所以就直接取屏幕高度-44的值 为tableView的高度就好了
        CGRect tableViewFrame = tableView.frame;
        tableView.frame = CGRectMake(tableViewFrame.origin.x, tableViewFrame.origin.y, tableViewFrame.size.width, heigth - 44);
    }

    if (collection != nil) {
        //这里跟上面一样
        CGRect collectionFrame = collection.frame;
        collection.frame = CGRectMake(collectionFrame.origin.x, collectionFrame.origin.y, collectionFrame.size.width, heigth - 44);
    }
}

/**
 *  开始展示时调用  这里也就是开始展示 相册控制器 的时候调用
 *
 *  @param navigationController navigationController
 *  @param viewController       当前正在显示的控制器
 *  @param animated             动画效果
 */
-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    //便利当前控制器中的每一个view  直至有一个view的类型是PUCollectionView
    UIView *collection;
    for (UIView * i in viewController.view.subviews) {
        if ([i isKindOfClass:self.PUCollectionView]) {
            collection = i;
        }
    }

    //此次进入的不是图片展示画面
    if (!collection) {
        return;
    }

    //第一次进来选择图片界面 初始化所有数据 以防还有旧数据存在
    self.currentIndexPath = nil;
    self.PUCollectionViewLastDelegate = nil;
    self.collectionView = nil;
    [self.allImagesArr removeAllObjects];
    [self.allIndexPathsArr removeAllObjects];

    //获取PUCollectionView的原来的代理对象
    self.PUCollectionViewLastDelegate = [collection valueForKey:@"delegate"];
    //运行时 强制性修改代理对象 让我们自己的控制器接收PUCollectionView的代理回调
    [collection setValue:self forKey:@"delegate"];

    //将self作为对象赋值到PUCollectionView的原有代理对象上。 因为这里运用了OC的运行时方法  之后会有调用PUCollectionView的代理方法  而且并不是由我们自己的这个ZYImagePickerController类 来调用 而是有PUCollectionView的代理对象去调用  所以在那个代理方法中  self参数 获取的就是PUCollectionView的代理对象  也就是我们这里的self.PUCollectionViewLastDelegate  所以当我们需要在 在那个代理方法中 需要取出我们的ZYImagePickerController时就拿不到了 因为self并不是我们的控制器 虽然那个代理方法是写在我们的ZYImagePickerController.m文件中  但我们利用了运行时方法进行了 指针对换  所以这里我们只能通过进行时方法 将self 也就是ZYImagePickerController 赋值给PUCollectionView的代理对象  到时候 我们就能通过PUCollectionView对象 取出我们自己的控制器ZYImagePickerController了
    objc_setAssociatedObject(self.PUCollectionViewLastDelegate, ZYImagePickerControllerKey, self, OBJC_ASSOCIATION_ASSIGN);
}

#pragma mark - UICollectionViewDataSource method
/**
 *  注意，这个函数的self指针指向的是PUCollectionView的代理对象上。因为我们一开始已经将这个函数添加上去到PUCollectionView的代理对象上了。所以现在调用这个方法的是PUCollectionView的代理对象来调用  并非是我们自己的控制器ZYImagePickerController  虽然这个方法是写在了我们的ZYImagePickerController控制器中
    至于为什么要重写这个函数  是因为cell的重用机制导致选择标记会被重用 导致数据错乱。所以需要在cell被重用时需要根据当前得到记录数据来重新添加或删除标记。
 *
 *  @param collectionView collectionView
 *  @param indexPath      indexPath
 *
 *  @return collectionViewCell
 */
-(UICollectionViewCell *)override_collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //因为我们这个函数 是在一开始的时候 利用进行时去 跟系统原生的collectionView:cellForItemAtIndexPath:函数  进行了Imp对换  也就是此时 系统是应该调用collectionView:cellForItemAtIndexPath:函数  来拿cell去做展示的  而此时就调用了我们自己重新写的这个函数  为了不影响系统原生的展示界面  这里就直接调用系统原生的函数 去获取cell  而不是重新创建一个cell  当然也可以在这里创建一个属于自己的cell来进行展示   而此时如果需要调用系统原生的collectionView:cellForItemAtIndexPath:函数  门面上则是要调用PUCollectionView的代理对象 的override_collectionView:cellForItemAtIndexPath:函数  因为两个函数我们做了Imp对换  
    //调用原始的collectionView:cellForItemAtIndexPath:函数去获得系统原生的cell去进行展示。
    UICollectionViewCell *cell = [self performSelector:@selector(override_collectionView:cellForItemAtIndexPath:) withObject:collectionView withObject:indexPath];

    //我们之前就已经利用进行时方法 把我们自己的控制器ZYImagePickerController 赋值给了PUCollectionView的代理对象中。而这里就是PUCollectionView的代理对象 调用的代理方法  所以在这里直接self就是PUCollectionView的代理对象 然后就可以取出我们自己的写的控制器 然后就能获取到当前的数据了
    ZYImagePickerController *pickerController = (ZYImagePickerController *)objc_getAssociatedObject(self, ZYImagePickerControllerKey);

    if (pickerController) {
        //调用pickerController的内部方法 传入当前cell的indexPath 判断此次的cell是否已经存在 选择的数组中
        if ([pickerController indexPathIsInAllIndexPathsArrWithIndexPath:indexPath] != NSIntegerMax) {
            //这个cell的indexPath 已经存在了 选择的indexPath数组中 也就是这个cell 是被选择了的 需要添加标记
            UIButton *indicatorButton = [pickerController getIndicatorButton:cell];
            if (indicatorButton == nil) {
                //还没有添加标记按钮  调用pickerController的内部方法 传入cell 去添加标记按钮
                [pickerController addIndicatorButton:cell];
            } else {
                //已经添加了标记按钮 则只需要确保标记按钮的hidden不为True就可以了
                indicatorButton.hidden = false;
            }
        } else {
            //这个cell并没有存在 选择的数组中 并没有选择这个cell 防止重用 需要移除标记
            [pickerController removeIndicatorButton:cell];
        }
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate
/**
 *  PUCollectionView照片显示控件的代理方法 是否可以选择这张图片
 *
 *  @param collectionView PUCollectionView
 *  @param indexPath      此次选择的indexPath
 *
 *  @return 返回YES则是可以选择  返回NO则是不能选择
 */
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //保存起来 这张图片对应的cell的indexPath  之后通过这个indexPath来找到这个cell 然后添加右上角的勾选图标
    self.currentIndexPath = indexPath;
    //保存起PUCollectionView 需要调用PUCollectionView的方法就可以直接调用了
    self.collectionView = collectionView;

    UIView *cell = [collectionView cellForItemAtIndexPath:indexPath];

    UIButton *indicatorButton = [self getIndicatorButton:cell];

    // 没有选择标记说明此时是打算选择这个图片，检查上限。
    if (indicatorButton == nil) {
        if ([self.allImagesArr count] >= self.maxImageCount) {
            // 选择图片已经超过上限。  调用代理通知外界 并且不能选择这张图片
            if ([self.myDelegate respondsToSelector:@selector(imagePickerController:selectImageOverMaxCount:)]) {
                [self.myDelegate imagePickerController:self selectImageOverMaxCount:self.maxImageCount];
            }
            return NO;
        }
    }

    // 调用原始的collectionView:shouldSelectItemAtIndexPath:
    //_cmd表示方法的自身  这里拼接出来的字符串其实就是collectionView:shouldSelectItemAtIndexPath:  然后创建成一个SEL方法指示器   判断PUCollectionView原来的代理对象 能否调用这个方法  如果能调用就调用这个原始的方法  调用这个原始的方法之后 系统就会接着调用UIImagePikcerController的代理方法  didFinishPickingImage来通知我们 选中了这张图片
    SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%s", sel_getName(_cmd)]);
    if ([self.PUCollectionViewLastDelegate respondsToSelector:sel]) {
        //屏蔽警告  因为self.PUCollectionViewLastDelegate 是id类型 要到运行的时候 才能确定类型 所以编译时 要用一个id类型对象去 调用函数 有可能会造成内存泄露  所以屏蔽警告
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.PUCollectionViewLastDelegate performSelector:sel withObject:collectionView withObject:indexPath];
#pragma clang diagnostic pop
    }

    /*
        我们之前为什么要强制性修改了PUCollectionView的Delegate对象为自己的控制器  然后来拦截这个shouldSelectItemAtIndexPath代理方法  最终却又要调用PUCollectionView原来的代理对象的shouldSelectItemAtIndexPath这个方法。
        首先,是因为我们拦截了PUCollectionView的代理对象的这个方法之后 如果不调用PUCollectionView原来的代理对象的这个方法，这样此次的响应事件就被截止了。系统并不会再去调用UIImagePickerController的代理方法didFinishPickingImage 这样我们就只能拿到此次用户点击了那个indexPath和哪个cell 却并不能拿到cell里面的image。除非我们自己把整个cell都自己重新做 不用系统的cell。所以最终 我们还是要调用PUCollectionView原来的代理对象的这个方法
        第二,就是如果我们不拦截PUCollectionView的这个代理方法，那当用户选择某张图片后，系统就会直接到达UIImagePickerController的代理方法didFinishPickingImage中，此时我们就直接拿到用户选择的image了 但是因为是多选的 所以我们还需要对这张图片加上一个可视化标记 让用户看到他已经选择了这张图片  而此时只有一个image对象  其他什么都没了
        所以最终 我们先拦截了这个代理方法 此时在这个代理方法中 我们就拿到了用户此次选择的图片的cell的indexPath  然后再调用原代理对象的方法 去让交互事件继续下去  最后再拿到image对象  然后就根据我们这里拿到的cell的indexPath  去调用PUCollectionView的cellForItemAtIndexPath拿取出image对应的cell 然后就可以在cell的右上角上添加一个打勾图片
     */
    return YES;
}

#pragma mark - UIImagePikcerControllerDelegate method
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    //根据之前保存下来的当前图片的indexPath 调用内部方法 判断这张图片之前呢是否已经被选择过了
    NSInteger currentImageIndex = [self indexPathIsInAllIndexPathsArrWithIndexPath:self.currentIndexPath];

    if (currentImageIndex == NSIntegerMax) {
        //这张图片还没选择过  调用代理方法  查看是否可以选择这张图片
        if ([self.myDelegate respondsToSelector:@selector(imagePickerController:shouldSelectImage:)]) {
            if ([self.myDelegate imagePickerController:self shouldSelectImage:image] == YES) {
                //可以选择这张图片  调用内部方法  将图片放进数组中  并且在图片的右上角添加 一个勾选的图标
                [self addCurrentImage:image];
            } else {
                //不可已选择这张图片  直接return
                return;
            }
        } else {
            //没有实现代理方法  直接默认可以选择这张图片
            [self addCurrentImage:image];
        }
    } else {
        //这张图片之前已经选择了  这里再次选择就是取消选择
        [self removeCurrentImage:image];
    }

    //只要选择图片的数组 大于0 就展示底部的确定按钮
    if (self.allImagesArr.count > 0) {
        self.doneButton.enabled = true;
    } else {
        self.doneButton.enabled = false;
    }
}

/**
 *  点击取消退出相册选择器时的代理回调
 *
 *  @param picker picker
 */
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if ([self.myDelegate respondsToSelector:@selector(imagePickerControllerClickCancel:)]) {
        [self.myDelegate imagePickerControllerClickCancel:self];
    }
}

#pragma mark - 内部方法
/**
 *  添加被选中的标记
 *
 *  @param view 需要添加标记的视图控件
 */
-(void)addIndicatorButton:(UIView *)view {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.cornerRadius = 30 * 0.5;
    [button setImage:[UIImage imageNamed:@"ZYImagePickerController.bundle/AssetsPickerChecked"]
            forState:UIControlStateNormal];
    [view addSubview:button];
    //取消autoresizing 使用Layout约束布局
    [button setTranslatesAutoresizingMaskIntoConstraints:false];
    NSArray* cs1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[button(30)]-1-|"
                                                           options:0 metrics:nil
                                                             views:NSDictionaryOfVariableBindings(button)];
    NSArray* cs2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-1-[button(30)]"
                                                           options:0 metrics:nil
                                                             views:NSDictionaryOfVariableBindings(button)];
    [view addConstraints:cs1];
    [view addConstraints:cs2];

    [button setSelected:true];
    button.hidden = false;

    [view updateConstraintsIfNeeded];
}

/**
 *  移除被选中的标记
 *
 *  @param view 需要被移除标记的视图控件
 */
-(void)removeIndicatorButton:(UIView *)view {
    for (UIView* button in view.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            [button removeFromSuperview];
            return;
        }
    }
}

/**
 *  传入一个视图控件 然后查看这个视图控件 是否已经添加了标记按钮
 *
 *  @param view 视图控件
 *
 *  @return 如果已经添加了标记按钮 则返回标记按钮 否则返回nil
 */
-(UIButton *)getIndicatorButton:(UIView *)view {
    for (id button in view.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            return (UIButton *)button;
        }
    }
    return nil;
}

/**
 *  判断此indexPath 是否已经存在全部的indexPath数组中
 *
 *  @param indexPath 需要判断的indexPath
 *
 *  @return 如果存在 则返回该图片在数组中的下标  如果不存在 则返回最大值
 */
-(NSInteger)indexPathIsInAllIndexPathsArrWithIndexPath:(NSIndexPath *)indexPath {
    for (int i = 0; i < self.allIndexPathsArr.count; i++) {
        if ((self.allIndexPathsArr[i]).row == indexPath.row &&
            (self.allIndexPathsArr[i]).section == indexPath.section) {
            return i;
        }
    }
    return NSIntegerMax;
}

/**
 *  将图片保存到所有选择的图片数组中  并且在当前选中的图片上 在右上角添加选中的图片
 *
 *  @param image 被选中的图片
 */
-(void)addCurrentImage:(UIImage *)image {
    NSInteger currentImageIndex = [self indexPathIsInAllIndexPathsArrWithIndexPath:self.currentIndexPath];
    //返回最大值的NSInterger 标识当前选择的图片 不存在于数组中 可以添加该图片
    if (currentImageIndex == NSIntegerMax) {
        //这张图片还没被选择
        [self.allImagesArr addObject:image];
        [self.allIndexPathsArr addObject:self.currentIndexPath];
        //self.collectionView就是PUCollectionView 获取当前正在显示的cell  然后调用内部方法 添加右上角的标注图片
        UIView *cell = [self.collectionView cellForItemAtIndexPath:self.currentIndexPath];
        [self addIndicatorButton:cell];
    }
}

/**
 *  将图片从保存所有图片的数组中删除 并且在图片的右上角的勾选的图片标注 也移除掉
 *
 *  @param image 被取消选中的图片
 */
-(void)removeCurrentImage:(UIImage *)image {
    NSInteger currentImageIndex = [self indexPathIsInAllIndexPathsArrWithIndexPath:self.currentIndexPath];
    //如果该图片的index 不等于最大值 则表明存在于数组中 然后就可以移除此图片了
    if (currentImageIndex != NSIntegerMax) {
        //从选择数组中 删除对应的图片 和 indexPath
        [self.allImagesArr removeObjectAtIndex:currentImageIndex];
        [self.allIndexPathsArr removeObjectAtIndex:currentImageIndex];
        //移除cell右上角的标注图片
        UIView *cell = [self.collectionView cellForItemAtIndexPath:self.currentIndexPath];
        [self removeIndicatorButton:cell];
    }
}

#pragma mark - 公开属性
-(NSArray<UIImage *> *)imagesArr {
    return self.allImagesArr.copy;
}

#pragma mark - 懒加载
-(Class)PUPhotoView {
    return NSClassFromString(@"PUPhotoView");
}

-(Class)PUCollectionView {
    return NSClassFromString(@"PUCollectionView");
}

-(NSMutableArray<NSIndexPath *> *)allIndexPathsArr {
    if (_allIndexPathsArr == nil) {
        _allIndexPathsArr = [NSMutableArray array];
    }
    return _allIndexPathsArr;
}

-(NSMutableArray<UIImage *> *)allImagesArr {
    if (_allImagesArr == nil) {
        _allImagesArr = [NSMutableArray array];
    }
    return _allImagesArr;
}

-(UIView *)bottomView {
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc] init];
    }
    return _bottomView;
}

-(UIButton *)doneButton {
    if (_doneButton == nil) {
        _doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
    }
    return _doneButton;
}

@end

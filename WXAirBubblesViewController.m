//
//  WXAirBubblesViewController.m
//  dope
//
//  Created by apple on 2019/5/22.
//  Copyright © 2019 Dope. All rights reserved.
//

#import "WXAirBubblesViewController.h"
#import "AirBubblesModel.h"
#import "JHCollectionViewFlowLayout.h"
#import "WXAirBubblesCollectionViewCell.h"
#import "CommitResourceVC.h"
#import "EOShareView.h"
#import <UMShare/UMShare.h>
#import "EOShareSucessView.h"
#define kMargin kSCRATIO(4)

@interface WXAirBubblesViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong)UICollectionView *airBubblesCollectionView;
@property (nonatomic, strong)AirBubblesModel *airBubblesModel;
@property (nonatomic) CGRect rect;
@property (nonatomic, strong)AirBubblesModelDataBubbleList *airBubblesModelDataBubbleListModel;

@end

@implementation WXAirBubblesViewController
{
    UIView *testView;
    UIView *testView0;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _rect = CGRectMake(0, 0, kSCRATIO(325), HEIGHT);
    
    
    [self setUI];
    [self bubbleData];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.view.backgroundColor=kColorFromRGBHex(0x171226);
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    UIButton *backButton = [[UIButton alloc] init];
    [backButton setImage:[UIImage imageNamed:@"withtBack"] forState:UIControlStateNormal];
    [backButton addTarget: self action: @selector(backAction) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(kSCRATIO(7));
        make.top.mas_offset(kSCRATIO(7)+kStatusBarHeight);
        make.width.height.mas_offset(kSCRATIO(31));
        
    }];
    UIButton *rightButton = [UIButton CreatButtontext:@"保存" image:nil Font:[UIFont systemFontOfSize:kSCRATIO(16)] Textcolor:ColorFFE131];
    [rightButton addTarget: self action: @selector(rightClick) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview:rightButton];
    [rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(kSCRATIO(-20));
        make.centerY.equalTo(backButton);
        make.width.mas_offset(kSCRATIO(34));
        make.height.mas_offset(kSCRATIO(20));
        
    }];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
-(void)backAction{
    if (self.isBackRoot) {
        [self.navigationController popToRootViewControllerAnimated:NO];

    }else{
        [self.navigationController popViewControllerAnimated:NO];

    }
    
}
-(void)rightClick{
    if (self.airBubblesModelDataBubbleListModel) {
        [[NetWorkManager sharedManager]postData:@"oauth/oauth-rest/choose-bubble" parameters:@{@"bubbleId":self.airBubblesModelDataBubbleListModel.bubbleId,@"bubbleUrl":self.airBubblesModelDataBubbleListModel.bubbleUrl} success:^(NSURLSessionDataTask *task, id responseObject) {
            [self backAction];
            Context.currentUser.bubbleUrl=self.airBubblesModelDataBubbleListModel.bubbleUrl;
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
    }else{
        [MessageAlertView showErrorMessage:@"请选择你喜欢的表情"];
    }
    
}
-(void)bubbleData{
    [[NetWorkManager sharedManager]getData:@"oauth/oauth-rest/user-bubble-list" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        self.airBubblesModel=[AirBubblesModel modelWithJson:responseObject];
        NSMutableArray *mutableArray=[self.airBubblesModel.data mutableCopy];
        NSMutableArray *airBubblesModelData2=((AirBubblesModelData *)self.airBubblesModel.data[1]).bubbleList.mutableCopy;
        [airBubblesModelData2 insertObjects:((AirBubblesModelData *)self.airBubblesModel.data[0]).bubbleList atIndex:0];
        ((AirBubblesModelData *)self.airBubblesModel.data[1]).bubbleList=airBubblesModelData2;
        [mutableArray removeObjectAtIndex:0];
        self.airBubblesModel.data=mutableArray;
        [self.airBubblesCollectionView reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
}
- (CGFloat)fixSlitWith:(CGRect)rect colCount:(CGFloat)colCount space:(CGFloat)space {
    CGFloat totalSpace = (colCount - 1) * space;//总共留出的距离
    CGFloat itemWidth = (rect.size.width - totalSpace) / colCount;// 按照真实屏幕算出的cell宽度 （iPhone6 375*667）93.75
    CGFloat fixValue = 1 / [UIScreen mainScreen].scale; //(6为1px=0.5pt,6Plus为3px=1pt)1个点有两个像素
    CGFloat realItemWidth = floor(itemWidth) + fixValue;//取整加fixValue  floor:如果参数是小数，则求最大的整数但不大于本身.
    if (realItemWidth < itemWidth) {// 有可能原cell宽度小数点后一位大于0.5
        realItemWidth += fixValue;
    }
    
    CGFloat realWidth = colCount * realItemWidth + totalSpace;//算出屏幕等分后满足`1px=0.5pt`实际的宽度
    CGFloat pointX = (realWidth - rect.size.width) / 2; //偏移距离
    rect.origin.x = -pointX;//向左偏移
    rect.size.width = realWidth;
    _rect = rect;
    return realItemWidth;//(rect.size.width - totalSpace) / colCount; //每个cell的真实宽度
}

-(void)setUI{
  
    UIImageView *mineImageView=[UIImageView new];
    mineImageView.contentMode =UIViewContentModeScaleAspectFill;
    mineImageView.userInteractionEnabled=YES;
    [self.view addSubview:mineImageView];
    [mineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.mas_offset(kSCRATIO(54)+kStatusBarHeight);
        make.height.width.mas_offset(kSCRATIO(116));
    }];
    mineImageView.tag=1006;
    [mineImageView layoutIfNeeded];
    [mineImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMG_URL,Context.currentUser.userAvatar]] placeholderImage:[UIImage imageNamed:@"headImage1"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        mineImageView.image =[UtilTools imageWithRoundCorner:mineImageView.image cornerRadius:kSCRATIO(58) size:CGSizeMake(kSCRATIO(116), kSCRATIO(116))];

    }];
//    if ([UtilTools isBlankString:Context.currentUser.bubbleUrl]) {
//        [mineImageView setPendantImage:[UIImage imageNamed:@"defaultBubbles"]];
//
//    }else{
//        [mineImageView setPentUrl:Context.currentUser.bubbleUrl];
//
//    }
//    [mineImageView pp_pendantLeft:kSCRATIO(75) bottom:kSCRATIO(-71) width:kSCRATIO(70) height:kSCRATIO(70)];
    UIButton *defaultButton=[UIButton CreatButtontext:@"恢复默认" image:nil Font:[UIFont systemFontOfSize:kSCRATIO(11)] Textcolor:ColorWhite];
    [self.view addSubview:defaultButton];
    defaultButton.layer.cornerRadius=kSCRATIO(15);
    defaultButton.layer.masksToBounds=YES;
    defaultButton.layer.borderColor=ColorWhite.CGColor;
    defaultButton.layer.borderWidth=1;
    [defaultButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(kSCRATIO(-20));
        make.top.equalTo(mineImageView.mas_bottom).offset(kSCRATIO(9));
        make.width.mas_offset(kSCRATIO(70));
        make.height.mas_offset(kSCRATIO(30));
        
    }];
    [defaultButton addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithActionBlock:^(id  _Nonnull sender) {
//        [mineImageView setPendantImage:[UIImage imageNamed:@"defaultBubbles"]];
       self.airBubblesModelDataBubbleListModel=[AirBubblesModelDataBubbleList new];
        self.airBubblesModelDataBubbleListModel.bubbleUrl=@"";
        self.airBubblesModelDataBubbleListModel.bubbleId=[NSNumber numberWithInteger:0];

       
        
    }]];
    UIView *whiteView=[UIView new];
    whiteView.backgroundColor=ColorWhite;
    [self.view addSubview:whiteView];
    [whiteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(defaultButton.mas_bottom).offset(kSCRATIO(15));
        make.left.right.bottom.mas_offset(0);
        
    }];
    [whiteView layoutIfNeeded];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0, 0, WIDTH, whiteView.height) byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(30,30)];
    //创建 layer
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = CGRectMake(0, 0, WIDTH, whiteView.height);
    //赋值
    maskLayer.path = maskPath.CGPath;
    whiteView.layer.mask = maskLayer;
    [whiteView addSubview:self.airBubblesCollectionView];
    [self.airBubblesCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(kSCRATIO(20));
        make.right.mas_offset(kSCRATIO(-21));
        
        make.bottom.mas_offset(-BOTTOM_HEIGHT);
        make.top.mas_offset(0);
        
    }];
}
#pragma mark UICollectionViewDataSource
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return CGSizeMake(WIDTH, kSCRATIO(31));
    }
    return CGSizeMake(WIDTH, kSCRATIO(20));
    
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headView;
    if (!headView) {
        headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MyFoot" forIndexPath:indexPath];
        
        headView.backgroundColor=ColorWhite;
    }
    
    return headView;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    WXAirBubblesCollectionViewCell *cell1=(WXAirBubblesCollectionViewCell *)cell;

    AirBubblesModelData *airBubblesModelData    =    self.airBubblesModel.data[indexPath.section];
    if ([airBubblesModelData.isUnLock boolValue]) {

        if ([cell respondsToSelector:@selector(tintColor)]) {
            
            
            CGFloat cornerRadius = 30;
            
            cell.backgroundColor = UIColor.clearColor;
            
            CAShapeLayer *layer = [[CAShapeLayer alloc] init];
            
            CGMutablePathRef pathRef = CGPathCreateMutable();
            
            CGRect bounds = CGRectInset(cell.bounds, 0, 0);
            
            if (indexPath.row==0&&indexPath.section==0) {
                
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
                
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), 0);
                
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
                layer.path = pathRef;
                
                CFRelease(pathRef);
                
                //颜色修改
                
                layer.fillColor = ColorWhite.CGColor;
                
                UIView *testView = [[UIView alloc] initWithFrame:bounds];
                [testView.layer insertSublayer:layer atIndex:0];
                testView.backgroundColor = kColorFromARGBHex(0x000000, 0.7);

                testView0=testView;
                                    cell1.testView.hidden=YES;

                cell.backgroundView = testView0;
                
                return;
            }
           else if (indexPath.row == 0||(indexPath.row==1&&indexPath.section==0)) {
                
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
                
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
                
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), 0);
                
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
                
                
            }else if (indexPath.row == 3) {
                
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
                
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), 0);
                
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
                
                
            }
            else if (indexPath.row == 4&&indexPath.section!=0) {
                
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
                
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
                
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), 0);
                
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
                
                
            }
            else if (indexPath.row == [collectionView numberOfItemsInSection:indexPath.section]-1) {
                
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
                
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), 0);
                
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
                
            }
            else if (indexPath.row==4&&indexPath.section==0) {

                
                CGPathMoveToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxX(bounds));
                
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMinX(bounds), CGRectGetMinY(bounds), cornerRadius);

                
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMinY(bounds), cornerRadius);
                
                
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
                layer.path = pathRef;
                
                CFRelease(pathRef);
                
                //颜色修改
                
                layer.fillColor = kColorFromARGBHex(0x000000, 0.7).CGColor;
             
                WXAirBubblesCollectionViewCell *cell1=(WXAirBubblesCollectionViewCell *)cell;
                for (CALayer *layer in cell1.testView.layer.sublayers) {
                    if (layer.superlayer) {
                        [layer removeFromSuperlayer];
                        
                    }
                }
                [cell1.testView.layer insertSublayer:layer above: 0];
                return;
                
            }
            else {
                
                CGPathAddRect(pathRef, nil, bounds);
                
                
            }
            
            layer.path = pathRef;
            
            CFRelease(pathRef);
            
            //颜色修改
            cell.backgroundView = nil;

            layer.fillColor = kColorFromARGBHex(0x000000, 0.7).CGColor;
        
            for (CALayer *layer in cell1.testView.layer.sublayers) {
                if (layer.superlayer) {
                    [layer removeFromSuperlayer];
                    
                }
            }
            [cell1.testView.layer insertSublayer:layer above: 0];
            cell1.testView.hidden=NO;

   
        }
    }else{
        WXAirBubblesCollectionViewCell *cell1=(WXAirBubblesCollectionViewCell *)cell;

        cell1.testView.hidden=YES;
    }
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.airBubblesModel.data.count;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.airBubblesModel.data[section].bubbleList.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    AirBubblesModelDataBubbleList *airBubblesModelDataBubbleList=   self.airBubblesModel.data[indexPath.section].bubbleList[indexPath.row];
    
    WXAirBubblesCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([WXAirBubblesCollectionViewCell class]) forIndexPath:indexPath];
   
    [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMG_URL,airBubblesModelDataBubbleList.bubbleUrl]] placeholderImage:[UIImage imageNamed:@"headImage1"]];;
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    AirBubblesModelData *airBubblesModelData=self.airBubblesModel.data[indexPath.section];
    if (![airBubblesModelData.isUnLock boolValue]||(indexPath.section==0&&indexPath.row==0)) {
        AirBubblesModelDataBubbleList *airBubblesModelDataBubbleList=   self.airBubblesModel.data[indexPath.section].bubbleList[indexPath.row];
        self.airBubblesModelDataBubbleListModel=airBubblesModelDataBubbleList;
        
//        UIImageView *image1006=[self.view viewWithTag:1006];
//        [image1006 setPentUrl:airBubblesModelDataBubbleList.bubbleUrl];
    }
  
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.width/4, collectionView.width/4);
}



- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0;
    
}
#pragma  mark 懒加载
-(UICollectionView *)airBubblesCollectionView{
    if (!_airBubblesCollectionView) {
        JHCollectionViewFlowLayout *jhFlowLayout = [[JHCollectionViewFlowLayout alloc] init];
        [jhFlowLayout setFrameblock:^(CGRect rect, NSInteger section) {
            AirBubblesModelData *airBubblesModelData    =    self.airBubblesModel.data[section];
                if ([airBubblesModelData.isUnLock boolValue]) {

                UIView *view=[[UIView alloc]initWithFrame:rect];
                view.top-=kSCRATIO(10);
                view.height+=kSCRATIO(20);
                view.left+=(WIDTH-kSCRATIO(41))/4;
                view.width-=(WIDTH-kSCRATIO(41))/4;

                view.tag=1010+section;
                [_airBubblesCollectionView addSubview:view];
                UIImageView *image=[UIImageView new];
                image.image=[UIImage imageNamed:@"lock"];
                
                [view addSubview:image];
                
                UILabel *label=[UILabel CreatLabeltext:@"分享到朋友圈即可解锁" Font:[UIFont fontWithName:@"PingFangSC-Semibold" size: kSCRATIO(16)] Textcolor:ColorWhite textAlignment:NSTextAlignmentCenter];
                [view addSubview:label];
                [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.width.equalTo(view);
                    make.height.mas_offset(kSCRATIO(22));
                    make.centerX.equalTo(self.view);

                }];
                [image mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.view);
                    make.width.height.mas_offset(kSCRATIO(48));
                    make.bottom.equalTo(label.mas_top).mas_offset(kSCRATIO(-13));
                }];
                UIButton *button=[UIButton CreatButtontext:@"邀请好友解锁" image:nil Font:[UIFont fontWithName:@"PingFangSC-Semibold" size: kSCRATIO(13)] Textcolor:ColorWhite];
                [view addSubview:button];
                button.layer.cornerRadius=kSCRATIO(19);
                button.layer.masksToBounds=YES;
                button.tag=10000+section;
                button.backgroundColor=kColorFromRGBHex(0x00D0A2);
                [button mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.view);
                    make.width.mas_offset(kSCRATIO(120));
                    make.height.mas_offset(kSCRATIO(38));
                    make.top.equalTo(label.mas_bottom).mas_offset(kSCRATIO(16));
                    
                }];
                
                [button addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithActionBlock:^(id  _Nonnull sender) {
                    switch (button.tag) {
                        case 10000:
                        {
                            UIView *bgV =  [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
                            
                            bgV.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
                            [[UIApplication sharedApplication].keyWindow addSubview:bgV];
                            UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithActionBlock:^(id  _Nonnull sender) {
                                [bgV removeFromSuperview];
                            }];
                            [bgV addGestureRecognizer:tap];
                            EOShareView *shareView = [[EOShareView alloc] initWithFrame:CGRectMake(kSCRATIO(0), HEIGHT, WIDTH, kSCRATIO(165)+BOTTOM_HEIGHT) count:4];
                            shareView.cancelBlock = ^{
                                [bgV removeFromSuperview];
                            };
                            
                            shareView.shareBlock = ^(NSInteger index) {
                                UMSocialPlatformType type = UMSocialPlatformType_UnKnown;
                                if (index == 0) {
                                    type = UMSocialPlatformType_QQ;
                                }
                                if (index == 1) {
                                    type = UMSocialPlatformType_Qzone;
                                }
                                if (index == 2) {
                                    type = UMSocialPlatformType_WechatSession;
                                }
                                if (index == 3) {
                                    type = UMSocialPlatformType_WechatTimeLine;
                                }
                                if (index==4) {
                                    type = UMSocialPlatformType_Sina;
                                    
                                }
                                NSString *urlKey = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMG_URL,Context.currentUser.userAvatar]]];
                                UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlKey];
                                if (!image) {
                                    image = [UIImage imageNamed:@"login_Logo.png"];
                                }
                                UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
                                UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:@"Hey，分享一个社交APP给你" descr:@"最放肆最有趣的人儿都在这儿" thumImage:image];
                                shareObject.webpageUrl = @"http://www.dopesns.com/";
                                
                                messageObject.shareObject = shareObject;
                                    [[UMSocialManager defaultManager] shareToPlatform:type messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
                                        if (error) {
                                            [MessageAlertView showErrorMessage:@"分享失败"];
                                        } else {
                                            [MessageAlertView showErrorMessage:@"分享成功"];
                                            
                                            [[NetWorkManager sharedManager]postData:@"points/points-rest/share-success" parameters:@{@"circleId":@"-1"} success:^(NSURLSessionDataTask *task, id responseObject) {
                                                if ([[NSString stringWithFormat:@"%@",responseObject[@"data"]] isEqualToString:@"1"]) {
                                                    [self bubbleData];

                                                
                                                UIView *bgV = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
                                                bgV.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
                                                [[UIApplication sharedApplication].keyWindow addSubview:bgV];
                                                
                                                EOShareSucessView *notiV = [[EOShareSucessView alloc] initWithFrame:CGRectMake(kSCRATIO(32), HEIGHT, kSCRATIO(305), kSCRATIO(330))];
                                                
                                               
                                                    notiV.icon.image=[UIImage imageNamed:@"ShareSuccess"];
                                                    notiV.titleLabel.text=@"分享成功";
                                                    notiV.contentL.text=@"成功获得一组头像气泡";
                                                    [notiV.action setTitle:@"好的" forState:0];

                                                __weak EOShareSucessView *weakView = notiV;
                                                notiV.sureBlock = ^{
                                                    [bgV removeFromSuperview];
                                                    [weakView removeFromSuperview];
                                                    
                                                };
                                                [[UIApplication sharedApplication].keyWindow addSubview:notiV];
                                                
                                                [UIView animateWithDuration:0.2f animations:^{
                                                    notiV.centerX = WIDTH * 0.5;
                                                    
                                                    notiV.centerY = HEIGHT * 0.5;
                                                }];
                                                
                                                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
                                                    [bgV removeFromSuperview];
                                                    [notiV removeFromSuperview];
                                                }];
                                                tap.numberOfTapsRequired = 1;
                                                tap.numberOfTouchesRequired = 1;
                                                [bgV addGestureRecognizer:tap];
                                                }
                                            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                
                                            }];
                                        }
                                        
                                    }];
                               
                                [bgV removeFromSuperview];
                                
                            };
                            [bgV addSubview:shareView];
                            
                            [UIView animateWithDuration:0.15 animations:^{
                                shareView.bottom = HEIGHT+BOTTOM_HEIGHT;
                                
                            }];
                        }
                            break;
                        case 10001:
                        {
                            CommitResourceVC *comment=[CommitResourceVC new];
                           
                            [self.navigationController pushViewController:comment animated:YES];
                        }
                            break;
                        case 10002:
                        {
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                               
                                dispatch_sync(dispatch_get_main_queue(), ^
                                              {
                                                  
                                                  self.tabBarController.selectedIndex = 2;
                                                  self.tabBarController.tabBar.hidden =NO;//因为我需要跳转那页把Tab Bar 隐藏了
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"tabChange" object:nil];

                                                  [self.navigationController popToRootViewControllerAnimated:YES];//回到根目录
                                                  
                                                  
                                                  
                                              });
                            });
                            
                            
                            
                        }
                            break;
                        default:
                            break;
                    }
                }]];
                switch ([airBubblesModelData.bubbleType integerValue]) {
                    case 2:
                    {
                        label.text=@"分享到朋友圈即可解锁";
                        [button setTitle:@"邀请好友解锁" forState:0];
                    }
                        break;
                    case 3:
                    {
                        label.text=@"发布5条以上内容即可解锁";
                        [button setTitle:@"立即发布内容" forState:0];
                    }
                        break;
                    case 4:
                    {
                        label.text=@"拥有10个dope好友即可解锁";
                        [button setTitle:@"发现更多好友" forState:0];
                    }
                        break;
                    default:
                        break;
                }
                }else{
                    UIView *view=[self.view viewWithTag:1010+section];
                    [view removeFromSuperview];
                }
            
        }];
        _airBubblesCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:jhFlowLayout];
        
        _airBubblesCollectionView.delegate=self;
        _airBubblesCollectionView.dataSource=self;
        _airBubblesCollectionView.showsVerticalScrollIndicator=NO;
        [_airBubblesCollectionView registerClass:[WXAirBubblesCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([WXAirBubblesCollectionViewCell class])];
        [_airBubblesCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MyFoot"];
        _airBubblesCollectionView.backgroundColor=ColorWhite;
        
    }
    return _airBubblesCollectionView;
}


@end

//
//  UIView+Pendant.m
//  AnimationEngineExample
//
//  Created by apple on 2019/5/20.
//  Copyright © 2019 Intuit. All rights reserved.
//

#import "UIView+Pendant.h"
#import <objc/runtime.h>
#import "UIView+Chain.h"

#import <INTUAnimationEngine/INTUAnimationEngine.h>
static NSString *const Pendant = @"Pendant";
static NSString *const pendantblock1 = @"pendantblock";

static const CGFloat kAnimationDuration = 2.0; // in seconds

@implementation UIView (Pendant)
@dynamic pentUrl;

@dynamic pendantImage;

@dynamic pendantImageView;
CGFloat INTUInterpolateCGFloat(CGFloat start, CGFloat end, CGFloat progress)
{
    return start * (1.0 - progress) + end * progress;
}
CGPoint INTUInterpolateCGPoint(CGPoint start, CGPoint end, CGFloat progress)
{
    CGFloat x = INTUInterpolateCGFloat(start.x, end.x, progress);
    CGFloat y = INTUInterpolateCGFloat(start.y, end.y, progress);
    return CGPointMake(x, y);
}
CGAffineTransform  GetCGAffineTransformRotateAroundPoint(float centerX, float centerY ,float x ,float y ,float angle)
{
    x = x - centerX; //计算(x,y)从(0,0)为原点的坐标系变换到(CenterX ，CenterY)为原点的坐标系下的坐标
    y = y - centerY; //(0，0)坐标系的右横轴、下竖轴是正轴,(CenterX,CenterY)坐标系的正轴也一样
    
    CGAffineTransform  trans = CGAffineTransformMakeTranslation(x, y);
    trans = CGAffineTransformRotate(trans,angle);
    trans = CGAffineTransformTranslate(trans,-x, -y);
    return trans;
}
-(void)setPentUrl:(NSString *)pentUrl{
    if (![self viewWithTag:106]) {
        [self layout];
        
    }
    UIButton *demoImageView1=[self viewWithTag:106];
    demoImageView1.imageView.contentMode=UIViewContentModeScaleAspectFit;
    [demoImageView1 setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMG_URL,pentUrl]] forState:0 placeholder:[UIImage imageNamed:@"placeHolder"]];
    
}
-(void)setPendantImage:(UIImage *)pendantImage{
    
    if (![self viewWithTag:106]) {
        [self layout];
        
    }
    UIButton *demoImageView1=[self viewWithTag:106];
    [demoImageView1 setImage:pendantImage forState:0];
    
    
    
}
-(void)layout{
    [self lazyLoadPendantImageView];
    
    [INTUAnimationEngine animateWithDuration:kAnimationDuration
                                       delay:0.0
                                      easing:INTUEaseInOutQuadratic
                                     options:INTUAnimationOptionRepeat | INTUAnimationOptionAutoreverse
                                  animations:^(CGFloat progress) {
                                      float centerX = self.pendantImageView.bounds.size.width/2;
                                      float centerY = self.pendantImageView.bounds.size.height/2;
                                      float x = self.pendantImageView.bounds.size.width;
                                      float y = self.pendantImageView.bounds.size.height;
                                      CGFloat rotationAngle = INTUInterpolateCGFloat(-M_PI_4 / 20, M_PI_4 / 20, progress);
                                      CGAffineTransform trans = GetCGAffineTransformRotateAroundPoint(x,centerY ,centerX ,y ,rotationAngle);
                                      self.pendantImageView.transform = CGAffineTransformIdentity;
                                      self.pendantImageView.transform = trans;
                                    
                                  }
                                  completion:^(BOOL finished) {
                                    
                                  }];
   
}
-(void)demoImageViewClick{
    if (self.pendantblock) {
        self.pendantblock();
    }
    UIButton *demoImageView1=[self viewWithTag:106];
    [UIView animateWithDuration:1 animations:^{
        demoImageView1.transform = CGAffineTransformMakeScale(1.65, 1.65);
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:1 animations:^{
            demoImageView1.transform = CGAffineTransformMakeScale(1, 1);
        } completion:^(BOOL finished) {
            
        }];
        
    }];
    
    
}
- (void)lazyLoadPendantImageView
{
    if (!self.pendantImageView) {
        self.pendantImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.height/4*3, self.frame.size.height/4*3)];
        self.pendantImageView.center = CGPointMake(self.frame.size.width, 0);
        self.pendantImageView.image=[UIImage imageNamed:@"pendantImage"];
        [self addSubview:self.pendantImageView];
        self.pendantImageView.userInteractionEnabled=YES;
        self.pendantImageView.ableRespose=YES;

        UIButton *   demoImageView1=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.pendantImageView.width*0.4, self.pendantImageView.height*0.4)];
        
        [self.pendantImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(demoImageViewClick)]];
        
        demoImageView1.tag=106;
        demoImageView1.clickArea=@"4";
        demoImageView1.center=CGPointMake(self.pendantImageView.frame.size.width*0.55, self.pendantImageView.frame.size.height*0.45);
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(demoImageViewClick)];
        tap.delegate=self;
        [demoImageView1 addGestureRecognizer:tap];
        self.pendantImageView.ableRespose=YES;
       demoImageView1.ableRespose=YES;

        [self.pendantImageView addSubview:demoImageView1];
    }
}
- (void)pp_pendantLeft:(CGFloat )left bottom:(CGFloat ) bottom width :(CGFloat ) width height :(CGFloat ) height  {
  
    [self.pendantImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(left);
        make.bottom.mas_offset(bottom);
        make.width.mas_offset(width);
        make.height.mas_offset(height);
        
    }];
    [self.pendantImageView layoutIfNeeded];
    UIButton *demoImageView1=[self viewWithTag:106];
    demoImageView1.width=self.pendantImageView.width*0.4;
    demoImageView1.height=self.pendantImageView.height*0.4;
    demoImageView1.centerX=self.pendantImageView.width*0.55;
    demoImageView1.centerY=self.pendantImageView.height*0.45;
    demoImageView1.layer.cornerRadius=demoImageView1.width/2;
    demoImageView1.layer.masksToBounds=YES;
}


- (UIImageView *)pendantImageView
{
    return objc_getAssociatedObject(self, &Pendant);
}
-(void)setPendantImageView:(UIImageView *)pendantImageView{
    objc_setAssociatedObject(self, &Pendant, pendantImageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}
-(Pendantblock)pendantblock{
    return objc_getAssociatedObject(self, &pendantblock1);
    
}
-(void)setPendantblock:(Pendantblock)pendantblock{
    objc_setAssociatedObject(self, &pendantblock1, pendantblock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}
- (void)setAbleRespose:(BOOL)ableRespose {
    objc_setAssociatedObject(self, @selector(ableRespose), @(ableRespose), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)ableRespose {
    return objc_getAssociatedObject(self, _cmd) != nil ? [objc_getAssociatedObject(self, _cmd) boolValue] : NO;
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self];
    if (CGRectContainsPoint(self.bounds, touchPoint)) {
        return YES;    }
    return NO;
}


@end

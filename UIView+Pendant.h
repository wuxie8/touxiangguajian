//
//  UIView+Pendant.h
//  AnimationEngineExample
//
//  Created by apple on 2019/5/20.
//  Copyright © 2019 Intuit. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^Pendantblock)(void);

@interface UIView (Pendant)<UIGestureRecognizerDelegate>
@property (nonatomic, assign) BOOL ableRespose;

@property (nonatomic, strong)UIImageView  *pendantImageView;
@property (nonatomic, strong)UIImage *pendantImage;
@property (nonatomic, strong)Pendantblock pendantblock;
@property (nonatomic, strong)NSString *pentUrl;
- (void)pp_pendantLeft:(CGFloat  )left bottom:(CGFloat ) bottom width :(CGFloat ) width height :(CGFloat ) height ;

@end

NS_ASSUME_NONNULL_END

//
//  WXAirBubblesViewController.h
//  dope
//
//  Created by apple on 2019/5/22.
//  Copyright © 2019 Dope. All rights reserved.
//

#import "BaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXAirBubblesViewController : BaseVC
@property (copy, nonatomic) void(^foundblock)(void);
@property (nonatomic, assign)BOOL isBackRoot;

@end

NS_ASSUME_NONNULL_END

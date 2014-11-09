//
//  MQViewController.h
//  Listings
//
//  Created by Dan Kwon on 9/5/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+MQImageEffects.h"
#import "UIView+MQViewAdditions.h"
#import "MQLoadingIndicator.h"
#import "MQProfile.h"
#import "MQLocationManager.h"
#import "Config.h"
#import "MQNotificationView.h"
#import "SignalCheck.h"


@interface MQViewController : UIViewController

@property (strong, nonatomic) MQLoadingIndicator *loadingIndicator;
@property (strong, nonatomic) MQNotificationView *notificationView;
@property (strong, nonatomic) MQProfile *profile;
@property (strong, nonatomic) UIView *fullImageView;
@property (strong, nonatomic) UIImageView *fullImage;
@property (strong, nonatomic) SignalCheck *signalCheck;

- (UIView *)baseView:(BOOL)navCtr;
- (void)showAlertWithtTitle:(NSString *)title message:(NSString *)msg;
- (void)showAlertWithOptions:(NSString *)title message:(NSString *)msg;
- (void)addNavigationTitleView;
- (void)shiftUp:(CGFloat)distance;
- (void)shiftBack:(CGFloat)origin;
- (void)addCustomBackButton;
- (void)setupFullImage:(UIView *)view;
- (void)exitFullImage:(UIButton *)btn;
- (void)viewFullImage:(UIImage *)image;
- (void)showNotification:(NSString *)title withMessage:(NSString *)message;
- (BOOL)checkConnection;
@end

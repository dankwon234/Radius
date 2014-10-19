//
//  MQLoadingIndicator.h
//  Listings
//
//  Created by Dan Kwon on 9/5/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MQLoadingIndicator : UIView

@property (strong, nonatomic) UILabel *lblTitle;
@property (strong, nonatomic) UILabel *lblMessage;
- (void)stopLoading;
- (void)startLoading;
@end

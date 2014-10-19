//
//  UIImage+MQImageEffects.h
//  Listings
//
//  Created by Dan Kwon on 9/5/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MQImageEffects)

- (UIImage *)applyBlurOnImage:(CGFloat)blurRadius;
- (UIImage *)convertImageToGrayScale;
- (UIImage *)imageByCropping:(CGRect)rect;
@end

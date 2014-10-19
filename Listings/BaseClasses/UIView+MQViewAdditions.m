//
//  UIView+MQViewAdditions.m
//  Listings
//
//  Created by Dan Kwon on 9/14/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "UIView+MQViewAdditions.h"

@implementation UIView (MQViewAdditions)


- (UIImage *)screenshot
{
    CGRect bounds = self.bounds;
    
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 0.0f);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSLog(@"SCREENSHOT: %.2f", image.size.height);
    return image;
}


@end

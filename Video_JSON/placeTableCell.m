//
//  placeTableCell.m
//  Video_JSON
//
//  Created by Nathan Poag on 12/22/14.
//  Copyright (c) 2014 Nathan Poag. All rights reserved.
//

#import "placeTableCell.h"

@implementation placeTableCell
@synthesize placeName = _placeName;
@synthesize placeDescription = _placeDescription;
@synthesize placeImage = _placeImage;
@synthesize isOpenLabel = _isOpenLabel;
@synthesize displayingHours = _displayingHours;

- (void)addBlurToView:(UIView *)view {
    UIView *blurView = nil;
    
    if([UIBlurEffect class]) { // iOS 8
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurView.frame = view.frame;
        
    } else { // workaround for iOS 7
        blurView = [[UIToolbar alloc] initWithFrame:view.bounds];
    }
    
    [blurView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [view addSubview:blurView];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[blurView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(blurView)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[blurView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(blurView)]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    UIView *view = [self.contentView viewWithTag:101];
    CATransition *animation = [CATransition animation];
    animation.duration = 0.2f;
    animation.type = kCATransitionFade;
    [view.layer removeAllAnimations];
    [view.layer addAnimation: animation forKey:@"deletingFade"];
}

@end

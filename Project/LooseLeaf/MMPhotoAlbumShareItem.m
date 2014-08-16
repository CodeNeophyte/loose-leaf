//
//  MMPhotoAlbumShareItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/9/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPhotoAlbumShareItem.h"
#import "MMImageViewButton.h"
#import "Mixpanel.h"
#import "Constants.h"
#import "NSThread+BlockAdditions.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation MMPhotoAlbumShareItem{
    MMImageViewButton* button;
}

@synthesize delegate;

-(id) init{
    if(self = [super init]){
        button = [[MMImageViewButton alloc] initWithFrame:CGRectMake(0,0, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [button setImage:[UIImage imageNamed:@"photoalbum"]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateButtonGreyscale)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
        
        [button addTarget:self action:@selector(performShareAction) forControlEvents:UIControlEventTouchUpInside];
        
        [self updateButtonGreyscale];
    }
    return self;
}

-(MMSidebarButton*) button{
    return button;
}

-(void) performShareAction{
    [delegate mayShare:self];
    // if a popover controller is dismissed, it
    // adds the dismissal to the main queue async
    // so we need to add our next steps /after that/
    // so we need to dispatch async too
    dispatch_async(dispatch_get_main_queue(), ^{
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
        UIImage* image = self.delegate.imageToShare;
        [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
            NSString* strResult = @"Failed";
            if (error) {
                // TODO: error handling
                [self animateToSuccess:NO];
            } else {
                strResult = @"Success";
                [self animateToSuccess:YES];
                [[[Mixpanel sharedInstance] people] increment:kMPNumberOfExports by:@(1)];
            }
            [[Mixpanel sharedInstance] track:kMPEventExport properties:@{kMPEventExportPropDestination : @"PhotoAlbum",
                                                                         kMPEventExportPropResult : strResult}];
            [button setNeedsDisplay];
        }];
    });
}

-(void) animateToSuccess:(BOOL)succeeded{
    CGPoint center = CGPointMake(button.bounds.size.width/2, button.bounds.size.height/2);
    
    CAShapeLayer *circle=[CAShapeLayer layer];
    CGFloat radius = button.drawableFrame.size.width / 2;
    circle.path=[UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:2*M_PI*0-M_PI_2 endAngle:2*M_PI*1-M_PI_2 clockwise:YES].CGPath;
    circle.fillColor=[UIColor clearColor].CGColor;
    circle.strokeColor=[UIColor whiteColor].CGColor;
    circle.lineWidth=radius*2;
    circle.strokeEnd = 0;
    
    
    CAShapeLayer *mask=[CAShapeLayer layer];
    mask.path=[UIBezierPath bezierPathWithArcCenter:center radius:radius-2 startAngle:2*M_PI*0-M_PI_2 endAngle:2*M_PI*1-M_PI_2 clockwise:YES].CGPath;

    CAShapeLayer *mask2=[CAShapeLayer layer];
    mask2.path=[UIBezierPath bezierPathWithArcCenter:center radius:radius-2 startAngle:2*M_PI*0-M_PI_2 endAngle:2*M_PI*1-M_PI_2 clockwise:YES].CGPath;
    
    circle.mask = mask;
    
    UILabel* label = [[UILabel alloc] initWithFrame:button.bounds];
    
    [button.layer addSublayer:circle];

    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration=.4;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion=NO;
    animation.fromValue=@(0);
    animation.toValue=@(1);
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [circle addAnimation:animation forKey:@"drawCircleAnimation"];
    
    [[NSThread mainThread] performBlock:^{
        if(succeeded){
            label.text = @"\u2714";
        }else{
            label.text = @"\u2718";
        }
        label.font = [UIFont fontWithName:@"ZapfDingbatsITC" size:30];
        label.textAlignment = NSTextAlignmentCenter;
        label.alpha = 0;
        [button addSubview:label];
        [UIView animateWithDuration:.3 animations:^{
            label.alpha = 1;
        } completion:^(BOOL finished){
            [delegate didShare:self];
            [[NSThread mainThread] performBlock:^{
                [label removeFromSuperview];
                [circle removeAnimationForKey:@"drawCircleAnimation"];
                [circle removeFromSuperlayer];
            } afterDelay:.5];
        }];
    } afterDelay:.3];
}

-(BOOL) isAtAllPossible{
    return YES;
}

#pragma mark - Notification

-(void) updateButtonGreyscale{
    if([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized) {
        button.greyscale = NO;
    }else{
        button.greyscale = YES;
    }
    [button setNeedsDisplay];
}

#pragma mark - Dealloc

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

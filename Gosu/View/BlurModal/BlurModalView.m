//
//  BlurModalView.m
//  Gosu
//
//  Created by dragon on 3/22/14.
//  Copyright (c) 2014 Matt Clemenson. All rights reserved.
//

#import "BlurModalView.h"
#import "UIView+Size.h"
#import "UIView+Screenshot.h"
#import <Accelerate/Accelerate.h>
#import <QuartzCore/QuartzCore.h>


/*
 This bit is important! In order to prevent capturing selected states of UIResponders I've implemented a delay. Please feel free to set this delay to *whatever* you deem apprpriate.
 I've defaulted it to 0.125 seconds. You can do shorter/longer as you see fit.
 */
CGFloat const kBMVBlurDefaultDelay = 0.125f;

/*
 You can also change this constant to make the blur more "blurry". I recommend the tasteful level of 0.2 and no higher. However, you are free to change this from 0.0 to 1.0.
 */
CGFloat const kBMVDefaultBlurScale = 0.2f;

CGFloat const kBMVBlurDefaultDuration = 0.2f;
CGFloat const kBMVBlurViewMaxAlpha = 1.f;

CGFloat const kBMVBlurBounceOutDurationScale = 0.8f;

NSString * const kBMVBlurDidShowNotification = @"com.whoisryannystrom.BMBlurModalView.show";
NSString * const kBMVBlurDidHidewNotification = @"com.whoisryannystrom.BMBlurModalView.hide";

typedef void (^RNBlurCompletion)(void);


@interface UIImage (Blur)
-(UIImage *)boxblurImageWithBlur:(CGFloat)blur;
@end

@interface BMVBlurView : UIImageView
- (id)initWithCoverView:(UIView*)view;
@end


@interface BlurModalView ()
@property (assign, readwrite) BOOL isVisible;
@end

#pragma mark - BlurModalView

@implementation BlurModalView {
    UIViewController *_controller;
    UIView *_parentView;
    UIView *_contentView;
    UIButton *_dismissButton;
    BMVBlurView *_blurView;
    RNBlurCompletion _completion;
}


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.alpha = 0.f;
        self.backgroundColor = [UIColor clearColor];
        //        self.backgroundColor = [UIColor redColor];
        //        self.layer.borderWidth = 2.f;
        //        self.layer.borderColor = [UIColor blackColor].CGColor;
        
        self.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                 UIViewAutoresizingFlexibleHeight |
                                 UIViewAutoresizingFlexibleLeftMargin |
                                 UIViewAutoresizingFlexibleTopMargin);
        
        self.presentAnimation = BlurModalViewAnimationNormal;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChangeNotification:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}



- (id)initWithViewController:(UIViewController*)viewController view:(UIView*)view {
    if (self = [self initWithFrame:CGRectMake(0, 0, viewController.view.width, viewController.view.height)]) {
        [self addSubview:view];
        _contentView = view;
        _contentView.center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        _controller = viewController;
        _parentView = nil;
        _contentView.clipsToBounds = YES;
        _contentView.layer.masksToBounds = YES;
    }
    return self;
}


- (id)initWithParentView:(UIView*)parentView view:(UIView*)view {
    if (self = [self initWithFrame:CGRectMake(0, 0, parentView.width, parentView.height)]) {
        [self addSubview:view];
        _contentView = view;
        _contentView.center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        _controller = nil;
        _parentView = parentView;
        _contentView.clipsToBounds = YES;
        _contentView.layer.masksToBounds = YES;
    }
    return self;
}


- (id)initWithView:(UIView*)view {
    if (self = [self initWithParentView:[[UIApplication sharedApplication].delegate window].rootViewController.view view:view]) {
        // nothing to see here
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (newSuperview) {
        self.center = CGPointMake(CGRectGetMidX(newSuperview.frame), CGRectGetMidY(newSuperview.frame));
    }
}


- (void)orientationDidChangeNotification:(NSNotification*)notification {
	if ([self isVisible]) {
		[self performSelector:@selector(updateSubviews) withObject:nil afterDelay:0.3f];
	}
}


- (void)updateSubviews {
    self.hidden = YES;
    
    // get new screenshot after orientation
    [_blurView removeFromSuperview]; _blurView = nil;
    if (_controller) {
        _blurView = [[BMVBlurView alloc] initWithCoverView:_controller.view];
        _blurView.alpha = 1.f;
        [_controller.view insertSubview:_blurView belowSubview:self];
        
    }
    else if(_parentView) {
        _blurView = [[BMVBlurView alloc] initWithCoverView:_parentView];
        _blurView.alpha = 1.f;
        [_parentView insertSubview:_blurView belowSubview:self];
        
    }
    
    
    
    self.hidden = NO;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setDismissButton:(UIButton *)dismissButton
{
    _dismissButton = dismissButton;
    [_dismissButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
}

- (void)show {
    [self showWithDuration:kBMVBlurDefaultDuration delay:0 options:kNilOptions completion:NULL];
}


- (void)showWithDuration:(CGFloat)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options completion:(void (^)(void))completion {
    self.animationDuration = duration;
    self.animationDelay = delay;
    self.animationOptions = options;
    _completion = [completion copy];
    
    // delay so we dont get button states
    [self performSelector:@selector(delayedShow) withObject:nil afterDelay:kBMVBlurDefaultDelay];
}


- (void)delayedShow {
    if (! self.isVisible) {
        if (! self.superview) {
            if (_controller) {
                self.frame = CGRectMake(0, 0, _controller.view.bounds.size.width, _controller.view.bounds.size.height);
                [_controller.view addSubview:self];
            }
            else if(_parentView) {
                self.frame = CGRectMake(0, 0, _parentView.bounds.size.width, _parentView.bounds.size.height);
                
                [_parentView addSubview:self];
            }
            self.top = 0;
        }
        
        if (_controller) {
            _blurView = [[BMVBlurView alloc] initWithCoverView:_controller.view];
            _blurView.alpha = 0.f;
            self.frame = CGRectMake(0, 0, _controller.view.bounds.size.width, _controller.view.bounds.size.height);
            
            [_controller.view insertSubview:_blurView belowSubview:self];
        }
        else if(_parentView) {
            _blurView = [[BMVBlurView alloc] initWithCoverView:_parentView];
            _blurView.alpha = 0.f;
            self.frame = CGRectMake(0, 0, _parentView.bounds.size.width, _parentView.bounds.size.height);
            
            [_parentView insertSubview:_blurView belowSubview:self];
        }
        
        if (self.presentAnimation == BlurModalViewAnimationNone)
        {
            self.alpha = 1;
            _blurView.alpha = 1;
            self.transform = CGAffineTransformIdentity;
            [[NSNotificationCenter defaultCenter] postNotificationName:kBMVBlurDidShowNotification object:nil];
            self.isVisible = YES;
            if (_completion) {
                _completion();
            }
        }
        else if (self.presentAnimation == BlurModalViewAnimationNormal)
        {
            self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.4, 0.4);
            [UIView animateWithDuration:self.animationDuration animations:^{
                _blurView.alpha = 1.f;
                self.alpha = 1.f;
                self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.f, 1.f);
            } completion:^(BOOL finished) {
                if (finished) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kBMVBlurDidShowNotification object:nil];
                    self.isVisible = YES;
                    if (_completion) {
                        _completion();
                    }
                }
            }];
        }
        else if (self.presentAnimation == BlurModalViewAnimationAlertView)
        {
            self.transform = CGAffineTransformMakeScale( 0.5, 0.5);
            self.alpha = 1;
            [UIView animateWithDuration:0.25 animations:^{
                _blurView.alpha = .4f;
                self.transform = CGAffineTransformMakeScale(1.2, 1.2f);
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:.2 animations:^{
                    _blurView.alpha = 0.8f;
                    self.transform = CGAffineTransformMakeScale(0.9, 0.9);
                } completion:^(BOOL finished) {
                    
                    [UIView animateWithDuration:.05 animations:^{
                        self.transform = CGAffineTransformIdentity;
                        _blurView.alpha = 1.f;
                    } completion:^(BOOL finished) {
                        if (finished) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:kBMVBlurDidShowNotification object:nil];
                            self.isVisible = YES;
                            if (_completion) {
                                _completion();
                            }
                        }
                    }];
                }];
            }];
        }
        
    }
    
}


- (void)hide {
    [self hideWithDuration:kBMVBlurDefaultDuration delay:0 options:kNilOptions completion:self.defaultHideBlock];
}


- (void)hideWithDuration:(CGFloat)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options completion:(void (^)(void))completion {
    if (self.isVisible) {
        [UIView animateWithDuration:duration
                              delay:delay
                            options:options
                         animations:^{
                             self.alpha = 0.f;
                             _blurView.alpha = 0.f;
                         }
                         completion:^(BOOL finished){
                             if (finished) {
                                 [_blurView removeFromSuperview];
                                 _blurView = nil;
                                 [self removeFromSuperview];
                                 
                                 [[NSNotificationCenter defaultCenter] postNotificationName:kBMVBlurDidHidewNotification object:nil];
                                 self.isVisible = NO;
                                 if (completion) {
                                     completion();
                                 }
                             }
                         }];
    }
}

-(void)hideCloseButton:(BOOL)hide {
    [_dismissButton setHidden:hide];
}

@end

#pragma mark - BMVBlurView

@implementation BMVBlurView {
    UIView *_coverView;
}

- (id)initWithCoverView:(UIView *)view {
    if (self = [super initWithFrame:CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height)]) {
        _coverView = view;
        UIImage *blur = [_coverView screenshot];
        self.image = [blur boxblurImageWithBlur:kBMVDefaultBlurScale];
    }
    return self;
}


@end

#pragma mark - UIImage + Blur

@implementation UIImage (Blur)

-(UIImage *)boxblurImageWithBlur:(CGFloat)blur {
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = self.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    
    vImage_Error error;
    
    void *pixelBuffer;
    
    
    //create vImage_Buffer with data from CGImageRef
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //create vImage_Buffer for output
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    // Create a third buffer for intermediate processing
    void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    vImage_Buffer outBuffer2;
    outBuffer2.data = pixelBuffer2;
    outBuffer2.width = CGImageGetWidth(img);
    outBuffer2.height = CGImageGetHeight(img);
    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);
    
    //perform convolution
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    free(pixelBuffer2);
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGImageRelease(imageRef);
    
    return returnImage;
}


@end

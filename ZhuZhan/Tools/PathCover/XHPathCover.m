//
//  XHPathConver.m
//  XHPathCover
//
//  Created by 曾 宪华 on 14-2-7.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHPathCover.h"
#import "XHWaterDropRefresh.h"
#import "LoginSqlite.h"

NSString *const XHUserNameKey = @"XHUserName";
NSString *const XHBirthdayKey = @"XHBirthday";
NSString *const XHTitkeKey = @"XHTitkeKey";
#import <Accelerate/Accelerate.h>
#import <float.h>

@interface UIImage (ImageEffects)
- (UIImage *)applyLightEffect;
@end

@implementation UIImage (ImageEffects)

- (UIImage *)applyLightEffect {
    UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    return [self applyBlurWithRadius:30 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage {
    // Check pre-conditions.
    if (self.size.width < 1 || self.size.height < 1) {
        NSLog (@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
        return nil;
    }
    if (!self.CGImage) {
        NSLog (@"*** error: image must be backed by a CGImage: %@", self);
        return nil;
    }
    if (maskImage && !maskImage.CGImage) {
        NSLog (@"*** error: maskImage must be backed by a CGImage: %@", maskImage);
        return nil;
    }
    
    CGRect imageRect = { CGPointZero, self.size };
    UIImage *effectImage = self;
    
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    if (hasBlur || hasSaturationChange) {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -self.size.height);
        CGContextDrawImage(effectInContext, imageRect, self.CGImage);
        
        vImage_Buffer effectInBuffer;
        
        
        effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
        
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
        
        if (hasBlur) {
            // A description of how to compute the box kernel width from the Gaussian
            // radius (aka standard deviation) appears in the SVG spec:
            // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
            //
            // For larger values of 's' (s >= 2.0), an approximation can be used: Three
            // successive box-blurs build a piece-wise quadratic convolution kernel, which
            // approximates the Gaussian kernel to within roughly 3%.
            //
            // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
            //
            // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
            //
            CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
            int radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                radius += 1; // force radius to be odd so that the three box-blur methodology works.
            }
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
        }
        BOOL effectImageBuffersAreSwapped = NO;
        if (hasSaturationChange) {
            CGFloat s = saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,  1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            if (hasBlur) {
                vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                effectImageBuffersAreSwapped = YES;
            }
            else {
                vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
        }
        if (!effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // Set up output context.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.size.height);
    
    // Draw base image.
    CGContextDrawImage(outputContext, imageRect, self.CGImage);
    
    // Draw effect image.
    if (hasBlur) {
        CGContextSaveGState(outputContext);
        if (maskImage) {
            CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
        }
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }
    
    // Add in color tint.
    if (tintColor) {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

@end

@interface XHPathCover () {
    BOOL normal, paste, hasStop;
    BOOL isrefreshed;
}

@property (nonatomic, strong) UIView *bannerView;

@property (nonatomic, strong) UIView *showView;

@property (nonatomic, strong) XHWaterDropRefresh *waterDropRefresh;

@property (nonatomic, assign) CGFloat showUserInfoViewOffsetHeight;

@end

@implementation XHPathCover

#pragma mark - Publish Api

- (void)stopRefresh {
    [_waterDropRefresh stopRefresh];
    if(_touching == NO) {
        [self resetTouch];
    } else {
        hasStop = YES;
    }
}

// background
- (void)setBackgroundImage:(UIImage *)backgroundImage {
    if (backgroundImage) {
        //_bannerImageView.image = backgroundImage;
        //_bannerImageViewWithImageEffects.image = [backgroundImage applyLightEffect];
    }
}

- (void)setBackgroundImageUrlString:(NSString *)backgroundImageUrlString {
    if (backgroundImageUrlString) {
        [_bannerImageView sd_setImageWithURL:[NSURL URLWithString:backgroundImageUrlString] placeholderImage:[GetImagePath getImagePath:self.bannerPlaceholderImageName]];
    }
}

// avatar
/*- (void)setAvatarImage:(UIImage *)avatarImage {
    if (avatarImage) {
        [_avatarButton setImage:avatarImage forState:UIControlStateNormal];
    }
}

- (void)setAvatarUrlString:(NSString *)avatarUrlString {
    if (avatarUrlString) {
        
    }
}*/

-(void)setHeadImageUrl:(NSString *)imageUrl{
    if(imageUrl){
        if([[LoginSqlite getdata:@"userType"] isEqualToString:@"Company"]){
            [_headImage sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[GetImagePath getImagePath:@"默认图_公司头像_主头像"]];
        }else{
            [_headImage sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[GetImagePath getImagePath:@"默认图_用户头像_群组成员"]];
        }
    }
}

-(void)addImageHead:(UIImage *)img{
    if(img){
        _headImage.image = img;
    }
}

// set info
- (void)setInfo:(NSDictionary *)info {
    NSString *userName = [info valueForKey:XHUserNameKey];
    if (userName) {
        self.userNameLabel.text = userName;
    }
    
    NSString *birthday = [info valueForKey:XHBirthdayKey];
    if (birthday) {
        self.birthdayLabel.text = birthday;
    }
    
    NSString *title = [info valueForKey:XHTitkeKey];
    if (title) {
        self.titleLabel.text = title;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.touching = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView isMyDynamicList:(BOOL)isMyDynamicList{
    self.isMyDynamicList = isMyDynamicList;
    self.offsetY = scrollView.contentOffset.y;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(decelerate == NO) {
        self.touching = NO;
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.touching = NO;
}

#pragma mark - Propertys

- (void)setTouching:(BOOL)touching {
    if(touching) {
        if(hasStop) {
            [self resetTouch];
        }
        
        if(normal) {
            paste = YES;
        } else if (paste == NO && _waterDropRefresh.isRefreshing == NO) {
            normal = YES;
        }
    } else if(_waterDropRefresh.isRefreshing == NO) {
        [self resetTouch];
    }
    _touching = touching;
}

- (void)setOffsetY:(CGFloat)y {
    CGFloat fixAdaptorPadding = 0;
    if ([[[UIDevice currentDevice] systemVersion] integerValue] >= 7.0) {
        fixAdaptorPadding = 64;
    }
    if(self.isMyDynamicList){
        y += fixAdaptorPadding-64;
    }else{
        y += fixAdaptorPadding;
    }
    _offsetY = y;
    CGRect frame = _showView.frame;
    if(y < 0) {
        if((_waterDropRefresh.isRefreshing) || hasStop) {
            if(normal && paste == NO) {
                frame.origin.y = self.showUserInfoViewOffsetHeight + y;
                _showView.frame = frame;
            } else {
                if(frame.origin.y != self.showUserInfoViewOffsetHeight) {
                    frame.origin.y = self.showUserInfoViewOffsetHeight;
                    _showView.frame = frame;
                }
            }
        } else {
            frame.origin.y = self.showUserInfoViewOffsetHeight + y;
            _showView.frame = frame;
        }
    } else {
        if(normal && _touching && isrefreshed) {
            paste = YES;
        }
        if(frame.origin.y != self.showUserInfoViewOffsetHeight) {
            frame.origin.y = self.showUserInfoViewOffsetHeight;
            _showView.frame = frame;
        }
    }
    if (hasStop == NO) {
        _waterDropRefresh.currentOffset = y;
    }
    
    UIView *bannerSuper = _bannerImageView.superview;
    CGRect bframe = bannerSuper.frame;
    if(y < 0) {
        bframe.origin.y = y;
        bframe.size.height = -y + bannerSuper.superview.frame.size.height;
        bannerSuper.frame = bframe;
        CGPoint center =  _bannerImageView.center;
        center.y = bannerSuper.frame.size.height / 2;
        if(bframe.size.height<320){
            _bannerImageView.center = center;
        }else{
            _bannerImageView.center = CGPointMake(center.x, center.y+(bframe.size.height-320)/2);
        }
        //_bannerImageView.frame = CGRectMake(0, 0, 320, bframe.size.height);
//        CGPoint center=self.center;
//        center.y-=y*.5;
//        _bannerImageView.center=center;
        if (self.isZoomingEffect) {
            
            //_bannerImageView.center = center;
            //CGFloat scale = fabsf(y) / self.parallaxHeight;
            //_bannerImageView.transform = CGAffineTransformMakeScale(1+scale, 1+scale);
        }
    } else {
        if(bframe.origin.y != 0) {
            bframe.origin.y = 0;
            bframe.size.height = bannerSuper.superview.frame.size.height;
            bannerSuper.frame = bframe;
        }
        if(y < bframe.size.height) {
            //CGPoint center =  _bannerImageView.center;
            //center.y = bannerSuper.frame.size.height/2 + 0.5 * y;
            //_bannerImageView.center = center;
        }
    }
    
    if (self.isLightEffect) {
        if(y < 0 && y >= -self.lightEffectPadding) {
            float percent = (-y / (self.lightEffectPadding * self.lightEffectAlpha));
            self.bannerImageViewWithImageEffects.alpha = percent;
            
        } else if (y <= -self.lightEffectPadding) {
            self.bannerImageViewWithImageEffects.alpha = self.lightEffectPadding / (self.lightEffectPadding * self.lightEffectAlpha);
        } else if (y > self.lightEffectPadding) {
            self.bannerImageViewWithImageEffects.alpha = 0;
        }
    }
}

#pragma mark - Life cycle

- (id)initWithFrame:(CGRect)frame bannerPlaceholderImageName:(NSString*)backgroundImageName{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.bannerPlaceholderImageName=backgroundImageName;
        [self _setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self _setup];
    }
    return self;
}

- (void)_setup {
    self.parallaxHeight = 170;
    self.isLightEffect = YES;
    self.lightEffectPadding = 80;
    self.lightEffectAlpha = 1.15;
    
    _bannerView = [[UIView alloc] initWithFrame:self.bounds];
    _bannerView.clipsToBounds = YES;
    
    _bannerImageView = [[UIImageView alloc] init];
    [_bannerImageView sd_setImageWithURL:nil placeholderImage:[GetImagePath getImagePath:self.bannerPlaceholderImageName]];
    _bannerImageView.frame=CGRectMake(0, 0, 320, 320);
    _bannerImageView.center=self.center;
    _bannerImageView.contentMode = UIViewContentModeScaleToFill;
    [_bannerView addSubview:self.bannerImageView];
    
    _bannerImageViewWithImageEffects = [[UIImageView alloc] initWithFrame:_bannerImageView.frame];
    _bannerImageViewWithImageEffects.alpha = 0.;
    [_bannerView addSubview:self.bannerImageViewWithImageEffects];
    
    [self addSubview:self.bannerView];
    
    NSArray *colorArray = [@[[UIColor colorWithRed:(0/255.0)  green:(0/255.0)  blue:(0/255.0)  alpha:.3],[UIColor colorWithRed:(0/255.0)  green:(0/255.0)  blue:(0/255.0)  alpha:.3]] mutableCopy];
    self.footView = [[GradientView alloc] initWithFrame:CGRectMake(0, _bannerImageView.frame.origin.y-83, 320, 320) colorArr:colorArray];
    [self addSubview:self.footView];
    
    CGFloat waterDropRefreshHeight = 100;
    CGFloat waterDropRefreshWidth = 20;
    _waterDropRefresh = [[XHWaterDropRefresh alloc] initWithFrame:CGRectMake(52.5, CGRectGetHeight(self.bounds) - waterDropRefreshHeight+5, waterDropRefreshWidth, waterDropRefreshHeight)];
    _waterDropRefresh.refreshCircleImage = [GetImagePath getImagePath:@"circle"];
    _waterDropRefresh.offsetHeight = 20; // 线条的长度
    [self addSubview:self.waterDropRefresh];
    
    CGFloat avatarButtonHeight = 46;
    self.showUserInfoViewOffsetHeight = CGRectGetHeight(self.frame) - waterDropRefreshHeight / 3 - avatarButtonHeight;

    _showView = [[UIView alloc] initWithFrame:CGRectMake(0, self.showUserInfoViewOffsetHeight, CGRectGetWidth(self.bounds), waterDropRefreshHeight)];
    _showView.backgroundColor = [UIColor clearColor];
    
    _headImage = [[UIImageView alloc] init];
    [_headImage sd_setImageWithURL:nil placeholderImage:[GetImagePath getImagePath:@"默认图_用户头像_群组成员"]];
    _headImage.frame = CGRectMake(45, 0, avatarButtonHeight, avatarButtonHeight);
    [_headImage.layer setMasksToBounds:YES];
    [_headImage.layer setCornerRadius:23];
    
    _avatarButton = [[UIButton alloc] initWithFrame:CGRectMake(45, 0, avatarButtonHeight+200, avatarButtonHeight+25)];
//    [_avatarButton.layer setMasksToBounds:YES];
//    [_avatarButton.layer setCornerRadius:23];
    
    
    _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 12, 100, 20)];
    _userNameLabel.textColor = [UIColor whiteColor];
    _userNameLabel.font = [UIFont boldSystemFontOfSize:14];
    
    
    _birthdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 35, 207, 12)];
    _birthdayLabel.textColor = [UIColor whiteColor];
    //_birthdayLabel.backgroundColor = [UIColor yellowColor];
    _birthdayLabel.font = [UIFont boldSystemFontOfSize:12];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 52, 207, 12)];
    _titleLabel.textColor = [UIColor whiteColor];
    //_titleLabel.backgroundColor = [UIColor yellowColor];
    _titleLabel.font = [UIFont boldSystemFontOfSize:12];
    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
//    imageView.backgroundColor = [UIColor yellowColor];
//    [_showView addSubview:imageView];
    
    //_showView.backgroundColor = [UIColor blackColor];
    
    [_showView addSubview:self.headImage];
    [_showView addSubview:self.avatarButton];
    [_showView addSubview:self.userNameLabel];
    [_showView addSubview:self.birthdayLabel];
    [_showView addSubview:self.titleLabel];
    
    [self addSubview:self.showView];
    
//    UIImageView *lineImage = [[UIImageView alloc] initWithFrame:CGRectMake(67, 140, 2, 14)];
//    [lineImage setBackgroundColor:[UIColor whiteColor]];
//    [self addSubview:lineImage];
}

-(void)hidewaterDropRefresh{
    self.waterDropRefresh.hidden = YES;
}


-(void)setHeadImageFrame:(CGRect)newFrame{
    [_headImage setFrame:newFrame];
}

-(void)setHeadTaget{
    [_avatarButton addTarget:self action:@selector(avatarClick) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setNameFrame:(CGRect)newFrame font:(UIFont *)font textAlignment:(NSTextAlignment)textAlignment{
    [_userNameLabel setFrame:newFrame];
    _userNameLabel.font = font;
    _userNameLabel.textAlignment = textAlignment;
}

-(void)setBirthdayFrame:(CGRect)newFrame font:(UIFont *)font{
    [_birthdayLabel setFrame:newFrame];
    _birthdayLabel.font = font;
    _birthdayLabel.textAlignment = NSTextAlignmentLeft;
}

- (void)dealloc {
    self.bannerImageView = nil;
    self.bannerImageViewWithImageEffects = nil;
    
    self.avatarButton = nil;
    self.userNameLabel = nil;
    self.birthdayLabel = nil;
    self.titleLabel = nil;
    
    self.bannerView = nil;
    self.showView = nil;
    
    self.waterDropRefresh = nil;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if(newSuperview) {
        [self initWaterView];
    }
}

- (void)initWaterView {
    __weak XHPathCover *wself =self;
    [_waterDropRefresh setHandleRefreshEvent:^{
        NSLog(@"initWaterView");
        [wself setIsRefreshed:YES];
        if(wself.handleRefreshEvent) {
            wself.handleRefreshEvent();
        }
    }];
}

#pragma mark - previte method

- (void)setIsRefreshed:(BOOL)b {
    isrefreshed = b;
}

- (void)refresh {
    if(_waterDropRefresh.isRefreshing) {
        [_waterDropRefresh startRefreshAnimation];
    }
}

- (void)resetTouch {
    normal = NO;
    paste = NO;
    hasStop = NO;
    isrefreshed = NO;
}


-(void)avatarClick{
    if([self.delegate respondsToSelector:@selector(gotoMyCenter)]){
        [self.delegate gotoMyCenter];
    }
}

- (void)setButton:(UIButton *)button WithFrame:(CGRect)frame WithBackgroundImage:(UIImage *)image AddTarget:(id)target WithAction:(SEL)selector WithTitle:(NSString *)title
{
//    UIView *back = [[UIView alloc] initWithFrame:frame];
//    back.backgroundColor = [UIColor blackColor];
//    back.alpha =0.4;
//    [self addSubview:back];
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
}

-(void)setFootViewFrame:(CGRect)newFrame{
    NSLog(@"%f",_bannerImageView.frame.origin.y-60);
    self.footView.frame = newFrame;
}
@end

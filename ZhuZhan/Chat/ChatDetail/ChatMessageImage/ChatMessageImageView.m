//
//  ChatMessageImageView.m
//  ZhuZhan
//
//  Created by 汪洋 on 15/5/18.
//
//

#import "ChatMessageImageView.h"
@interface ChatMessageImageView()
{
    CALayer      *_contentLayer;
    CAShapeLayer *_maskLayer;
    UIImage *_copyImage;
}
@end

@implementation ChatMessageImageView

- (BOOL)canBecomeFirstResponder{
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    return (action == @selector(copy:) || action == @selector(saveImage:));
}

-(void)copy:(id)sender{
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.image = _copyImage;
}

-(void)saveImage:(id)sender{
    if(self.isLocal){
        UIImageWriteToSavedPhotosAlbum(self.bigLocalImage, self, nil,nil);
    }else{
        [self saveServeImage];
    }
}

//-(void)paste:(id)sender{
//    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
//    self.image = pboard.image;
//}

-(void)saveServeImage{
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.bigImageUrl]];
    UIImage *image = [UIImage imageWithData:imageData];
    UIImageWriteToSavedPhotosAlbum(image, self, nil,nil);
}

- (instancetype)initWithFrame:(CGRect)frame isSelf:(BOOL)isSelf{
    self = [super initWithFrame:frame];
    if (self) {
        self.isSelf = isSelf;
        [self setup];
        
        self.userInteractionEnabled = YES;  //用户交互的总开关
        //长按压
        UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
        press.minimumPressDuration = 1.0;
        [self addGestureRecognizer:press];
    }
    return self;
}

- (void)setup
{
    _maskLayer = [CAShapeLayer layer];
    //_maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:5].CGPath;
    _maskLayer.fillColor = [UIColor blackColor].CGColor;
    _maskLayer.strokeColor = [UIColor clearColor].CGColor;
    _maskLayer.frame = self.bounds;
    _maskLayer.contentsCenter = CGRectMake(0.5, 0.5, 0.1, 0.1);
    _maskLayer.contentsScale = [UIScreen mainScreen].scale;                 //非常关键设置自动拉伸的效果且不变形
    if(self.isSelf){
        _maskLayer.contents = (id)[GetImagePath getImagePath:@"自己会话框最小"].CGImage;
    }else{
        _maskLayer.contents = (id)[GetImagePath getImagePath:@"他人会话框最小"].CGImage;
    }
    
    _contentLayer = [CALayer layer];
    _contentLayer.mask = _maskLayer;
    _contentLayer.frame = self.bounds;
    [self.layer addSublayer:_contentLayer];
    
}

- (void)setImage:(UIImage *)image
{
    _contentLayer.contents = (id)image.CGImage;
    _copyImage = image;
}

-(void)setImageId:(NSString *)imageId{
    _imageId = imageId;
}

-(void)setBigLocalImage:(UIImage *)bigLocalImage{
    _bigLocalImage = bigLocalImage;
}

-(void)setBigImageUrl:(NSString *)bigImageUrl{
    _bigImageUrl = bigImageUrl;
}

-(void)setIsLocal:(BOOL)isLocal{
    _isLocal = isLocal;
}

- (void)longPress:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        UIMenuItem *saveImage = [[UIMenuItem alloc] initWithTitle:@"收藏" action:@selector(saveImage:)];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:[NSArray arrayWithObjects:saveImage, nil]];
        [menu setTargetRect:self.frame inView:self.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}
@end

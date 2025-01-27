//
//  RequirementCustomerReplyView.m
//  ZhuZhan
//
//  Created by 孙元侃 on 15/6/10.
//
//

#import "RequirementCustomerReplyView.h"
#import "RKViewFactory.h"
#import "RKShadowView.h"
#import "PublishRequirementTitleView.h"
@interface RequirementCustomerReplyView ()
@property (nonatomic, strong)UIView* titleView;
@property (nonatomic, strong)UILabel* contentLabel;
@property (nonatomic, strong)UILabel* timeLabel;
@end

@implementation RequirementCustomerReplyView

- (instancetype)init{
    if (self = [super init]) {

    }
    return self;
}



- (void)setContent:(NSString *)content time:(NSString *)time needTime:(BOOL)needTime contentColor:(UIColor *)contentColor{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self addSubview:self.titleView];
    [self addSubview:self.contentLabel];
    [self addSubview:self.timeLabel];
    
    self.contentLabel.text = content;
    self.contentLabel.textColor = contentColor;
    self.timeLabel.text = time;
    
    CGFloat height = 50;
    [RKViewFactory autoLabel:self.contentLabel maxWidth:CGRectGetWidth(self.contentLabel.frame)];
    CGRect frame = self.contentLabel.frame;
    frame.origin.y = height;
    self.contentLabel.frame = frame;
    height = CGRectGetMaxY(self.contentLabel.frame);
    
    if (needTime) {
        height += 5;
        frame = self.timeLabel.frame;
        frame.origin.y = height;
        self.timeLabel.frame = frame;
        height = CGRectGetMaxY(self.timeLabel.frame);
    }

    height += 10;
    self.frame = CGRectMake(0, 0, kScreenWidth, height);
    
    [self addSepe];
}

- (void)addSepe{
    [self addSubview:[RKShadowView seperatorLine]];
    
    UIView* sepe1 = [RKShadowView seperatorLine];
    CGRect frame = sepe1.frame;
    frame.origin.y = 40;
    sepe1.frame = frame;
    [self addSubview:sepe1];
    
    UIView* sepe2 = [RKShadowView seperatorLine];
    frame = sepe2.frame;
    frame.origin.y = CGRectGetHeight(self.frame)-1;
    sepe2.frame = frame;
    [self addSubview:sepe2];
}

- (UILabel *)contentLabel{
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 10, kScreenWidth-36, 0)];
        _contentLabel.font = [UIFont systemFontOfSize:17];
    }
    return _contentLabel;
}

- (UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, kScreenWidth-36, 20)];
        _timeLabel.font = [UIFont systemFontOfSize:14];
        _timeLabel.textColor = AllNoDataColor;
    }
    return _timeLabel;
}

- (UIView *)titleView{
    if (!_titleView) {
        _titleView = [PublishRequirementTitleView titleViewWithImageName:@"需求_标题_客服回复" title:@"客服回复"];
    }
    return _titleView;
}
@end

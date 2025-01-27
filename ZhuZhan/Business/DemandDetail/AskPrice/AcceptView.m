//
//  AcceptView.m
//  ZhuZhan
//
//  Created by 孙元侃 on 15/4/7.
//
//

#import "AcceptView.h"
#import "RKShadowView.h"
@interface AcceptView ()
@property (nonatomic, strong)UIView* mainView;

@property (nonatomic, strong)UIView* titleView;
@property (nonatomic, strong)NSMutableArray* cells;
@property (nonatomic, strong)UIView* bottomView;

@property (nonatomic, strong)NSMutableArray* chooseds;
@end
#define kMaxWidth 260
@implementation AcceptView
-(instancetype)initWithUserNames:(NSArray *)userNames{
    if (self=[super init]) {
        self.userNames=userNames;
        self.frame=CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        self.backgroundColor=[[UIColor alloc]initWithRed:0 green:0 blue:0 alpha:.5];
        [self addTarget:self action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
        [self setUp];
    }
    return self;
}

-(void)setUp{
    [self addSubview:self.mainView];
    
    __block CGFloat height=0;
    [self.mainView addSubview:self.titleView];
    height+=CGRectGetHeight(self.titleView.frame);
    
    [self.cells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView* cell=obj;
        CGFloat cellHeight=CGRectGetHeight(cell.frame);
        cell.frame=CGRectMake(0, height, kMaxWidth, cellHeight);
        
        [self.mainView addSubview:cell];
        height+=CGRectGetHeight(cell.frame);
        
        UIButton* btn=cell.subviews.lastObject;
        btn.tag=idx;
        [btn addTarget:self action:@selector(chooseBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }];
    
    CGRect frame=self.bottomView.frame;
    frame.origin.y=height;
    self.bottomView.frame=frame;
    [self.mainView addSubview:self.bottomView];
    height+=CGRectGetHeight(self.bottomView.frame);
    
    self.mainView.frame=CGRectMake(0, 0, kMaxWidth, height);
    self.mainView.center=self.center;
    self.mainView.layer.cornerRadius=5;
}

-(void)chooseBtnClicked:(UIButton*)btn{
    NSString* index=[NSString stringWithFormat:@"%d",(int)btn.tag];
    BOOL contains=[self.chooseds containsObject:index];
    if (contains) {
        [self.chooseds removeObject:index];
    }else{
        [self.chooseds addObject:index];
    }
    contains=!contains;
    NSString* imageName=contains?@"高级搜索-多选_07a":@"高级搜索-多选_09a";
    [btn setBackgroundImage:[GetImagePath getImagePath:imageName] forState:UIControlStateNormal];
}
-(void)btnClicked:(UIButton*)btn{
    if (btn.tag) {
        if ([self.delegate respondsToSelector:@selector(acceptViewSureBtnClicked:)]) {
            [self.delegate acceptViewSureBtnClicked:self];
        }
    }
    [self removeFromSuperview];
}

-(UIView *)bottomView{
    if (!_bottomView) {
        _bottomView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, kMaxWidth, 40)];
        
        UIButton* sureBtn=[UIButton  buttonWithType:UIButtonTypeCustom];
        UIButton* cancelBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        
        UIFont* font=[UIFont systemFontOfSize:15];
        sureBtn.titleLabel.font=font;
        cancelBtn.titleLabel.font=font;
        
        [sureBtn setTitle:@"采纳" forState:UIControlStateNormal];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        
        [sureBtn setTitleColor:BlueColor forState:UIControlStateNormal];
        [cancelBtn setTitleColor:AllLightGrayColor forState:UIControlStateNormal];
        
        sureBtn.tag=1;
        [sureBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cancelBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];

        CGFloat width=100;
        CGFloat x=(kMaxWidth/2-width)/2;
        sureBtn.frame=CGRectMake(x, 10, width, 20);
        cancelBtn.frame=CGRectMake(x+kMaxWidth/2, 10, width, 20);
        
        [_bottomView addSubview:sureBtn];
        [_bottomView addSubview:cancelBtn];
        
        UIView* seperatorLine1=[RKShadowView seperatorLine];
        seperatorLine1.frame=CGRectMake(0, 0, kMaxWidth, 2);
        [_bottomView addSubview:seperatorLine1];
        
        UIView* seperatorLine2=[RKShadowView seperatorLine];
        seperatorLine2.frame=CGRectMake(0, 0, 1, CGRectGetHeight(_bottomView.frame));
        seperatorLine2.center=_bottomView.center;
        [_bottomView addSubview:seperatorLine2];
    }
    return _bottomView;
}

-(NSMutableArray *)cells{
    if (!_cells) {
        _cells=[NSMutableArray array];
        [self.userNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIView* cell=[[UIView alloc]initWithFrame:CGRectMake(0, 0, kMaxWidth, 40)];
            CGFloat seperatorLineWidth=200;
            CGFloat x=(kMaxWidth-seperatorLineWidth)*0.5;
            CGFloat y=10;
            UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(x, y, 100, 20)];
            label.text=self.userNames[idx];
            label.font=[UIFont systemFontOfSize:14];
            [cell addSubview:label];
            
            UIView* seperatorLine=[RKShadowView seperatorLine];
            seperatorLine.frame=CGRectMake(x, CGRectGetHeight(cell.frame), seperatorLineWidth, CGRectGetHeight(seperatorLine.frame));
            [cell addSubview:seperatorLine];
            
            CGFloat btnWidth=21;
            CGFloat btnHeight=21;
            CGFloat btnX=kMaxWidth-x-btnWidth;
            UIButton* chooseBtn=[UIButton buttonWithType:UIButtonTypeCustom];
            [chooseBtn setBackgroundImage:[GetImagePath getImagePath:@"高级搜索-多选_09a"] forState:UIControlStateNormal];
            chooseBtn.frame=CGRectMake(btnX, y, btnWidth, btnHeight);
            [cell addSubview:chooseBtn];
            
            [_cells addObject:cell];
        }];
    }
    return _cells;
}

-(UIView *)titleView{
    if (!_titleView) {
        UIView* view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, kMaxWidth, 70)];
        
        UILabel* titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 40)];
        titleLabel.numberOfLines=0;
        titleLabel.textAlignment=NSTextAlignmentCenter;
        titleLabel.center=view.center;
        titleLabel.text=@"请选择需要的报价提供者\n未选的所有报价均会关闭";
        titleLabel.font=[UIFont boldSystemFontOfSize:16];
        [view addSubview:titleLabel];
        
        UIView* seperatorLine=[RKShadowView seperatorLine];
        seperatorLine.frame=CGRectMake(0, CGRectGetHeight(view.frame)-CGRectGetHeight(seperatorLine.frame), kMaxWidth, 2);
        [view addSubview:seperatorLine];
        
        _titleView=view;
    }
    return _titleView;
}

-(UIView *)mainView{
    if (!_mainView) {
        _mainView=[[UIView alloc]initWithFrame:CGRectZero];
        _mainView.backgroundColor=[UIColor whiteColor];
    }
    return _mainView;
}

-(void)setUserNames:(NSArray *)userNames{
    _userNames=userNames;
}

-(NSMutableArray *)chooseds{
    if (!_chooseds) {
        _chooseds=[NSMutableArray array];
    }
    return _chooseds;
}
@end

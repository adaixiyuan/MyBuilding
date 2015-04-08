//
//  AskPriceViewController.m
//  ZhuZhan
//
//  Created by 孙元侃 on 15/3/16.
//
//

#import "AskPriceViewController.h"
#import "RKStageChooseView.h"
#import "RKTwoView.h"
#import "AskPriceViewCell.h"
#import "ChooseProductBigStage.h"
#import "ChooseProductSmallStage.h"
#import "DemandStageChooseController.h"
#import "AskPriceApi.h"
#import "AskPriceModel.h"
#import "QuotesModel.h"
#import "DemandListSearchController.h"
#import "LoginSqlite.h"
#import "AskPriceDetailViewController.h"
#import "QuotesDetailViewController.h"
#import "MJRefresh.h"
@interface AskPriceViewController ()<DemandStageChooseControllerDelegate,RKStageChooseViewDelegate>
@property(nonatomic,strong)NSString *otherStr;
@property(nonatomic,strong)NSString *statusStr;
@property(nonatomic,strong)NSMutableArray *showArr;
@property (nonatomic)NSInteger nowStage;
@property(nonatomic)int startIndex;
@end

@implementation AskPriceViewController

-(instancetype)init{
    if (self=[super init]) {
        self.otherStr=@"-1";
    }
    return self;
}

-(instancetype)initWithOtherStr:(NSString*)otherStr{
    if (self=[super init]) {
        self.otherStr=otherStr;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.startIndex = 0;
    [self initNavi];
    [self initStageChooseViewWithStages:@[@"全部",@"进行中",@"已采纳",@"已关闭"]  numbers:@[@"0",@"0",@"0",@"0"]];
    [self initTableView];
    
    //集成刷新控件
    [self setupRefresh];

    self.tableView.backgroundColor=AllBackDeepGrayColor;
}

-(NSString*)getTitle{
    NSString* title;
    if([self.otherStr isEqualToString:@"1"]){
        title=@"报价需求列表";
    }else if ([self.otherStr isEqualToString:@"0"]){
        title=@"询价需求列表";
    }else if ([self.otherStr isEqualToString:@"-1"]){
        title=@"全部需求列表";
    }
    return title;
}

-(NSString *)statusStr{
    if (!_statusStr) {
        _statusStr = @"";
    }
    return _statusStr;
}

-(void)loadList{
    [AskPriceApi GetAskPriceWithBlock:^(NSMutableArray *posts, NSError *error) {
        if(!error){
            [self.showArr removeAllObjects];
            self.showArr = posts[0];
           [self.stageChooseView changeNumbers:@[posts[1][@"totalCount"],posts[1][@"processingCount"],posts[1][@"completeCount"],posts[1][@"offCount"]]];
            [self.tableView reloadData];
        }
    } status:self.statusStr startIndex:0 other:self.otherStr keyWorks:@"" noNetWork:nil];
}

-(void)initNavi{
    [self initTitleViewWithTitle:[self getTitle]];
    [self setLeftBtnWithImage:[GetImagePath getImagePath:@"013"]];
    [self setRightBtnWithImage:[GetImagePath getImagePath:@"搜索按钮"]];
    self.needAnimaiton=YES;
}

-(void)initTitleViewWithTitle:(NSString*)title{
    NSString* titleStr=title;
    UIFont* font=[UIFont fontWithName:@"GurmukhiMN-Bold" size:19];
    UILabel* titleLabel=[[UILabel alloc]init];
    titleLabel.text=titleStr;
    titleLabel.font=font;
    titleLabel.textColor=[UIColor whiteColor];
    CGSize size=[titleStr boundingRectWithSize:CGSizeMake(9999, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    titleLabel.frame=CGRectMake(0, 0, size.width, size.height);
    
    UIImageView* imageView=[[UIImageView alloc]initWithFrame:CGRectMake( 0, 0, 15, 9)];
    imageView.center=CGPointMake(CGRectGetMaxX(titleLabel.frame)+CGRectGetWidth(imageView.frame)*0.5+5, CGRectGetMidY(titleLabel.frame));
    imageView.image=[GetImagePath getImagePath:@"交易_页头箭头"];
    
    CGRect frame=titleLabel.frame;
    frame.size.width+=CGRectGetWidth(imageView.frame);
    
    UIButton* button=[[UIButton alloc]initWithFrame:frame];
    [button addTarget:self action:@selector(selectDemandStage) forControlEvents:UIControlEventTouchUpInside];
    [button addSubview:titleLabel];
    [button addSubview:imageView];
    
    self.navigationItem.titleView=button;
}

-(void)rightBtnClicked{
    UIViewController* vc=[[DemandListSearchController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
    //[self presentViewController:vc animated:YES completion:nil];
}

-(void)selectDemandStage{
    DemandStageChooseController* vc=[[DemandStageChooseController alloc]initWithIndex:self.nowStage stageNames:@[@"全部需求列表",@"报价需求列表",@"询价需求列表"]];
    vc.delegate=self;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)finishSelectedWithStageName:(NSString *)stageName index:(int)index{
    self.nowStage=index;
    [self initTitleViewWithTitle:stageName];
    if(index == 1){
        self.otherStr = @"1";
    }else if (index == 2){
        self.otherStr = @"0";
    }else{
        self.otherStr = @"-1";
    }
    [self stageBtnClickedWithNumber:self.stageChooseView.nowStageNumber];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.showArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    AskPriceModel *model = self.showArr[indexPath.row];
    if([model.a_category isEqualToString:@"0"]){
        return [AskPriceViewCell carculateTotalHeightWithContents:@[model.a_invitedUser,model.a_productBigCategory,model.a_productCategory,model.a_remark]];
    }else{
        return [AskPriceViewCell carculateTotalHeightWithContents:@[model.a_requestName,model.a_productBigCategory,model.a_productCategory,model.a_remark]];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AskPriceViewCell* cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell=[[AskPriceViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.clipsToBounds=YES;
    }
    AskPriceModel *model = self.showArr[indexPath.row];
    if([model.a_category isEqualToString:@"0"]){
        cell.contents=@[model.a_invitedUser,model.a_productBigCategory,model.a_productCategory,model.a_remark,model.a_category,model.a_tradeStatus,model.a_tradeCode];
    }else{
        cell.contents=@[model.a_requestName,model.a_productBigCategory,model.a_productCategory,model.a_remark,model.a_category,model.a_tradeStatus,model.a_tradeCode];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AskPriceModel *model = self.showArr[indexPath.row];
    if([model.a_category isEqualToString:@"0"]){
        NSLog(@"自己发");
        AskPriceDetailViewController *view = [[AskPriceDetailViewController alloc] init];
        view.askPriceModel = model;
        [self.navigationController pushViewController:view animated:YES];
    }else{
        NSLog(@"别人发");
        QuotesDetailViewController *view = [[QuotesDetailViewController alloc] init];
        view.askPriceModel = model;
        [self.navigationController pushViewController:view animated:YES];
    }
}

-(void)stageBtnClickedWithNumber:(NSInteger)stageNumber{

    NSLog(@"=====> %ld",(long)stageNumber);
    if(stageNumber == 0){
        self.statusStr = @"";
    }else if (stageNumber == 1){
        self.statusStr = @"0";
    }else if (stageNumber == 2){
        self.statusStr = @"1";
    }else{
        self.statusStr = @"2";
    }
    [self loadList];
}


/**
 *  集成刷新控件
 */
- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    //[_tableView headerBeginRefreshing];
    
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
}

#pragma mark 开始进入刷新状态
- (void)headerRereshing
{
    [AskPriceApi GetAskPriceWithBlock:^(NSMutableArray *posts, NSError *error) {
        if(!error){
            [self.showArr removeAllObjects];
            self.showArr = posts[0];
            [self.stageChooseView changeNumbers:@[posts[1][@"totalCount"],posts[1][@"processingCount"],posts[1][@"completeCount"],posts[1][@"offCount"]]];
            [self.tableView reloadData];
        }
        [self.tableView headerEndRefreshing];
    } status:self.statusStr startIndex:0 other:self.otherStr keyWorks:@"" noNetWork:nil];
}

- (void)footerRereshing
{
    [AskPriceApi GetAskPriceWithBlock:^(NSMutableArray *posts, NSError *error) {
        if(!error){
            self.startIndex++;
            [self.showArr addObjectsFromArray:posts[0]];
            [self.stageChooseView changeNumbers:@[posts[1][@"totalCount"],posts[1][@"processingCount"],posts[1][@"completeCount"],posts[1][@"offCount"]]];
            [self.tableView reloadData];
        }
        [self.tableView footerEndRefreshing];
    } status:self.statusStr startIndex:self.startIndex+1 other:self.otherStr keyWorks:@"" noNetWork:nil];
}
@end

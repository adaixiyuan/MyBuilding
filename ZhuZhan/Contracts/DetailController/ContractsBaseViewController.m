//
//  ContractsBaseViewController.m
//  ZhuZhan
//
//  Created by 孙元侃 on 15/3/30.
//
//

#import "ContractsBaseViewController.h"
#import "BaseContractsView.h"
#import "ProvisionalViewController.h"
#import "RKContractsStagesView.h"
#import "ContractsTradeCodeView.h"
#import "ContractsApi.h"
@interface ContractsBaseViewController ()<ContractsViewDelegate>
@property (nonatomic, strong)UIAlertView* sucessAlertView;//成功发送
@property (nonatomic, strong)UIAlertView* sureCloseAlertView;//确认关闭
@end

@implementation ContractsBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [self initNavi];
    [self initStagesView];
    [self initTradeCodeView];
}

-(void)initNavi{
    [self setLeftBtnWithImage:[GetImagePath getImagePath:@"013"]];
    [self setRightBtnWithText:@"更多"];
}

-(void)initStagesView{
    [self.view addSubview:self.stagesView];
}

-(void)initTradeCodeView{
    [self.view insertSubview:self.tradeCodeView belowSubview:self.stagesView];
    CGRect frame=self.tradeCodeView.frame;
    frame.origin.y=CGRectGetMaxY(self.stagesView.frame);
    self.tradeCodeView.frame=frame;
}

-(void)sucessPost{
    self.sucessAlertView=[[UIAlertView alloc]initWithTitle:@"提醒" message:@"操作成功" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [self.sucessAlertView show];
}

-(void)rightBtnClicked{
    UIActionSheet* sheet=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"关闭", nil];
    [sheet showInView:self.view.window];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    //关闭
    if (buttonIndex==0) {
        self.sureCloseAlertView=[[UIAlertView alloc] initWithTitle:@"提醒" message:@"确认要关闭吗？" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",@"取消", nil];
        [self.sureCloseAlertView show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (self.sucessAlertView==alertView) {
        [self.navigationController popViewControllerAnimated:YES];
    }else if (self.sureCloseAlertView==alertView){
        [self closeBtnClicked];
    }
}

-(void)closeBtnClicked{
    NSLog(@"关闭");
}

-(UIView *)stagesView{
    if (!_stagesView) {
        _stagesView=[RKContractsStagesView contractsStagesViewWithBigStageNames:@[@"大标题1",@"大标题2",@"大标题3"] smallStageNames:@[@[@"小标题1",@"小标题2",@"小标题3"],@[@"小标题1",@"小标题2"],@[@"小标题"]] smallStageStyles:@[@[@0,@0,@0],@[@0,@1],@[@1]] isClosed:NO];
        CGRect frame=_stagesView.frame;
        frame.origin.y=64;
        _stagesView.frame=frame;
    }
    return _stagesView;
}

-(ContractsTradeCodeView *)tradeCodeView{
    if (!_tradeCodeView) {
        NSString* tradeCode=[NSString stringWithFormat:@"流水号:%@",self.listSingleModel.a_serialNumber];
        _tradeCodeView=[ContractsTradeCodeView contractsTradeCodeViewWithTradeCode:tradeCode time:self.listSingleModel.a_createdTime];
    }
    return _tradeCodeView;
}

-(NSArray*)stylesWithNumber:(NSInteger)number count:(NSInteger)count{
    NSMutableArray* array=[NSMutableArray array];
    for (int i=0;i<count;i++) {
        [array addObject:number>0?@0:@1];
        number--;
    }
    return array;
}
@end

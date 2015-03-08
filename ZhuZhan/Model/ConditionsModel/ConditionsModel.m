//
//  ConditionsModel.m
//  ZhuZhan
//
//  Created by 汪洋 on 14-9-1.
//
//

#import "ConditionsModel.h"
#import "ProjectStage.h"
@implementation ConditionsModel
-(void)setDict:(NSDictionary *)dict{
    _dict = dict;
    self.a_id = [ProjectStage ProjectStrStage:dict[@"advSearchId"]];
    self.a_searchName = [ProjectStage ProjectStrStage:dict[@"searchName"]];
    self.a_searchConditions = [ProjectStage ProjectStrStage:dict[@"searchCondition"]];
    self.a_createBy = [ProjectStage ProjectStrStage:dict[@"createdUser"]];
}
@end

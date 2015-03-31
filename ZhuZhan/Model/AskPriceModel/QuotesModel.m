//
//  QuotesModel.m
//  ZhuZhan
//
//  Created by 汪洋 on 15/3/21.
//
//

#import "QuotesModel.h"
#import "ProjectStage.h"
@implementation QuotesModel
-(void)setDict:(NSDictionary *)dict{
    _dict = dict;
    self.a_isVerified = dict[@"isVerified"];
    self.a_loginId = dict[@"loginId"];
    self.a_loginName = dict[@"loginName"];
    if([dict[@"status"] isEqualToString:@"0"]){
        self.a_status = @"进行中";
    }else if ([dict[@"status"] isEqualToString:@"1"]){
        self.a_status = @"完成";
    }else{
        self.a_status = @"关闭";
    }
}
@end


@implementation QuotesDetailModel

-(void)setDict:(NSDictionary *)dict{
    _dict = dict;
    self.a_id = dict[@"id"];
    self.a_bookBuildingId = dict[@"bookBuildingId"];
    self.a_createdTime = [ProjectStage ProjectTimeStage:dict[@"createdTime"]];
    self.a_isAccepted = dict[@"isAccepted"];
    self.a_quoteContent = dict[@"quoteContent"];
    if([dict[@"quoteIsVerified"] isEqualToString:@"00"]){
        self.a_quoteIsVerified = dict[@""];
    }else{
        self.a_quoteIsVerified = dict[@"平台认证公司资质，诚实可信"];
    }
    self.a_quoteUser = dict[@"quoteUser"];
    self.a_status = dict[@"status"];
    self.a_tradeCode = dict[@"tradeCode"];
    self.a_createdBy = dict[@"createdBy"];
    self.a_quoteTimes = dict[@"quoteTimes"];
    self.a_quoteAttachmentsArr = [[NSMutableArray alloc] init];
    [dict[@"quoteAttachments"] enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        ImagesModel *model = [[ImagesModel alloc] init];
        [model setDict:item];
        [self.a_quoteAttachmentsArr addObject:model];
    }];
    
    [dict[@"quoteAttachments"] enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        ImagesModel *model = [[ImagesModel alloc] init];
        [model setDict:item];
        [self.a_qualificationsAttachmentsArr addObject:model];
    }];
    
    [dict[@"quoteAttachments"] enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        ImagesModel *model = [[ImagesModel alloc] init];
        [model setDict:item];
        [self.a_otherAttachmentsArr addObject:model];
    }];
}

@end

@implementation ImagesModel
-(void)setDict:(NSDictionary *)dict{
    self.a_id = dict[@"id"];
    self.a_createdBy = dict[@"createdBy"];
    if(![[ProjectStage ProjectStrStage:dict[@"location"]] isEqualToString:@""]){
        self.a_location = [NSString stringWithFormat:@"%s%@",serverAddress,image([ProjectStage ProjectStrStage:dict[@"location"]], @"quote", @"", @"", @"")];
        self.a_isUrl = YES;
    }else{
        self.a_location = [ProjectStage ProjectStrStage:dict[@"location"]];
        self.a_isUrl = NO;
    }
    self.a_name = dict[@"name"];
    self.a_quotesId = dict[@"quotesId"];
    self.a_tradeCode = dict[@"tradeCode"];
    self.a_category = dict[@"category"];
}
@end
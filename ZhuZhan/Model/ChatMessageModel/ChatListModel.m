//
//  ChatListModel.m
//  ZhuZhan
//
//  Created by 汪洋 on 15/4/11.
//
//

#import "ChatListModel.h"
#import "ProjectStage.h"
@implementation ChatListModel
-(void)setDict:(NSDictionary *)dict{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _dict = dict;
    self.a_chatlogId = dict[@"chatlogId"];
    self.a_groupId = dict[@"groupId"];
    self.a_groupName = dict[@"name"];
    self.a_loginId = dict[@"loginId"];
    if(![dict[@"loginImagesId"] isEqualToString:@""]){
        self.a_loginImageUrl = [NSString stringWithFormat:@"%@%@",[userDefaults objectForKey:@"serverAddress"],image(dict[@"loginImagesId"], @"login", @"", @"", @"")];
    }else{
        self.a_loginImageUrl = dict[@"loginImagesId"];
    }
    if([dict[@"nickName"] isEqualToString:@""]){
        self.a_loginName = dict[@"loginName"];
    }else{
        self.a_loginName = dict[@"nickName"];
    }
    if([dict[@"msgType"] isEqualToString:@"01"]){
        self.a_content = dict[@"content"];
    }else if([dict[@"msgType"] isEqualToString:@"02"]){
        self.a_content = @"[图片]";
    }else{
        self.a_content = @"";
    }
    
    self.a_type = dict[@"type"];
    if([dict[@"msgCount"] intValue] >99){
        self.a_msgCount = @"99";
    }else{
        self.a_msgCount = dict[@"msgCount"];
    }
    if([dict[@"msgCount"] isEqualToString:@"0"]){
        self.a_isShow = NO;
    }else{
        self.a_isShow = YES;
    }
    self.a_time = [ProjectStage ChatMessageTimeStage:dict[@"createdTime"]];
}
@end
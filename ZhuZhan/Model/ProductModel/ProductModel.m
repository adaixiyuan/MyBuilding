//
//  ProductModel.m
//  ZhuZhan
//
//  Created by 汪洋 on 14-9-4.
//
//

#import "ProductModel.h"
#import "ProjectStage.h"
#import "ConnectionAvailable.h"

@implementation ProductModel
-(void)setDict:(NSDictionary *)dict{
    _dict = dict;
    self.a_id = [ProjectStage ProjectStrStage:_dict[@"productId"]];
    self.a_name = [ProjectStage ProjectStrStage:_dict[@"productName"]];
    self.a_content = [ProjectStage ProjectStrStage:_dict[@"productDesc"]];
    if(![[ProjectStage ProjectStrStage:_dict[@"imageUrl"]] isEqualToString:@""]){
        self.a_imageUrl = [NSString stringWithFormat:@"%s%@",serverAddress,image([ProjectStage ProjectStrStage:dict[@"productImagesId"]], @"product", @"", @"", @"")];
    }else{
        self.a_imageUrl = [ProjectStage ProjectStrStage:_dict[@"productImagesId"]];
    }
    self.a_commentNumber = [ProjectStage ProjectStrStage:[NSString stringWithFormat:@"%@",_dict[@"commetNum"]]];
    self.a_imageWidth = [ProjectStage ProjectStrStage:[NSString stringWithFormat:@"%@",_dict[@"imageWidth"]]];
    self.a_imageHeight = [ProjectStage ProjectStrStage:[NSString stringWithFormat:@"%@",_dict[@"imageHeight"]]];
    if(![[ProjectStage ProjectStrStage:_dict[@"avatarUrl"]] isEqualToString:@""]){
        self.a_avatarUrl = [NSString stringWithFormat:@"%s%@",serverAddress,[ProjectStage ProjectStrStage:_dict[@"avatarUrl"]]];
    }else{
        self.a_avatarUrl = [ProjectStage ProjectStrStage:_dict[@"avatarUrl"]];
    }
    self.a_userName = [ProjectStage ProjectStrStage:_dict[@"loginName"]];
    self.a_createdBy=[ProjectStage ProjectStrStage:_dict[@"createdUser"]];
    self.a_userType=[ProjectStage ProjectStrStage:_dict[@"userType"]];
    self.a_isFocused = [ProjectStage ProjectStrStage:[NSString stringWithFormat:@"%@",_dict[@"isFocus"]]];
}

-(NSString *)a_commentNumber{
    if ([_a_commentNumber isEqualToString:@""]) {
        _a_commentNumber=@"0";
    }
    return _a_commentNumber;
}

+ (NSURLSessionDataTask *)GetProductInformationWithBlock:(void (^)(NSMutableArray *posts, NSError *error))block startIndex:(int)startIndex keyWords:(NSString *)keyWords noNetWork:(void (^)())noNetWork{
    if (![ConnectionAvailable isConnectionAvailable]) {
        if (noNetWork) {
            noNetWork();
        }
        return nil;
    }
    NSString *urlStr = [NSString stringWithFormat:@"api/productInfo/getProductInfoPage?pageSize=10&pageIndex=%d&productDesc=%@",startIndex,keyWords];
    NSString * encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (CFStringRef)urlStr, NULL, NULL,  kCFStringEncodingUTF8 ));
    //NSLog(@"%@",urlStr);
    return [[AFAppDotNetAPIClient sharedNewClient] GET:encodedString parameters:nil success:^(NSURLSessionDataTask * __unused task, id JSON) {
        NSLog(@"JSON===>%@",JSON);
        NSLog(@"%@",JSON[@"status"][@"errorMsg"]);
        if([[NSString stringWithFormat:@"%@",JSON[@"status"][@"statusCode"]]isEqualToString:@"200"]){
            NSMutableArray *mutablePosts = [[NSMutableArray alloc] init];
            for(NSDictionary *item in JSON[@"data"][@"rows"]){
                ProductModel *model = [[ProductModel alloc] init];
                [model setDict:item];
                [mutablePosts addObject:model];
            }
            if (block) {
                block([NSMutableArray arrayWithArray:mutablePosts], nil);
            }
        }else if([[NSString stringWithFormat:@"%@",JSON[@"d"][@"status"][@"statusCode"]]isEqualToString:@"1302"]){
            if (block) {
                block(nil,nil);
            }
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:JSON[@"d"][@"status"][@"errors"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error ==> %@",error);
        if (block) {
            block([NSMutableArray array], error);
        }
    }];
}

//POST:
//{
//    "ProductName": ":"产品名字" 必填
//    "ProductDescription":"产品描述"
//    "ProductImageName":"产品图片名字"
//    "ProductImageStrings":"图片base64"
//    "CreatedBy":"创建人"
//}
+ (NSURLSessionDataTask *)AddProductInformationWithBlock:(void (^)(NSMutableArray *posts, NSError *error))block dic:(NSDictionary *)dic imgData:(NSData *)imgData noNetWork:(void(^)())noNetWork{
    if (![ConnectionAvailable isConnectionAvailable]) {
        if (noNetWork) {
            noNetWork();
        }
        return nil;
    }
    NSString *urlStr = [NSString stringWithFormat:@"api/productInfo/addProductInfo"];
    return [[AFAppDotNetAPIClient sharedNewClient] POST:urlStr parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imgData name:@"productImageString" fileName:@"product.jpg" mimeType:@"image/jpg"];
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"responseObject ==> %@",responseObject);
//        if (block) {
//            block([NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"%s%@",serverAddress,responseObject[@"data"]], nil], nil);
//        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error ==> %@",error);
        if (block) {
            block([NSMutableArray array], error);
        }
    }];
}

//POST:
//{
//    "productId": ":"产品Id" 必填
//    "PublishedBy":"发布人" 必填
//}
+ (NSURLSessionDataTask *)PublishProductInformationWithBlock:(void (^)(NSMutableArray *posts, NSError *error))block dic:(NSMutableDictionary *)dic noNetWork:(void(^)())noNetWork{
    if (![ConnectionAvailable isConnectionAvailable]) {
        if (noNetWork) {
            noNetWork();
        }
        return nil;
    }
    NSString *urlStr = [NSString stringWithFormat:@"api/ProductInformation/PublishProductInformation"];
    return [[AFAppDotNetAPIClient sharedNewClient] POST:urlStr parameters:dic success:^(NSURLSessionDataTask * __unused task, id JSON) {
        NSLog(@"JSON=publish==>%@",JSON);
        if([[NSString stringWithFormat:@"%@",JSON[@"status"][@"statusCode"]]isEqualToString:@"200"]){
            NSMutableArray *mutablePosts = [[NSMutableArray alloc] init];
            [mutablePosts addObject:JSON];
            if (block) {
                block([NSMutableArray arrayWithArray:mutablePosts], nil);
            }
        }else if([[NSString stringWithFormat:@"%@",JSON[@"d"][@"status"][@"statusCode"]]isEqualToString:@"1302"]){
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:JSON[@"d"][@"status"][@"errors"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error ==> %@",error);
        if (block) {
            block([NSMutableArray array], error);
        }
        
    }];
}
@end

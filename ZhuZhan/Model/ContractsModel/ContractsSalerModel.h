//
//  ContractsSalerModel.h
//  ZhuZhan
//
//  Created by 孙元侃 on 15/4/20.
//
//

#import <Foundation/Foundation.h>

@interface ContractsSalerModel : NSObject
@property (nonatomic, copy)NSString* a_id;
@property (nonatomic)NSInteger a_status;
@property (nonatomic, copy)NSString* a_fileName;
@property (nonatomic, copy)NSString* a_createdTime;
//流水号
@property (nonatomic, copy)NSString* a_serialNumber;
//非主条款、供应商合同状态下的他们的id
@property (nonatomic, copy)NSString* a_contractsRecordId;
@property (nonatomic)NSInteger a_archiveStatus;
@property (nonatomic, strong)NSDictionary* dict;
@end

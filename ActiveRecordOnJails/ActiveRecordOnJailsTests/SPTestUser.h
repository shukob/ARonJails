//
//  SPTestUser.h
//  ActiveRecordOnJails
//
//  Created by skonb on 2013/06/25.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ARJActiveRecord.h"

@interface SPTestUser : ARJActiveRecord
@property (nonatomic, strong) NSString * name;
+(id)validateSizeOfPicture:(id)instance;

@end

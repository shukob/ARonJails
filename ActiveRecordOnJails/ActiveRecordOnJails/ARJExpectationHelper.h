//
//  ARJExpectationHelper.h
//  ActiveRecordOnJails
//
//  Created by skonb on 2013/06/03.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARJExpectationHelper : NSObject
-(NSString*)nonCamelizedFromCamelized:(NSString*)camelized;
-(NSString*)camelizedFromNonCamelized:(NSString*)nonCamelized;
+(ARJExpectationHelper*)defaultHelper;
@end

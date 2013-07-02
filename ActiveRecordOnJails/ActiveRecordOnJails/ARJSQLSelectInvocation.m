//
//  ARJSQLSelectInvocation.m
//  ActiveRecordOnJails
//
//  Created by skonb on 2013/06/24.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ARJSQLSelectInvocation.h"
#import "FMDatabase.h"
@implementation ARJSQLSelectInvocation

-(id)invokeInDatabase:(id)database{
    id res = nil;
    if ([database isKindOfClass:[FMDatabase class]]) {
        res = [database executeQuery:self.SQLString withArgumentsInArray:self.parameters];
    }
    return res;
}

@end

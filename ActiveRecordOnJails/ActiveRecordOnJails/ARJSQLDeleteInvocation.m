//
//  ARJSQLDeleteInvocation.m
//  ActiveRecordOnJails
//
//  Created by skonb on 2013/06/24.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ARJSQLDeleteInvocation.h"
#import "FMDatabase.h"

@implementation ARJSQLDeleteInvocation
-(id)invokeInDatabase:(id)database{
    id res = nil;
    if ([database isKindOfClass:[FMDatabase class]]) {
        BOOL result = [database executeUpdate:self.SQLString withArgumentsInArray:self.parameters];
        res = @(result);
    }
    return res;
}

@end

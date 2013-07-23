//
//  ARJSQLSelectInvocation.m
//  ActiveRecord on Jails
//
//  Created by skonb on 2013/06/24.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ARJSQLSelectInvocation.h"
#import "ARJDatabaseManager.h"

@implementation ARJSQLSelectInvocation

-(id)invokeInDatabaseManager:(ARJDatabaseManager*)manager{
    __block id res = nil;
    [manager runInTransaction:^BOOL(id database){
        res = [database executeQuery:self.SQLString withArgumentsInArray:self.parameters];
        return res != nil;
    }];
    return res;
}

@end

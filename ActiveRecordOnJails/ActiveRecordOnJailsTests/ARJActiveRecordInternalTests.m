//
//  ARJActiveRecordInternalTests.m
//  ActiveRecordOnJails
//
//  Created by skonb on 2013/07/02.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ARJActiveRecordInternalTests.h"
#import "ARJActiveRecordTests.h"
#import "ARJDatabaseManager.h"
#import "SPTestUser.h"
#import "SPTestOrganization.h"

@implementation ARJActiveRecordInternalTests

-(void)setUp{
    [[ARJDatabaseManager defaultManager]setDbName:@"test.sqlite"];
    [[ARJDatabaseManager defaultManager]setModels:@[@"SPTestUser", @"SPTestOrganization"]];
    [[ARJDatabaseManager defaultManager]migrate];
}

-(void)tearDown{
    [[ARJDatabaseManager defaultManager]deleteDB];
}


-(void)testReload{
    SPTestUser * user = [SPTestUser create:@{@"age": @(1)}];
    [user update:@{@"age": @(10)}];
    STAssertEqualObjects(user._updateDictionary[@"age"], @(10), @"properties are in update dictionary");
    [user reload];
    STAssertTrue(user._updateDictionary.count==0, @"no update dictionary");
    STAssertEqualObjects(user._columnDictionary[@"age"], @(10), @"updates in column dictionary");
}

-(void)testMultiThread{
    __block NSMutableArray *array = [NSMutableArray array];
    NSRecursiveLock * lock = [NSRecursiveLock new];
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i < 100; ++i) {
        dispatch_async(queue, ^{
            SPTestUser *user = [SPTestUser create:@{@"age": @(10)}];
            [lock lock];
            [array addObject:user];
            [lock unlock];
        });
    }
    dispatch_barrier_sync(queue, ^{
        STAssertTrue(array.count==100, @"");
    });
}

-(void)testCorrespondingDatabaseManager{
    SPTestOrganization *organization = [SPTestOrganization create:@{@"name": @"test"}];
    STAssertTrue(organization.correspondingDatabaseManager == [ARJDatabaseManager defaultManager], @"corresponding DatabaseManager");
}

@end

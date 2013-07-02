//
//  ARJActiveRecordTests.m
//  ActiveRecordOnJails
//
//  Created by skonb on 2013/07/02.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ARJActiveRecordTests.h"
#import "ARJDatabaseManager.h"
#import "SPTestUser.h"
#import "SPTestOrganization.h"

@implementation ARJActiveRecordTests
-(void)setUp{
    [[ARJDatabaseManager defaultManager]setDbName:@"test.sqlite"];
    [[ARJDatabaseManager defaultManager]setModels:@[@"SPTestUser", @"SPTestOrganization"]];
    [[ARJDatabaseManager defaultManager]migrate];
}

-(void)tearDown{
    [[ARJDatabaseManager defaultManager]deleteDB];
}


- (void)testSaveForCreate
{
    SPTestUser *user = [SPTestUser new];
    [user setAttribute:@(10) forKey:@"age"];
    BOOL res = [user save];
    STAssertTrue(res, [user.errors.fullMessages componentsJoinedByString:@"\n"]);
}

-(void)testFind{
    SPTestUser *user = [[SPTestUser alloc]initWithDictionary:@{@"age" : @(10)}];
    [user save];
    user = [[SPTestUser alloc]initWithDictionary:@{@"age": @(10)}];
    [user save];
    NSArray * users = [SPTestUser find:@{@"age": @(10)}];
    STAssertTrue(users.count==2, @"");
}

-(void)testFindFirst{
    SPTestUser *user = [SPTestUser new];
    [user setAttribute:@(20) forKey:@"age"];
    [user save];
    
    user = [SPTestUser findFirst:@{@"age" : @(20)}];
    STAssertTrue(user != nil, @"");
}

-(void)testCreate{
    SPTestUser *user = [SPTestUser create:@{@"name": @"some name", @"age" : @(30)}];
    STAssertTrue(user != nil, @"creation");
    
    user = [SPTestUser findFirst:@{@"name" : @"some name"}];
    STAssertTrue(user != nil, @"find first");
    
}


-(void)testAssociation{
    SPTestUser *user = [SPTestUser create:@{@"age" : @(20)}];
    SPTestOrganization * org = [SPTestOrganization new];
    [org setAttribute:@"org name" forKey:@"name"];
    [user setAssociated:org forKey:@"organization"];
    BOOL res = [user save];
    NSString *mes = [user.errors.fullMessages componentsJoinedByString:@","];
    STAssertTrue(res, mes);
    STAssertTrue([[SPTestOrganization findAll]count]==1, @"should be saved");
}

-(void)testKVO{
    SPTestUser *user = [SPTestUser create:@{@"age" : @(20)}];
    user.name = @"some name";//This calles setAttribute:forKey:
    [user save];
    user = [SPTestUser findFirst:nil];
    STAssertEqualObjects([user attributeForKey:@"name"], @"some name", @"");
}

-(void)testUpdate{
    SPTestUser * user = [SPTestUser create:@{@"age" : @(30)}];
    [user update:@{@"name": @"some name"}];
    
    user = [SPTestUser findFirst:@{@"age": @(30)}];
    STAssertEqualObjects([user attributeForKey:@"name"], @"some name", @"update");
}

-(void)testSaveForUpdate{
    SPTestUser *user = [SPTestUser create:@{@"age": @(30)}];
    [user setAttribute:@"some name" forKey:@"name"];
    STAssertTrue([user save], @"save");
    user = [SPTestUser findFirst:@{@"age":@(30)}];
    STAssertEqualObjects([user attributeForKey:@"name"], @"some name", @"update");
}

@end

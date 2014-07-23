//
//  ARJActiveRecordTests.m
//  ActiveRecord on Jails
//
//  Created by skonb on 2013/07/02.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ARJActiveRecordTests.h"
#import "ARJDatabaseManager.h"
#import "CMUnitTestHelper.h"
#import "SPTestUser.h"
#import "SPTestOrganization.h"

@implementation ARJActiveRecordTests
-(void)setUp{
    [[ARJDatabaseManager defaultManager]setDbName:@"test.sqlite"];
    [[ARJDatabaseManager defaultManager]setModels:@[@"SPTestUser", @"SPTestOrganization"]];
    [[ARJDatabaseManager defaultManager]migrate];
    [[CMUnitTestHelper instance]setLogOutputPath:@"log.txt"];
    [[CMUnitTestHelper instance]clearLogFile];
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

-(void)testTimestampsWhenCreated{
    SPTestUser *user = [SPTestUser create:@{@"age" : @(30)}];
    user = [SPTestUser findFirst:nil];
    STAssertNotNil([user attributeForKey:@"created_at"], @"created at is set");
    STAssertEqualObjects([user attributeForKey:@"created_at"], [user attributeForKey:@"updated_at"], @"created_at and updated_at are indentical when created");
    STAssertTrue([[user attributeForKey:@"created_at"]timeIntervalSinceNow] < 0, @"created at is in past");
}


-(void)testTimestampsWhenUpdated{
    SPTestUser * user = [SPTestUser create:@{@"age": @(30)}];
    user = [SPTestUser findFirst:nil];
    NSDate *createdAt = [user attributeForKey:@"created_at"];
    [user setAttribute:@"name" forKey:@"name"];
    [user save];
    user = [SPTestUser findFirst:nil];
    NSDate *updatedAt = [user attributeForKey:@"updated_at"];
    STAssertEqualObjects(createdAt, [user attributeForKey:@"created_at"], @"created at does not change on udpate");
    STAssertNotNil(updatedAt, @"updated at is set");
    STAssertTrue([updatedAt timeIntervalSinceNow] < 0, @"updated at is in past");
}

-(void)testScope{
    [SPTestUser create:@{@"age" : @(5)}];
    [SPTestUser create:@{@"age": @(11)}];
    NSArray *users = [SPTestUser executeScopeForKey:@"under_age" withParams:@{@"age" : @(10)}];
    STAssertTrue(users.count==1, @"scope correctness");
}

-(void)testAfterInitialize{
    SPTestUser *user = [SPTestUser new];
    STAssertEqualObjects(user.customProperty[@"afterInitialize"], @YES, @"after initialzie");
}

-(void)testAfterSave{
    SPTestUser *user = [SPTestUser new];
    [user save];

    STAssertEqualObjects(user.customProperty[@"beforeSave"], @YES, @"before save");
    STAssertEqualObjects(user.customProperty[@"afterSave"], @YES, @"after save");
    STAssertEqualObjects(user.customProperty[@"beforeValidation"], @YES, @"before validation");
    STAssertEqualObjects(user.customProperty[@"afterValidation"], @YES, @"after validation");
    STAssertEqualObjects(user.customProperty[@"afterInitialize"], @YES, @"after initialzie");
    STAssertEqualObjects(user.customProperty[@"beforeCreate"], @YES, @"before create");
    STAssertEqualObjects(user.customProperty[@"afterCreate"], @YES, @"after create");
}

#ifdef ARJ_USE_DYNAMIC_METHOD_IMP

-(void)testDynamicGetterImp{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wundeclared-selector"
    SPTestUser *user = [SPTestUser new];
    [user setAttribute:@(1) forKey:@"age"];
    STAssertNoThrow([user performSelector:@selector(age)], @"dynamic attribute getter");
    STAssertEqualObjects([user performSelector:@selector(age)], @(1), @"dynamic attribute getter correctness");
    SPTestOrganization *org = [SPTestOrganization new];
    STAssertNoThrow([org performSelector:@selector(users)], @"dynamic association getter");
#pragma clang diagnostic pop
}

-(void)testDynamicSetterImp{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wundeclared-selector"
    SPTestUser *user = [SPTestUser new];
    STAssertNoThrow([user performSelector:@selector(setAge:) withObject:@(1)], @"dynamic attribute setter");
    STAssertEqualObjects([user attributeForKey:@"age"], @(1), @"dynamic attribute setter correctness");
    SPTestOrganization *org = [SPTestOrganization new];
    STAssertNoThrow([user performSelector:@selector(setOrganization:) withObject:org], @"dynamic association setter");
    STAssertEqualObjects([user associatedForKey:@"organization"], org, @"dynamic association setter correctness");
#pragma clang diagnostic pop
}

#endif /*ARJ_USE_DYNAMIC_METHOD_IMP*/

-(void)testInsertToHasMany{
    SPTestUser *user = [SPTestUser new];
//    [user save];
    SPTestOrganization *org = [SPTestOrganization new];
    [org save];
    [org insertAssociated:user forKey:@"users"];
    STAssertTrue([[org associatedForKey:@"users"]count]==1, @"inserted");
    [org reload];
    STAssertTrue([[org associatedForKey:@"users"]count]==1, @"retrieved after reload");
    [org save];
    SPTestUser *user2 = [SPTestUser new];
    [user2 save];
    [org insertAssociated:user2 forKey:@"users"];
    STAssertTrue([[org associatedForKey:@"users"]count]==2, @"2 inserted");
    [org reload];
    STAssertTrue([[org associatedForKey:@"users"]count]==2, @"retrieved after 1 insertion and reload");
    
    [org insertAssociated:user2 forKey:@"users"];
    STAssertTrue([[org associatedForKey:@"users"]count]==2, @"same object does not duplicates");
}

-(void)testDestroyDependency{
    SPTestOrganization *org = [[SPTestOrganization alloc]initWithDictionary:@{@"name" : @"test"}];
    [org save];
    [org insertAssociated:[SPTestUser new] forKey:@"users"];
    [org insertAssociated:[SPTestUser new] forKey:@"users"];
    STAssertTrue([[org associatedForKey:@"users"]count]==2, @"2 inserted");
    [org destroy];
    STAssertTrue([SPTestUser count:nil]==0, @"dependency destroyed");
}

-(void)testCount{
    [SPTestUser create:nil];
    STAssertTrue([SPTestUser count:nil]==1, @"correctly counted");
}

-(void)testRecursiveRelationship{
    SPTestUser *child = [SPTestUser create:nil];
    SPTestUser *parent = [SPTestUser create:nil];
    [child setAssociated:parent forKey:@"parent"];
    [child save];
    [child reload];
    [parent reload];
    
    STAssertNotNil([child associatedForKey:@"parent"], @"recursive relation");
    STAssertTrue([[parent associatedForKey:@"children"]count]==1, @"recursive relation");
}

@end

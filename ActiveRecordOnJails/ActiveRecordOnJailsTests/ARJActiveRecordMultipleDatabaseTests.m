//
//  ARJActiveRecordMultipleDatabaseTests.m
//  ActiveRecordOnJails
//
//  Created by skonb on 2013/07/02.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ARJActiveRecordMultipleDatabaseTests.h"
#import "ARJDatabaseManager.h"
#import "SPTestUser.h"
#import "SPTestOrganization.h"

@interface ARJActiveRecordMultipleDatabaseTests()
@end
static ARJDatabaseManager *manager1;
static ARJDatabaseManager *manager2;

@implementation ARJActiveRecordMultipleDatabaseTests

+(void)setUp{
    manager1 = [ARJDatabaseManager defaultManager];
    manager2 = [ARJDatabaseManager new];
}


-(void)setUp{
    [manager1 setDbName:@"test.sqlite"];
    [manager1 setModels:@[@"SPTestUser", @"SPTestOrganization"]];
    [manager1 migrate];
    [manager2 setDbName:@"test2.sqlite"];
    [manager2 setModels:@[@"SPTestUser", @"SPTestOrganization"]];
    [manager2 migrate];
}

-(void)tearDown{
    [manager1 deleteDB];
    [manager2 deleteDB];
}


-(void)testCorrespondingDatabaseManager{
    SPTestUser *user = [SPTestUser create:@{@"age": @(10)}];
    STAssertEqualObjects(user.correspondingDatabaseManager, manager1, @"default database");
    user = [SPTestUser create:@{@"age": @(10)} inDatabaseManager:manager2];
    STAssertEqualObjects(user.correspondingDatabaseManager, manager2, @"another database");
}

-(void)testDoNotInterfareAcrossDatabases{
    [SPTestUser create:@{@"age": @(10)}];
    [SPTestUser create:@{@"age": @(10)} inDatabaseManager:manager2];
    NSArray *usersIn1 = [SPTestUser find:@{@"age":@(10)}];
    STAssertTrue(usersIn1.count==1, @"default database");
    NSArray *usersIn2 = [SPTestUser find:@{@"age" : @(10)} inDatabaseManager:manager2];
    STAssertTrue(usersIn2.count==1, @"another database");
}

-(void)testAssociationIsSavedInCorrespondingDatabase{
    SPTestUser *user = [SPTestUser create:@{@"age": @(10)} inDatabaseManager:manager2];
    SPTestOrganization *org = [[SPTestOrganization alloc]initWithDictionary:@{@"name" : @"test"}];
    [user setAssociated:org forKey:@"organization"];
    STAssertTrue([user save], @"can save");
    STAssertTrue([[SPTestOrganization findAllInDatabaseManager:manager2]count]==1, @"find in another database");
    STAssertTrue([SPTestOrganization find:@{@"name": @"test"} inDatabaseManager:manager2]!=nil, @"searched");
}


@end

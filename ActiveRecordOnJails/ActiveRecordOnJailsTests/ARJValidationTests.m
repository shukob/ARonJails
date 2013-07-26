//
//  ARJValidationTests.m
//  ActiveRecord on Jails
//
//  Created by skonb on 2013/06/28.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ARJValidationTests.h"
#import "ARJDatabaseManager.h"
#import "SPTestUser.h"
#import "CMUnitTestHelper.h"
#import "SPTestOrganization.h"
#import <QuartzCore/QuartzCore.h>
@implementation ARJValidationTests


+(void)setUp{
    [[ARJDatabaseManager defaultManager]setDbName:@"test.sqlite"];
    [[ARJDatabaseManager defaultManager]setModels:@[@"SPTestUser", @"SPTestOrganization"]];
    [[ARJDatabaseManager defaultManager]migrate];
    [[CMUnitTestHelper instance]setLogOutputPath:@"log.txt"];
}

+(void)tearDown{
    [[ARJDatabaseManager defaultManager]deleteDB];
}


-(void)testValidateNumericality{
    @try {
        SPTestUser *user = [SPTestUser new];
        [user setAttribute:@(-1) forKey:@"age"];
        [user save];
        STAssertTrue(user.errors.count==1, @"numericality validation ");
    }
    @catch (NSException *exception) {
        CMUnitTestLogException(exception);
        STAssertTrue(NO, @"");
    }
    @finally {
        
    }
}

-(void)testValidateLength{
    SPTestUser *user = [SPTestUser new];
    [user setAttribute:@(10) forKey:@"age"];
    [user setAttribute:@";sdkafj;sdlkjfa;lskdjf;askldf" forKey:@"name"];
    [user save];
    STAssertTrue(user.errors.count==1, @"length validation");
}

-(void)testCustomValidation{
    SPTestUser *user = [SPTestUser new];
    UIGraphicsBeginImageContext(CGSizeMake(100, 100));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [[UIColor blackColor]CGColor]);
    CGContextFillRect(ctx, CGRectMake(0, 0, 100, 100));
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [user setAttribute:UIImageJPEGRepresentation(img, .4) forKey:@"picture"];
    [user setAttribute:@(10) forKey:@"age"];
    [user save];
    STAssertTrue(user.errors.count==0, @"custom function");
}

-(void)testCustomValidation2{
    SPTestUser *user = [SPTestUser new];
    UIGraphicsBeginImageContext(CGSizeMake(300, 300));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [[UIColor blackColor]CGColor]);
    CGContextFillRect(ctx, CGRectMake(0, 0, 100, 100));
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [user setAttribute:UIImageJPEGRepresentation(img, .4) forKey:@"picture"];
    [user setAttribute:@(10) forKey:@"age"];
    [user save];
    STAssertTrue(user.errors.count==1, @"custom function");
}


-(void)testPresenceValidation{
    SPTestOrganization *org = [SPTestOrganization new];
    [org save];
    STAssertTrue(org.errors.count==1, @"presence");
}

-(void)testFormatValidation{
    SPTestUser *user = [SPTestUser new];
    [user setAttribute:@(1) forKey:@"age"];
    [user setAttribute:@"skonb@me.com" forKey:@"email"];
    [user validate];
    STAssertTrue(user.errors.count==0, @"format validation");
}

-(void)testFormatValidationFail{
    SPTestUser *user = [SPTestUser new];
    [user setAttribute:@(3) forKey:@"age"];
    [user setAttribute:@";dlkjfa" forKey:@"email"];
    [user validate];
    STAssertTrue(user.errors.count==1, @"format validation");
}

-(void)testUniquenessValidation{
    SPTestUser *user = [SPTestUser new];
    [user setAttribute:@(10) forKey:@"age"];
    [user setAttribute:@"skonb@me.com" forKey:@"email"];
    [user save];
    STAssertTrue(user.errors.count==0, @"first one-unique");
    
    user = [SPTestUser new];
    [user setAttribute:@"skonb@me.com" forKey:@"email"];
    [user setAttribute:@(15) forKey:@"age"];
    [user save];
    STAssertTrue(user.errors.count==1, @"second one");
}



@end

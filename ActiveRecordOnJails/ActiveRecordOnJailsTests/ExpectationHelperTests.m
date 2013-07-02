//
//  ExpectationHelperTests.m
//  ActiveRecordOnJails
//
//  Created by skonb on 2013/06/28.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ExpectationHelperTests.h"
#import "ARJExpectationHelper.h"
@implementation ExpectationHelperTests

-(void)testN2C{
    NSString * before = @"some_id";
    NSString * after = @"someId";
    NSString * res = [[ARJExpectationHelper defaultHelper]camelizedFromNonCamelized:before];
    STAssertEqualObjects(after, res, @"N2C");
}

-(void)testC2N{
    NSString * before = @"someId";
    NSString * after = @"some_id";
    NSString * res = [[ARJExpectationHelper defaultHelper]nonCamelizedFromCamelized:before];
    STAssertEqualObjects(after, res, @"C2N");
}

-(void)testC2NBeginCamelized{
    NSString * before = @"SomeClass";
    NSString * after = @"some_class";
    NSString * res = [[ARJExpectationHelper defaultHelper]nonCamelizedFromCamelized:before];
    STAssertEqualObjects(after, res, @"C2N");
}

@end

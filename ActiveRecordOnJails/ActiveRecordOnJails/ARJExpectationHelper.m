//
//  ARJExpectationHelper.m
//  ActiveRecordOnJails
//
//  Created by ; on 2013/06/03.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ARJExpectationHelper.h"

@interface ARJExpectationHelper()
@property (nonatomic, strong) NSMutableDictionary * C2NonCDictionary;
@property (nonatomic, strong) NSRegularExpression *C2NonCRegex;
@property (nonatomic, strong) NSMutableDictionary * NonC2CDictionary;
@property (nonatomic, strong) NSRegularExpression *NonC2CRegex1;
@property (nonatomic, strong) NSRegularExpression *NonC2CRegex2;
@property (nonatomic, strong) NSRegularExpression *NonC2CRegex3;
@end

@implementation ARJExpectationHelper

-(id)init{
    if ([super init]) {
        self.C2NonCDictionary = [NSMutableDictionary new];
        self.NonC2CDictionary = [NSMutableDictionary new];
    }
    return self;
}

-(NSString*)nonCamelizedFromCamelized:(NSString*)camelized{
    if (!(self.C2NonCDictionary)[camelized]) {
        if (!self.C2NonCRegex) {
            NSError *error;
            self.C2NonCRegex = [NSRegularExpression regularExpressionWithPattern:@"([^A-Z]+)([A-Z])" options:0 error:&error];
        }
        NSString * nonC = [[self.C2NonCRegex stringByReplacingMatchesInString:camelized options:0 range:NSMakeRange(0, camelized.length) withTemplate:@"$1_$2"]lowercaseString];
        (self.C2NonCDictionary)[camelized] = nonC;
    }
    return (self.C2NonCDictionary)[camelized];
    
}

-(NSString*)camelizedFromNonCamelized:(NSString*)nonCamelized{
    if (!self.NonC2CDictionary[nonCamelized]) {
        if (!self.NonC2CRegex1) {
            NSError *error;
            self.NonC2CRegex1 = [NSRegularExpression regularExpressionWithPattern:@"\\A[_0-9]*([a-z])" options:0 error:&error];
            self.NonC2CRegex2 = [NSRegularExpression regularExpressionWithPattern:@"_+([a-z])" options:0 error:&error];
            self.NonC2CRegex3 = [NSRegularExpression regularExpressionWithPattern:@"\\*[a-z]" options:0 error:&error];
        }
        NSMutableString *res = [NSMutableString stringWithString:nonCamelized];
        [self.NonC2CRegex1 replaceMatchesInString:res options:0 range:NSMakeRange(0, res.length) withTemplate:@"$1"];
        [self.NonC2CRegex2 replaceMatchesInString:res options:0 range:NSMakeRange(0, res.length) withTemplate:@"*$1"];
        NSArray *matches = [self.NonC2CRegex3 matchesInString:res options:0 range:NSMakeRange(0, res.length)];
        for(NSTextCheckingResult *result in matches){
            NSString *thisString = [[res substringWithRange:result.range]substringWithRange:NSMakeRange(1, 1)];;
            [res replaceCharactersInRange:result.range withString:[thisString uppercaseString]];
        }
        self.NonC2CDictionary[nonCamelized]=res;
    }
    return self.NonC2CDictionary[nonCamelized];
}

static ARJExpectationHelper * ___instance;
+(ARJExpectationHelper*)defaultHelper{
    if (!___instance) {
        ___instance = [ARJExpectationHelper new];
    }
    return ___instance;
}

@end

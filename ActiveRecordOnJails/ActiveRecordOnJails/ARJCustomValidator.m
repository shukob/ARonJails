//
//  ARJCustomValidator.m
//  ActiveRecordOnJails
//
//  Created by skonb on 2013/06/24.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ARJCustomValidator.h"
#import "ARJActiveRecord.h"
@interface ARJCustomValidator()
@property (nonatomic, assign) SEL selector;
@end

@implementation ARJCustomValidator

-(id)initWithDictionary:(NSDictionary *)dictionary{
    if ([super initWithDictionary:dictionary]) {
        self.selector = NSSelectorFromString(self.dictionary[ARJValidationFunctionSpecifier]);
    }
    return self;
}

-(BOOL)validateInstance:(ARJActiveRecord*)instance inDatabaseManager:(ARJDatabaseManager *)manager{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    BOOL res = [[[instance class] performSelector: NSSelectorFromString(self.dictionary[ARJValidationFunctionSpecifier]) withObject:instance]boolValue];
#pragma clang diagnostic pop
    return res;
}


@end

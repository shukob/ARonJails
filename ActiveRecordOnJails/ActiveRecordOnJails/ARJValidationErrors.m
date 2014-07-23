//
//  ARJValidationErrors.m
//  ActiveRecord on Jails
//
//  Created by skonb on 2013/06/24.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ARJValidationErrors.h"
#import "ARJActiveRecordHelper.h"
@interface ARJValidationErrors()
@property (nonatomic, strong) NSMutableDictionary * errors;
@end
@implementation ARJValidationErrors
@synthesize count = _count;
+(ARJValidationErrors*)errors{
    return [ARJValidationErrors new];
}

-(id)init{
    if ([super init]) {
        self.errors = [NSMutableDictionary dictionary];
    }
    return self;
    
}

-(void)addErrorMessage:(NSString*)message forKey:(NSString*)key{
    if (!self.errors[key]) {
        self.errors[key] = [NSMutableArray array];
    }
    [self.errors[key]addObject:message];
    ++_count;
}
-(void)mergeErrors:(ARJValidationErrors*)other{
    [self mergeErrors:other keyPrefix:nil];
}

-(void)mergeErrors:(ARJValidationErrors *)other keyPrefix:(NSString*)keyPrefix{
    for (NSString * key in other.errors.allKeys){
        NSString *thisKey = key;
        if (keyPrefix) {
            thisKey = [keyPrefix stringByAppendingString:key];
        }
        for (NSString * message in other.errors[key]){
            [self addErrorMessage:message forKey:thisKey];
        }
    }
}

-(void)addErrorMessages:(NSArray*)messages forKey:(NSString*)key{
    for (NSString *message in messages){
        [self addErrorMessage:message forKey:key];
    }
}

-(void)clearErrors{
    _count = 0;
    [self.errors removeAllObjects];
}

-(NSArray*)fullMessages{
    NSMutableArray *res = [NSMutableArray array];
    for (NSString * key in self.errors.allKeys){
        for (NSString * mes in self.errors[key]){
            if ([key isEqualToString:ARJValidationBaseTargetSpecifier]) {
                [res addObject:[NSString stringWithFormat:@"%@", mes]];
            }else{
                [res addObject:[NSString stringWithFormat:@"%@ : %@", key , mes]];
            }
        }
    }
    return res;
}

@end

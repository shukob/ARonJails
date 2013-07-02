//
//  ARJLengthValidator.m
//  ActiveRecordOnJails
//
//  Created by skonb on 2013/06/24.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ARJLengthValidator.h"
#import "ARJActiveRecord.h"
@interface ARJLengthValidator()

@end
@implementation ARJLengthValidator

-(id)initWithDictionary:(NSDictionary *)dictionary{
    if ([super initWithDictionary:dictionary]) {
        [self constructPredicates];
    }
    return self;
}

-(void)constructPredicates{
    for (NSString * key in self.dictionary){
        NSPredicate *predicate = [self predicateForKey:key value:self.dictionary[key]];
        if (predicate) {
            [self.predicates addObject:predicate];
        }
    }
}

-(NSPredicate*)predicateForKey:(NSString*)key value:(id)value{
    NSPredicate *predicate = nil;
    
    if ([key isEqualToString:ARJValidationEqualToSpecifier]) {
        predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self.length = %@", value]];
    }else if([key isEqualToString:ARJValidationGreaterThanSpecifier]){
        predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self.length > %@", value]];
    }else if([key isEqualToString:ARJValidationLessThanSpecifier]){
        predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self.length < %@", value]];
    }else if([key isEqualToString:ARJValidationLessThanOrEqualToSpecifier]){
        predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self.length <= %@", value]];
    }else if([key isEqualToString:ARJValidationGreaterThanOrEqualToSpecifier]){
        predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self.length >= %@", value]];
    }
    return predicate;
}

-(NSArray*)validateValue:(id)value{
    NSMutableArray *res = [NSMutableArray array];
    for (NSPredicate *predicate in self.predicates){
        if (![predicate evaluateWithObject:value]) {
            [res addObject:[NSString stringWithFormat:@"Length Error: %@", predicate.predicateFormat]];
        }
    }
    return res;
}


@end

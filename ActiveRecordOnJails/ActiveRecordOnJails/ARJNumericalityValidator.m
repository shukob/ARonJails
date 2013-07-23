//
//  ARJNumericalityValidator.m
//  ActiveRecord on Jails
//
//  Created by skonb on 2013/06/24.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ARJNumericalityValidator.h"
#import "ARJActiveRecordHelper.h"
@interface ARJNumericalityValidator()
@property (nonatomic, strong) NSMutableArray *predicates;
@end
@implementation ARJNumericalityValidator

-(id)initWithDictionary:(NSDictionary *)dictionary{
    if ([super initWithDictionary:dictionary]) {
        [self constructPredicates];
    }
    return self;
}

-(NSArray*)validateValue:(id)value{
    NSNumber *num = value;
    NSMutableArray *res = [NSMutableArray array];
    for (NSPredicate *predicate in self.predicates){
        if (![predicate evaluateWithObject:num]) {
            [res addObject:[NSString stringWithFormat:@"Numericality Error: %@", predicate.predicateFormat]];
        }
    }
    return res;
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
        predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self = %@", value]];
    }else if([key isEqualToString:ARJValidationGreaterThanSpecifier]){
        predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self > %@", value]];
    }else if([key isEqualToString:ARJValidationLessThanSpecifier]){
        predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self < %@", value]];
    }else if([key isEqualToString:ARJValidationLessThanOrEqualToSpecifier]){
        predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self <= %@", value]];
    }else if([key isEqualToString:ARJValidationGreaterThanOrEqualToSpecifier]){
        predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self >= %@", value]];
    }
    return predicate;
}


@end

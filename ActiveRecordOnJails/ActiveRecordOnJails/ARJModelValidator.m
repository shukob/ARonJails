//
//  ARJModelValidator.m
//  ActiveRecord on Jails
//
//  Created by skonb on 2013/06/24.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ARJModelValidator.h"
#import "ARJActiveRecordHelper.h"
#import "ARJNumericalityValidator.h"
#import "ARJFormatValidator.h"
#import "ARJLengthValidator.h"
#import "ARJPresenceValidator.h"
#import "ARJUniquenessValidator.h"
#import "ARJCustomValidator.h"
#import "ARJAcceptanceValidator.h"
#import "ARJActiveRecord.h"
#import "ARJAssociationValidator.h"
@implementation ARJModelValidator
@synthesize validationTiming = _validationTiming;
-(id)initWithDictionary:(NSDictionary *)dictionary{
    if ([super init]) {
        self.dictionary = dictionary;
        self.predicates = [NSMutableArray array];
        [self updateValidationTiming];
    }
    return self;
}

+(ARJModelValidator*)modelValidatorWithDictionary:(NSDictionary*)dictionary{
    NSString * type = dictionary[ARJValidationTypeSpecifier];
    ARJModelValidator * validator = nil;
    if ([type isEqualToString:ARJFormatValidationSpecifier]) {
        validator = [[ARJFormatValidator alloc]initWithDictionary:dictionary];
    }else if([type isEqualToString:ARJNumericalityValidationSpecifier]){
        validator = [[ARJNumericalityValidator alloc]initWithDictionary:dictionary];
    }else if([type isEqualToString:ARJLengthValidationSpecifier]){
        validator = [[ARJLengthValidator alloc]initWithDictionary:dictionary];
    }else if([type isEqualToString:ARJPresenceValidationSpecifier]){
        validator = [[ARJPresenceValidator alloc]initWithDictionary:dictionary];
    }else if([type isEqualToString:ARJUniquenessValidationSpecifier]){
        validator = [[ARJUniquenessValidator alloc]initWithDictionary:dictionary];
    }else if([type isEqualToString:ARJCustomValidationSpecifier]){
        validator = [[ARJCustomValidator alloc]initWithDictionary:dictionary];
    }else if([type isEqualToString:ARJAcceptanceValidationSpecifier]){
        validator = [[ARJAcceptanceValidator alloc]initWithDictionary:dictionary];
    }else if([type isEqualToString:ARJAssociationValidationSpecifier]){
        validator = [[ARJAssociationValidator alloc]initWithDictionary:dictionary];
    }
    return validator;
}

-(BOOL)validateInstance:(ARJActiveRecord*)instance{
    return [self validateInstance:instance inDatabaseManager:instance.correspondingDatabaseManager];
}

-(BOOL)validateInstance:(ARJActiveRecord *)instance inDatabaseManager:(ARJDatabaseManager *)manager{
    id value = [instance latestValueForKey:self.targetProperty];
    if ([self validateBlankValue:value]) {
        return YES;
    }else{
        NSArray * messages = [self validateValue:value inDatabaseManager:manager];
        [instance.errors addErrorMessages:messages forKey:self.targetProperty];
        return NO;
    }
}

-(BOOL)validateInstance:(ARJActiveRecord *)instance onTiming:(ARJModelValidatorValidationTiming)timing inDatabaseManager:(ARJDatabaseManager*)manager{
    if (![self requiresValidationOnTiming:timing]) {
        return YES;
    }
    return [self validateInstance:instance inDatabaseManager:manager];
}

-(BOOL)validateInstance:(ARJActiveRecord *)instance onTiming:(ARJModelValidatorValidationTiming)timing{
    return [self validateInstance:instance onTiming:timing inDatabaseManager:instance.correspondingDatabaseManager];
}

-(NSString*)targetColumnName{
    return self.dictionary[ARJValidationTargetSpecifier];
}

-(BOOL)validateBlankValue:(id)value{
    if ([self.dictionary[ARJValidationAllowBlankSpecifier]boolValue] && arj_blank(value)) {
        return YES;
    }else{
        return NO;
    }
}

-(NSArray*)validateValue:(id)value{
    [self doesNotRecognizeSelector:@selector(validateValue:)];
    return nil;
}

-(NSArray*)validateValue:(id)value inDatabaseManager:(ARJDatabaseManager *)manager{
    return [self validateValue:value];
}

-(void)updateValidationTiming{
    if (self.dictionary[ARJValidationOnSpecifier]) {
        NSArray *targets = nil;
        if ([self.dictionary[ARJValidationOnSpecifier]isKindOfClass:[NSArray class]]) {
            targets = self.dictionary[ARJValidationOnSpecifier];
        }else{
            targets = @[self.dictionary[ARJValidationOnSpecifier]];
        }
        for (NSString * specifier in targets){
            if ([specifier isEqualToString:ARJValidationTimingOnCraete]) {
                _validationTiming|=ARJModelValidatorValidationTimingOnCreate;
            }else if([specifier isEqualToString:ARJValidationTimingOnUpdate]){
                _validationTiming|=ARJModelValidatorValidationTimingOnUpdate;
            }
        }
    }else{
        _validationTiming = ARJModelValidatorValidationTimingOnCreate | ARJModelValidatorValidationTimingOnUpdate;
    }
}

-(BOOL)requiresValidationOnTiming:(ARJModelValidatorValidationTiming)timing{
    return self.validationTiming & timing;
}

-(NSString*)targetProperty{
    return self.dictionary[ARJValidationTargetSpecifier];
}

@end

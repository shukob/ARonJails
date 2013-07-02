//
//  ARJModelValidator.h
//  ActiveRecordOnJails
//
//  Created by skonb on 2013/06/24.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARJValidationErrors.h"
@class ARJActiveRecord;

typedef enum _ARJModelValidatorValidationTiming{
    ARJModelValidatorValidationTimingOnNone = 0 ,
    ARJModelValidatorValidationTimingOnCreate = 1,
    ARJModelValidatorValidationTimingOnUpdate = 1 << 1,
}ARJModelValidatorValidationTiming;
@class ARJDatabaseManager;
@interface ARJModelValidator : NSObject
@property (nonatomic, strong) NSDictionary * dictionary;
@property (nonatomic, readonly) NSString * targetProperty;
@property (nonatomic, strong) NSMutableArray * predicates;
@property (nonatomic, readonly) ARJModelValidatorValidationTiming validationTiming;
-(id)initWithDictionary:(NSDictionary*)dictionary;
+(ARJModelValidator*)modelValidatorWithDictionary:(NSDictionary*)dictionary;
-(BOOL)validateInstance:(ARJActiveRecord*)instance;
-(BOOL)validateInstance:(ARJActiveRecord*)instance inDatabaseManager:(ARJDatabaseManager*)manager;
-(BOOL)validateInstance:(ARJActiveRecord *)instance onTiming:(ARJModelValidatorValidationTiming)timing;
-(BOOL)validateInstance:(ARJActiveRecord *)instance onTiming:(ARJModelValidatorValidationTiming)timing inDatabaseManager:(ARJDatabaseManager*)manager;
-(NSArray*)validateValue:(id)value;
-(NSArray*)validateValue:(id)value inDatabaseManager:(ARJDatabaseManager*)manager;
-(BOOL)validateBlankValue:(id)value;
-(BOOL)requiresValidationOnTiming:(ARJModelValidatorValidationTiming)timing;
@end

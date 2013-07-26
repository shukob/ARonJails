//
//  ARJActiveRecordHelper.m
//  ActiveRecord on Jails
//
//  Created by skonb on 2013/06/03.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ARJActiveRecordHelper.h"
#import "ARJActiveRecord.h"
NSString * const ARJAttributeTypeSpecifier = @"attribute_type";
NSString * const ARJAttributeNameSpecifier = @"attribute_name";
NSString * const ARJRelationTypeSpecifier = @"relation_type";
NSString * const ARJRelationNameSpecifier = @"relation_name";
NSString * const ARJPropertyNameSpecifier = @"property_name";
NSString * const ARJAttributeDefaultValueSpecifier = @"default";
NSString * const ARJAttributeNullSpecifier = @"null";


NSString * const ARJStringAttributeSpecifier = @"string";
NSString * const ARJIntegerAttributeSpecifier = @"integer";
NSString * const ARJDateTimeAttributeSpecifier = @"datetime";
NSString * const ARJBlobAttributeSpecifier = @"blob";
NSString * const ARJFloatAttributeSpecifier = @"float";

NSString * const ARJHasManyRelationSpecifier = @"has_many";
NSString * const ARJBelongsToRelationSpecifier = @"belongs_to";
NSString * const ARJHasOneRelationSpecifier = @"has_one";

NSString * const ARJDependencyDestroySpecifier = @"destroy";
NSString * const ARJDependencyNullifySpecifier = @"nullify";

NSString * const ARJAttributesSpecifier = @"attributes";
NSString * const ARJRelationsSpecifier = @"relations";


NSString * const ARJClassNameSpecifier = @"class";
NSString * const ARJForeignKeySpecifier = @"foreign_key";
NSString * const ARJAssociationKeySpecifier = @"association_key";
NSString * const ARJDependencySpecifier = @"dependent";
NSString * const ARJInverseRelationSpecifier = @"inverse_of";
NSString * const ARJAutoSaveSpecifier = @"autosave";
NSString * const ARJThroughSpecifier = @"through";

NSString * const ARJValidationTypeSpecifier = @"validation_type";
NSString * const ARJValidationTargetSpecifier = @"validation_target";

NSString * const ARJPresenceValidationSpecifier = @"presence";
NSString * const ARJLengthValidationSpecifier = @"length";
NSString * const ARJNumericalityValidationSpecifier = @"numericality";
NSString * const ARJFormatValidationSpecifier = @"format";
NSString * const ARJUniquenessValidationSpecifier = @"uniqueness";
NSString * const ARJCustomValidationSpecifier = @"function";
NSString * const ARJAcceptanceValidationSpecifier = @"acceptance";
NSString * const ARJAssociationValidationSpecifier = @"associated";


NSString * const ARJValidationAllowBlankSpecifier = @"allow_blank";
NSString * const ARJValidationOnSpecifier = @"on";
NSString * const ARJValidationIfSpecifier = @"if";
NSString * const ARJValidationMessageSpecifier = @"message";
NSString * const ARJValidationFormatSpecifier = @"format";
NSString * const ARJValidationLessThanSpecifier = @"less_than";
NSString * const ARJValidationGreaterThanSpecifier = @"greater_than";
NSString * const ARJValidationLessThanOrEqualToSpecifier = @"less_than_or_equal_to";
NSString * const ARJValidationGreaterThanOrEqualToSpecifier = @"greater_than_or_equal_to";
NSString * const ARJValidationEqualToSpecifier = @"equal_to";
NSString * const ARJValidationFormatOptionSpecifier = @"format_option";
NSString * const ARJValidationFunctionSpecifier = @"selector";

NSString * const ARJValidationTimingOnCraete = @"create";
NSString * const ARJValidationTimingOnUpdate = @"update";
NSString * const ARJValidationBaseTargetSpecifier = @"__base__";

NSString * const ARJScopeNameSpecifier = @"name";
NSString * const ARJScopeFactorySpecifier = @"factory";

NSString * const ARJCallbackTimingBeforeCreate = @"before_create";
NSString * const ARJCallbackTimingAfterCreate = @"after_create";
NSString * const ARJCallbackTimingBeforeValidation = @"before_validation";
NSString * const ARJCallbackTimingAfterValidation = @"after_validation";
NSString * const ARJCallbackTimingBeforeSave = @"before_save";
NSString * const ARJCallbackTimingAfterSave = @"after_save";
NSString * const ARJCallbackTimingBeforeDestroy = @"before_destroy";
NSString * const ARJCallbackTimingAfterDestroy = @"after_destroy";
NSString * const ARJCallbackTimingAfterCommit = @"after_commit";
NSString * const ARJCallbackTimingAfterInitialize = @"after_initialize";

NSString * const ARJCallbackTimingSpecifier = @"callback_at";
NSString * const ARJCallbackFunctionSpecifier = @"callback_function";


@interface ARJActiveRecordHelper()
@property (nonatomic, strong) NSRegularExpression *valuePlaceholderRegex;
@property (nonatomic, strong) NSRegularExpression *tableSpecificationRegex;
@end

@implementation ARJActiveRecordHelper

-(id)init{
    if ([super init]) {
        self.valuePlaceholderRegex = [NSRegularExpression regularExpressionWithPattern:@"^.+ *\\?.*$" options:0 error:nil];
        self.tableSpecificationRegex = [NSRegularExpression regularExpressionWithPattern:@"^.+\\..+$" options:0 error:nil];
    }
    return self;
}


-(BOOL)hasValuePlaceholderInString:(NSString*)string{
    return [[self.valuePlaceholderRegex matchesInString:string options:0 range:NSMakeRange(0, string.length)]count]>0;
}

-(BOOL)hasTableSpecificationInString:(NSString*)string{
    return [[self.tableSpecificationRegex matchesInString:string options:0 range:NSMakeRange(0, string.length)] count]>0;

}


static ARJActiveRecordHelper * ___instance;
+(ARJActiveRecordHelper*)defaultHelper{
    if (!___instance) {
        ___instance = [ARJActiveRecordHelper new];
    }
    return ___instance;
}

-(BOOL)hasSameRecord:(ARJActiveRecord*)record inEnumerable:(id)enumerable{
    return [[enumerable indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj Id] && [obj Id]==[record Id];
    }]count] != 0;
}

@end
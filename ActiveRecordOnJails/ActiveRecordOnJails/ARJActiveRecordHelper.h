//
//  ARJActiveRecordHelper.h
//  ActiveRecord on Jails
//
//  Created by skonb on 2013/06/03.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const ARJAttributeTypeSpecifier;
extern NSString * const ARJAttributeNameSpecifier;
extern NSString * const ARJRelationTypeSpecifier;
extern NSString * const ARJRelationNameSpecifier;
extern NSString * const ARJPropertyNameSpecifier;
extern NSString * const ARJAttributeDefaultValueSpecifier;
extern NSString * const ARJAttributeNullSpecifier;

extern NSString * const ARJStringAttributeSpecifier;
extern NSString * const ARJIntegerAttributeSpecifier;
extern NSString * const ARJDateTimeAttributeSpecifier;
extern NSString * const ARJBlobAttributeSpecifier;
extern NSString * const ARJFloatAttributeSpecifier;

extern NSString * const ARJHasManyRelationSpecifier;
extern NSString * const ARJBelongsToRelationSpecifier;
extern NSString * const ARJHasOneRelationSpecifier;

extern NSString * const ARJDependencyDestroySpecifier;
extern NSString * const ARJDependencyNullifySpecifier;

extern NSString * const ARJAttributesSpecifier;
extern NSString * const ARJRelationsSpecifier;

extern NSString * const ARJClassNameSpecifier;
extern NSString * const ARJForeignKeySpecifier;
extern NSString * const ARJAssociationKeySpecifier;
extern NSString * const ARJDependencySpecifier;
extern NSString * const ARJInverseRelationSpecifier;
extern NSString * const ARJAutoSaveSpecifier;
extern NSString * const ARJThroughSpecifier;

extern NSString * const ARJValidationTypeSpecifier;
extern NSString * const ARJValidationTargetSpecifier;

extern NSString * const ARJPresenceValidationSpecifier;
extern NSString * const ARJLengthValidationSpecifier;
extern NSString * const ARJNumericalityValidationSpecifier;
extern NSString * const ARJFormatValidationSpecifier;
extern NSString * const ARJUniquenessValidationSpecifier;
extern NSString * const ARJCustomValidationSpecifier;
extern NSString * const ARJAcceptanceValidationSpecifier;
extern NSString * const ARJAssociationValidationSpecifier;

extern NSString * const ARJValidationAllowBlankSpecifier;
extern NSString * const ARJValidationOnSpecifier;
extern NSString * const ARJValidationIfSpecifier;
extern NSString * const ARJValidationMessageSpecifier;
extern NSString * const ARJValidationFormatSpecifier;
extern NSString * const ARJValidationFormatOptionSpecifier;
extern NSString * const ARJValidationLengthRequirementsSpecifier;
extern NSString * const ARJValidationLessThanSpecifier;
extern NSString * const ARJValidationGreaterThanSpecifier;
extern NSString * const ARJValidationLessThanOrEqualToSpecifier;
extern NSString * const ARJValidationGreaterThanOrEqualToSpecifier;
extern NSString * const ARJValidationEqualToSpecifier;
extern NSString * const ARJValidationFunctionSpecifier;

extern NSString * const ARJValidationTimingOnCraete;
extern NSString * const ARJValidationTimingOnUpdate;
extern NSString * const ARJValidationBaseTargetSpecifier;

extern NSString * const ARJScopeNameSpecifier;
extern NSString * const ARJScopeFactorySpecifier;

extern NSString * const ARJCallbackTimingBeforeCreate;
extern NSString * const ARJCallbackTimingAfterCreate;
extern NSString * const ARJCallbackTimingBeforeValidation;
extern NSString * const ARJCallbackTimingAfterValidation;
extern NSString * const ARJCallbackTimingBeforeSave;
extern NSString * const ARJCallbackTimingAfterSave;
extern NSString * const ARJCallbackTimingBeforeDestroy;
extern NSString * const ARJCallbackTimingAfterDestroy;
extern NSString * const ARJCallbackTimingAfterCommit;
extern NSString * const ARJCallbackTimingAfterInitialize;

extern NSString * const ARJCallbackTimingSpecifier;
extern NSString * const ARJCallbackFunctionSpecifier;

#define arj_nil(target) (!(target) || (NSNull*)(target) == [NSNull null])

#define arj_not_nil(target) ((target) && (NSNull*)(target) != [NSNull null])

#define arj_blank(target) (arj_nil((target)) || ([(target) isKindOfClass:[NSString class]] && [(NSString*)(target) length]==0) || ([(target) isKindOfClass:[NSNumber class]] && [(NSNumber*)(target) integerValue]==0) || ([(target) isKindOfClass:[NSArray class]] && [(NSArray*)(target) count]==0))

#define arj_present(target) (arj_not_nil((target)) && (([(target) isKindOfClass:[NSString class]] && [(NSString*)(target) length]!=0) || ([(target) isKindOfClass:[NSNumber class]] && [(NSNumber*)(target) integerValue]!=0) || ([(target) isKindOfClass:[NSArray class]] && [(NSArray*)(target) count]!=0)) || (![(target) isKindOfClass:[NSArray class]] && ![(target) isKindOfClass:[NSNumber class]] && ![(target) isKindOfClass:[NSString class]]))

#define arj_model(name) +(NSString*)model{return @#name;}

#define arj_attributes_with_relational_keys static NSMutableDictionary *__arj__attributes__with_relational__keys_cache;\
+(NSDictionary*)attributesWithRelationalKeys{\
    if(!__arj__attributes__with_relational__keys_cache){\
        NSDictionary *attributes = [self attributes];\
        NSDictionary *relations = [self relations];\
        NSMutableDictionary *targetAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];\
        for (ARJRelation *relation in relations.allValues){\
            NSDictionary *thisAttributes = [relation attributes];\
            if (thisAttributes) {\
                [targetAttributes addEntriesFromDictionary:thisAttributes];\
            }\
        }\
        __arj__attributes__with_relational__keys_cache = targetAttributes;\
    }\
    return __arj__attributes__with_relational__keys_cache;\
}

#define arj_string(name, ...) @{ARJAttributeTypeSpecifier : ARJStringAttributeSpecifier, ARJAttributeNameSpecifier : @#name, __VA_ARGS__}
#define arj_integer(name, ...) @{ARJAttributeTypeSpecifier : ARJIntegerAttributeSpecifier, ARJAttributeNameSpecifier : @#name,  __VA_ARGS__}
#define arj_datetime(name, ...) @{ARJAttributeTypeSpecifier : ARJDateTimeAttributeSpecifier, ARJAttributeNameSpecifier : @#name,  __VA_ARGS__}
#define arj_blob(name, ...) @{ARJAttributeTypeSpecifier : ARJBlobAttributeSpecifier, ARJAttributeNameSpecifier : @#name,  __VA_ARGS__}
#define arj_float(name, ...) @{ARJAttributeTypeSpecifier : ARJFloatAttributeSpecifier, ARJAttributeNameSpecifier : @#name, __VA_ARGS__}

#define arj_has_many(relations, ...) @{ARJRelationTypeSpecifier : ARJHasManyRelationSpecifier, ARJRelationNameSpecifier : @#relations, __VA_ARGS__}
#define arj_has_one(relation, ...) @{ARJRelationTypeSpecifier : ARJHasOneRelationSpecifier, ARJRelationNameSpecifier : @#relation, __VA_ARGS__}
#define arj_belongs_to(relation, ...) @{ARJRelationTypeSpecifier : ARJBelongsToRelationSpecifier, ARJRelationNameSpecifier : @#relation,  __VA_ARGS__}

#define arj_validates_presence_of(property, ...)  @{ARJValidationTypeSpecifier : ARJPresenceValidationSpecifier, ARJValidationTargetSpecifier : @#property, __VA_ARGS__}
#define arj_validates_uniqueness_of(property, ...) @{ARJValidationTypeSpecifier : ARJUniquenessValidationSpecifier, ARJValidationTargetSpecifier : @#property,  __VA_ARGS__}
#define arj_validates_length_of(property, ...) @{ARJValidationTypeSpecifier : ARJLengthValidationSpecifier, ARJValidationTargetSpecifier : @#property,  __VA_ARGS__}
#define arj_validates_format_of(property, format, ...) @{ARJValidationTypeSpecifier : ARJFormatValidationSpecifier, ARJValidationTargetSpecifier : @#property, ARJValidationFormatSpecifier : format,  __VA_ARGS__}
#define arj_validate(function, ...) @{ARJValidationTypeSpecifier : ARJCustomValidationSpecifier, ARJValidationFunctionSpecifier : @#function, ARJValidationTargetSpecifier : ARJValidationBaseTargetSpecifier,  __VA_ARGS__}
#define arj_validates_numericality_of(property, ...) @{ARJValidationTypeSpecifier : ARJNumericalityValidationSpecifier, ARJValidationTargetSpecifier : @#property,   __VA_ARGS__}
#define arj_validates_associated(relation, ...) @{ARJValidationTypeSpecifier : ARJAssociationValidationSpecifier, ARJValidationTargetSpecifier : @#relation,  __VA_ARGS__}

#define arj_scope(name, block) @{ARJScopeNameSpecifier: @#name, ARJScopeFactorySpecifier: [ARJScopeFactory scopeFactoryWithBlock:(^(ARJScope* scope, NSDictionary *params)block) forModel:self]}

#define arj_attributes(block, ...) static NSMutableDictionary *__arj__attributes__cache;\
+(NSDictionary*)attributes{\
    if(!__arj__attributes__cache){\
        __arj__attributes__cache = [NSMutableDictionary dictionaryWithDictionary:[super attributes]];\
        for(NSDictionary *dict in @[block,  __VA_ARGS__]){\
            __arj__attributes__cache[dict[ARJAttributeNameSpecifier]] = [ARJModelAttribute modelAttributeWithDictionary:dict];\
        }\
    }\
    return __arj__attributes__cache;\
}

#define arj_relations(block, ...) static NSMutableDictionary* __arj__relations__cache;\
+(NSDictionary*)relations{\
    if(!__arj__relations__cache){\
        __arj__relations__cache = [NSMutableDictionary dictionary];\
        for(NSDictionary *dict in @[block,  __VA_ARGS__]){\
            __arj__relations__cache[dict[ARJRelationNameSpecifier]] = [ARJRelation relationWithDictionary:dict forModel:self];\
        }\
    }\
    return __arj__relations__cache;\
}\
arj_attributes_with_relational_keys

#define arj_validations(block, ...) static NSMutableDictionary* __arj__validations__cache;\
+(NSDictionary*)validations{\
    if(!__arj__validations__cache){\
        __arj__validations__cache = [NSMutableDictionary dictionary];\
        for(NSDictionary *dict in @[block,  __VA_ARGS__]){\
            NSLog(@"%@", dict[ARJValidationTargetSpecifier]);\
            if(!__arj__validations__cache[dict[ARJValidationTargetSpecifier]]){\
                __arj__validations__cache[dict[ARJValidationTargetSpecifier]]=[NSMutableArray array];\
            }\
            ARJModelValidator *validator = [ARJModelValidator modelValidatorWithDictionary:dict];\
            [__arj__validations__cache[dict[ARJValidationTargetSpecifier]] addObject:validator];\
        }\
    }\
    return __arj__validations__cache;\
}
            
#define arj_scopes(block, ...) static NSMutableDictionary* __arj__scopes__cache;\
+(NSDictionary*)scopes{\
    if(!__arj__scopes__cache){\
        __arj__scopes__cache = [NSMutableDictionary dictionary];\
        for(NSDictionary *dict in @[block, __VA_ARGS__]){\
            __arj__scopes__cache[dict[ARJScopeNameSpecifier]]=dict[ARJScopeFactorySpecifier];\
        }\
    }\
    return __arj__scopes__cache;\
}\

#define arj_before_create(function) @{ARJCallbackTimingSpecifier: ARJCallbackTimingBeforeCreate, ARJCallbackFunctionSpecifier: @#function}

#define arj_after_create(function) @{ARJCallbackTimingSpecifier: ARJCallbackTimingAfterCreate, ARJCallbackFunctionSpecifier: @#function}

#define arj_before_validation(function) @{ARJCallbackTimingSpecifier: ARJCallbackTimingBeforeValidation, ARJCallbackFunctionSpecifier: @#function}

#define arj_after_validation(function) @{ARJCallbackTimingSpecifier: ARJCallbackTimingAfterValidation, ARJCallbackFunctionSpecifier: @#function}

#define arj_before_save(function) @{ARJCallbackTimingSpecifier: ARJCallbackTimingBeforeSave, ARJCallbackFunctionSpecifier: @#function}

#define arj_after_save(function) @{ARJCallbackTimingSpecifier: ARJCallbackTimingAfterSave, ARJCallbackFunctionSpecifier: @#function}

#define arj_before_destroy(function) @{ARJCallbackTimingSpecifier: ARJCallbackTimingBeforeDestroy, ARJCallbackFunctionSpecifier: @#function}

#define arj_after_destroy(function) @{ARJCallbackTimingSpecifier: ARJCallbackTimingAfterDestroy, ARJCallbackFunctionSpecifier: @#function}

#define arj_after_comit(function) @{ARJCallbackTimingSpecifier: ARJCallbackTimingAfterCommit, ARJCallbackFunctionSpecifier: @#function}

#define arj_after_initialize(function) @{ARJCallbackTimingSpecifier: ARJCallbackTimingAfterInitialize, ARJCallbackFunctionSpecifier: @#function}

#define arj_callbacks(block, ...) static NSMutableDictionary* __arj__callbacks__cache;\
+(NSDictionary*)callbacks{\
    NSLog(@"callbacks called on %@", self);\
    if(!__arj__callbacks__cache){\
        __arj__callbacks__cache = [NSMutableDictionary dictionaryWithDictionary:[super callbacks]];\
        for(NSDictionary *dict in @[block,  __VA_ARGS__]){\
            if(!__arj__callbacks__cache[dict[ARJCallbackTimingSpecifier]]){\
                __arj__callbacks__cache[dict[ARJCallbackTimingSpecifier]] = [NSMutableArray array];\
            }\
            [__arj__callbacks__cache[dict[ARJCallbackTimingSpecifier]] addObject:dict[ARJCallbackFunctionSpecifier]];\
        }\
    }\
    return __arj__callbacks__cache;\
}

#define arj_property(name) @property (nonatomic, strong) id name
#define arj_properties(name, ...) @property (nonatomic, strong) id name, __VA_ARGS__
#define arj_typed_property(type, name) @property (nonatomic, strong) type name;
#define arj_dynamic_property_imp(name) @dynamic name
#define arj_dynamic_properties_imp(name, ...) @dynamic name, __VA_ARGS__
#define arj_number_property(numberType, name) @property (nonatomic, strong) NSNumber* name;\
@property (nonatomic, assign) numberType name##_primitive

@class ARJActiveRecord;
@interface ARJActiveRecordHelper : NSObject
-(BOOL)hasValuePlaceholderInString:(NSString*)string;
-(BOOL)hasTableSpecificationInString:(NSString*)string;
+(ARJActiveRecordHelper*)defaultHelper;
-(BOOL)hasSameRecord:(ARJActiveRecord*)record inEnumerable:(id)enumerable;
@end

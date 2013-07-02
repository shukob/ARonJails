//
//  ARJActiveRecordHelper.h
//  ActiveRecordOnJails
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


#define arj_model(name) +(NSString*)model{return @#name;}

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

#define arj_attributes(block, ...) static NSMutableDictionary *__arj__attributes__cache;\
+(NSDictionary*)attributes{\
    if(!__arj__attributes__cache){\
        __arj__attributes__cache = [NSMutableDictionary dictionary];\
        for(NSDictionary *dict in @[block,  __VA_ARGS__]){\
            __arj__attributes__cache[dict[ARJAttributeNameSpecifier]] = [ARJModelAttribute modelAttributeWithDictionary:dict];\
        }\
        __arj__attributes__cache[@"id"]=[ARJModelAttribute modelAttributeWithDictionary:@{ARJAttributeTypeSpecifier : ARJIntegerAttributeSpecifier, ARJAttributeNameSpecifier : @"id"}];\
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
}

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
            


@interface ARJActiveRecordHelper : NSObject
-(BOOL)hasValuePlaceholderInString:(NSString*)string;
-(BOOL)hasTableSpecificationInString:(NSString*)string;
+(ARJActiveRecordHelper*)defaultHelper;
@end

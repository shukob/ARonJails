//
//  ARJActiveRecord.m
//  ActiveRecordOnJails
//
//  Created by skonb on 2013/06/03.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ARJActiveRecord.h"
#import "ARJExpectationHelper.h"
#import "ARJDatabaseManager.h"
#import "ARJScope.h"
#import "NSString+ActiveSupportInflector.h"
#import "ARJModelValidator.h"
#import "ARJPropertyObserver.h"

@interface ARJActiveRecord()
@property (nonatomic, strong) NSMutableDictionary *relationCache;
@property (nonatomic, assign) BOOL validated;
@property (nonatomic, assign) BOOL saving;
@property (nonatomic, assign) BOOL savingAssociated;
@end

@implementation ARJActiveRecord

-(id)init{
    if ([super init]) {
        self._updateDictionary = [NSMutableDictionary dictionary];
        self.relationCache = [NSMutableDictionary dictionary];
        [[ARJPropertyObserver defaultObserver]registerForPropertyObservation:self];
        self.errors = [ARJValidationErrors new];
        self.correspondingDatabaseManager = [ARJDatabaseManager defaultManager];
    }
    return self;
}

+(NSString*)tableName{
    NSString* res=[[ARJExpectationHelper defaultHelper]nonCamelizedFromCamelized:[[self model]pluralizeString]];
    return res;
}

+(NSDictionary*)schema{
    return @{ARJAttributesSpecifier : [self attributes], ARJRelationsSpecifier : [self relations]};
}
+(NSString*)model{
    return @"";
}
+(NSDictionary*)attributes{
    ARJModelAttribute *idAttribute = [ARJModelAttribute modelAttributeWithDictionary:@{ARJAttributeTypeSpecifier : ARJIntegerAttributeSpecifier, ARJAttributeNameSpecifier : @"id"}];
    return @{@"id" : idAttribute};
}
+(NSDictionary*)relations{
    return @{};
}
+(NSDictionary*)validations{
    return @{};
}
+(NSArray*)scopes{
    return @[];
}

+(id)find:(NSDictionary*)condition{
    return [self find:condition inDatabaseManager:[ARJDatabaseManager defaultManager]];
}

+(id)findFirst:(NSDictionary*)condition{
    return [self findFirst:condition inDatabaseManager:[ARJDatabaseManager defaultManager]];
}

+(NSArray*)findAll{
    return [self findAllInDatabaseManager:[ARJDatabaseManager defaultManager]];
}

-(BOOL)destroy{
    return [self destroyInDatabaseManager:self.correspondingDatabaseManager];
}

-(BOOL)save{
    return [self saveInDatabaseManager:self.correspondingDatabaseManager];
}

-(id)update:(NSDictionary*)attributes{
    return [self update:attributes inDatabaseManager:self.correspondingDatabaseManager];
}

+(id)create:(NSDictionary*)attributes{
    return [self create:attributes inDatabaseManager:[ARJDatabaseManager defaultManager]];
}

+(id)find:(NSDictionary*)condition inDatabaseManager:(ARJDatabaseManager*)manager{
    if (!manager) {
        manager = [ARJDatabaseManager defaultManager];
    }
    return [manager findModel:self condition:condition];
}

+(id)findFirst:(NSDictionary*)condition inDatabaseManager:(ARJDatabaseManager*)manager{
    if (!manager) {
        manager = [ARJDatabaseManager defaultManager];
    }
     return [manager findFirstModel:self condition:condition];
}
+(NSArray*)findAllInDatabaseManager:(ARJDatabaseManager*)manager{
    if (!manager) {
        manager = [ARJDatabaseManager defaultManager];
    }
    return [manager allModels:self];
}

+(void)destroyAllInDatabaseManager:(ARJDatabaseManager*)manager{
    if (!manager) {
        manager = [ARJDatabaseManager defaultManager];
    }
    [manager destroyAllModels:self];
}

-(BOOL)destroyInDatabaseManager:(ARJDatabaseManager*)manager{
    if (!manager){
        manager = [ARJDatabaseManager defaultManager];
    }
    return [manager destroyInstance:self];
}

-(BOOL)saveInDatabaseManager:(ARJDatabaseManager*)manager{
    self.saving = YES;
    BOOL res = NO;
    if (self.Id) {
        if ([self validateOnTiming:ARJModelValidatorValidationTimingOnUpdate]) {
            [self willSave];
            res = [self.correspondingDatabaseManager saveInstance:self];
        }else{
            res = NO;
        }
    }else{
        if ([self validateOnTiming:ARJModelValidatorValidationTimingOnCreate]) {
            [self willCreate];
            ARJActiveRecord* instance = [[self class]create:self._updateDictionary inDatabaseManager:manager];
            if (instance) {
                self.Id = instance.Id;
                res = [self saveAssociated];
            }else{
                res =  NO;
            }
            
        }else{
            res =  NO;
        }
    }
    self.saving = NO;
    return res;
}
-(id)update:(NSDictionary*)attributes inDatabaseManager:(ARJDatabaseManager*)manager{
    for (NSString *key in attributes.allKeys){
        [self setAttribute:attributes[key] forKey:key];
    }
    if ([self validateOnTiming:ARJModelValidatorValidationTimingOnUpdate]) {
        if (!manager) {
            manager = [ARJDatabaseManager defaultManager];
        }
        return [manager updateInstance:self attributes:attributes];
    }else{
        return self;
    }
}

+(id)create:(NSDictionary*)attributes inDatabaseManager:(ARJDatabaseManager*)manager{
    ARJActiveRecord * tempInstance = [self new];
    [tempInstance._updateDictionary addEntriesFromDictionary:attributes];
    if ([tempInstance validateOnTiming:ARJModelValidatorValidationTimingOnCreate]) {
        if (!manager) {
            manager = [ARJDatabaseManager defaultManager];
        }
        return [manager createModel:self attributes:attributes];
    }else{
        return tempInstance;
    }
}

+(ARJScope*)scoped{
    return [[ARJScope SELECT]FROM:[self tableName]];
}

+(ARJScope*)insertScope{
    return [[ARJScope INSERT]INTO:[self tableName]];
}

-(ARJScope*)updateScope{
    return [[ARJScope UPDATE:[[self class]tableName]]WHERE:[self idWhereDictionary], nil];
}

-(ARJScope*)destroyScope{
    return [[[ARJScope DELETE]FROM:[[self class]tableName]] WHERE:[self idWhereDictionary], nil];
}

-(NSDictionary*)idWhereDictionary{
    return @{[NSString stringWithFormat:@"%@.id=?", [[self class] tableName]]: [self attributeForKey:@"id"]};
}

-(id)attributeForKey:(NSString *)key{
    
    return [[[self class]attributes][key]valueForInstance:self];
}

-(void)setAttribute:(id)attribute forKey:(NSString *)key{
    if ([[self class]attributes][key]) {
        [[[self class]attributes][key]setValue:attribute forInstance:self];
    }else{
        self._updateDictionary[key]=attribute;
    }
}

+(ARJActiveRecord*)instanceWithDictionary:(NSDictionary*)dictionary{
    ARJActiveRecord *res = [self new];
    res._columnDictionary = dictionary;
    //    [res inflateProperty];
    return res;
}


+(void)destroyAll{
    [self destroyAllInDatabaseManager:[ARJDatabaseManager defaultManager]];
}

-(id)associatedForKey:(NSString *)key{
    if (!self.relationCache) {
        self.relationCache = [NSMutableDictionary dictionary];
    }
    id res = self.relationCache[key];
    if(!res){
        ARJRelation *relation = [[self class]relationForKey:key];
        res = [relation destinationForSource:self];
    }
    return res;
}


-(void)clearRelationCache{
    [self.relationCache removeAllObjects];
}

-(NSInteger)Id{
    return [[self attributeForKey:@"id"]integerValue];
}



-(void)setAssociated:(id)associated forKey:(NSString*)key{
    ARJRelation *relation  = [[self class]relationForKey:key];
    if(relation){
        self.relationCache[key]=associated;
    }
}

-(void)insertAssociated:(id)associated forKey:(NSString *)key{
    
}


-(BOOL)willDestroy{
    NSDictionary * relations = [[self class]relations];
    if(relations.count){
        return [[ARJDatabaseManager defaultManager]runInTransaction:^BOOL{
            BOOL res = YES;
            for (ARJRelation *relation in [relations allValues]){
                res = [relation willDestroySourceInstance:self inDatabaseManager:self.correspondingDatabaseManager];
                if (!res) {
                    break;
                }
            }
            return res;
        }];
    }else{
        return YES;
    }
    
}

-(BOOL)didDestroy{
    return YES;
}
-(BOOL)willSave{
    BOOL valid = [self valid];
    return valid;
}
-(BOOL)didSave{
    return YES;
}
-(BOOL)willCreate{
    return YES;
}
-(BOOL)didCreate{
    return YES;
}

-(BOOL)willValidate{
    return YES;
}

-(BOOL)didValidate{
    return YES;
}

+(ARJRelation*)relationForKey:(NSString*)key{
    return [self relations][key];
}

-(BOOL)validateOnTiming:(ARJModelValidatorValidationTiming)timing{
    if (!self.validated) {
        [self.errors clearErrors];
        for(NSString *validatorKey in [[[self class]validations]allKeys]){
            for (ARJModelValidator *validator in [[self class ]validations][validatorKey]){
                if (![validator requiresValidationOnTiming:timing]) {
                    continue;
                }
                [validator validateInstance:self inDatabaseManager:self.correspondingDatabaseManager];
            }
        }
        self.validated = YES;
    }
    return self.errors.count == 0;
}

-(BOOL)validate{
    return [self validateInDatabaseManager:self.correspondingDatabaseManager];
}

-(BOOL)validateInDatabaseManager:(ARJDatabaseManager *)manager{
    if (!self.validated) {
        [self.errors clearErrors];
        for(NSString *validatorKey in [[[self class]validations]allKeys]){
            for (ARJModelValidator *validator in [[self class ]validations][validatorKey]){
                [validator validateInstance:self inDatabaseManager:manager];
            }
        }
        self.validated = YES;
    }
    return self.errors.count == 0;
}

-(BOOL)valid{
    return [self validate];
}

-(id)latestValueForKey:(NSString *)key{
    if (self._updateDictionary[key]) {
        return self._updateDictionary[key];
    }else{
        return self._columnDictionary[key];
    }
}

-(BOOL)saveAssociated{
    if(self.savingAssociated){
        return YES;
    }
    self.savingAssociated = YES;
    BOOL res = YES;
    for (NSString * relationKey in [[self class]relations].allKeys){
        ARJRelation *relation = [[self class]relations][relationKey];
        if (relation.autosave) {
            if (self.relationCache[relationKey] && ![self.relationCache[relationKey]saving]) {
                if(![relation setDestinationInstance:self.relationCache[relationKey] toSourceInstance:self inDatabaseManager:self.correspondingDatabaseManager]){
                    res = NO;
                    break;
                }
            }
        }
    }
    self.savingAssociated = NO;
    return res;
}

-(void)reload{
    if ([self Id]) {
        ARJActiveRecord * temp = [[self class]findFirst:@{@"id" : @([self Id])}];
        if (temp) {
            self._columnDictionary = temp._columnDictionary;
            [self._updateDictionary removeAllObjects];;
        }
    }
}

-(void)setId:(NSInteger)Id{
    [self setAttribute:@(Id) forKey:@"id"];
}
//
//-(void)inflateProperty{
//    for (NSString *key in self._columnDictionary){
//        NSString * camelized =[[ARJExpectationHelper defaultHelper]camelizedFromNonCamelized:key];
//        NSString *camelized2 = [camelized stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[camelized substringWithRange:NSMakeRange(0, 1)]uppercaseString]];
//        if ([self respondsToSelector:NSSelectorFromString([NSString stringWithFormat:@"set%@:", camelized2])]) {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//            if (self respondsToSelector:NSSelectorFromString(<#NSString *aSelectorName#>)) {
//                <#statements#>
//            }
//            [self performSelector:NSSelectorFromString([NSString stringWithFormat:@"set%@:", camelized]) withObject:self._columnDictionary[key]];
//#pragma clang diagnostic pop
//        }
//    }
//}

-(id)initWithDictionary:(NSDictionary *)dictionary{
    if ([self init]) {
        for (NSString * key in dictionary){
            [self setAttribute:dictionary[key] forKey:key];
        }
    }
    return self;
}

@end

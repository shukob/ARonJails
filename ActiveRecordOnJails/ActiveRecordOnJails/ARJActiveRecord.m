//
//  ARJActiveRecord.m
//  ActiveRecord on Jails
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
#import "ARJSQLInvocation.h"
#import <objc/runtime.h>
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
        [self invokeCallbackOnTiming:ARJActiveRecordCallbackTimingAfterInitialize];
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
    ARJModelAttribute *updatedAtAttribute =[ARJModelAttribute modelAttributeWithDictionary:@{ARJAttributeTypeSpecifier : ARJDateTimeAttributeSpecifier, ARJAttributeNameSpecifier : @"updated_at"}];
    ARJModelAttribute *createdAtAttribute =[ARJModelAttribute modelAttributeWithDictionary:@{ARJAttributeTypeSpecifier : ARJDateTimeAttributeSpecifier, ARJAttributeNameSpecifier : @"created_at"}];
    
    return @{@"id" : idAttribute, @"updated_at": updatedAtAttribute, @"created_at" : createdAtAttribute};
}
+(NSDictionary*)relations{
    return @{};
}


+(NSDictionary*)attributesWithRelationalKeys{
    NSDictionary *attributes = [self attributes];
    NSDictionary *relations = [self relations];
    NSMutableDictionary *targetAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    for (ARJRelation *relation in relations.allValues){
        NSDictionary *thisAttributes = [relation attributes];
        if (thisAttributes) {
            [targetAttributes addEntriesFromDictionary:thisAttributes];
        }
    }
    return targetAttributes;
}

+(NSDictionary*)callbacks{
    return @{ARJCallbackTimingBeforeValidation : [NSMutableArray arrayWithObject:@"setUpDefaults:"]};//This must be mutable, because other before validation callbacks may be appended to it in subclass.
}

+(NSDictionary*)validations{
    return @{};
}
+(NSDictionary*)scopes{
    return @{};
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
    if(![self willDestroy]){
        return NO;
    }
    BOOL res = [manager destroyInstance:self];
    if (res) {
        if (![self didDestroy]) {
            return NO;
        }
    }
    return res;
}

-(BOOL)requiresSaving{
    //If we already have column dictionary, that means that it is already saved in database,
    //still not is updated nor relation is set, then it does not require saving any information.
    return !self._columnDictionary || self._updateDictionary.count || self.relationCache.count;
}

-(BOOL)saveInDatabaseManager:(ARJDatabaseManager*)manager{
    if (! [self requiresSaving]) {
        return YES;
    }
    self.saving = YES;
    BOOL res = NO;
    if (self.Id) {
        if(![self willValidate]){
            return NO;
        }
        if ([self validateOnTiming:ARJModelValidatorValidationTimingOnUpdate]) {
            if (![self didValidate]) {
                return NO;
            }
            if(![self willSave]){
                return NO;
            };
            res = [self.correspondingDatabaseManager saveInstance:self];
            if (![self didSave]) {
                return NO;
            }
        }else{
            res = NO;
        }
    }else{
        if (![self willValidate]) {
            return NO;
        }
        if ([self validateOnTiming:ARJModelValidatorValidationTimingOnCreate]) {
            if (![self didValidate]) {
                return NO;
            }
            if (![self willSave]) {
                return NO;
            }
            if(![self willCreate]){
                return NO;
            }
            ARJActiveRecord* instance = [[self class]create:self._updateDictionary inDatabaseManager:manager];
            self._columnDictionary = instance._columnDictionary;
            if (![self didCreate]) {
                return NO;
            }
            if (![self didSave]) {
                return NO;
            }
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
    if (![self willValidate]) {
        return self;
    }
    if ([self validateOnTiming:ARJModelValidatorValidationTimingOnUpdate]) {
        if (![self didValidate]) {
            return self;
        }
        if(![self willSave]){
            return self;
        };
        if (!manager) {
            manager = [ARJDatabaseManager defaultManager];
        }
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:attributes];
        [dict setObject:[self attributeForKey:@"updated_at"] forKey:@"updated_at"];
        id res = [manager updateInstance:self attributes:dict];
        if (![res didSave]) {
            return res;
        }
        return res;
    }else{
        return self;
    }
}

+(id)create:(NSDictionary*)attributes inDatabaseManager:(ARJDatabaseManager*)manager{
    ARJActiveRecord * tempInstance = [self new];
    [tempInstance._updateDictionary addEntriesFromDictionary:attributes];
    if(![tempInstance willValidate]){
        return tempInstance;
    }
    if ([tempInstance validateOnTiming:ARJModelValidatorValidationTimingOnCreate]) {
        if(![tempInstance didValidate]){
            return tempInstance;
        }
        if(![tempInstance willSave]){
            return tempInstance;
        }
        if(![tempInstance willCreate]){
            return tempInstance;
        }
        if (!manager) {
            manager = [ARJDatabaseManager defaultManager];
        }
        id res = [manager createModel:self attributes:tempInstance._updateDictionary];
        if(![res didCreate]){
            return res;
        }
        if(![res didSave]){
            return res;
        }
        return res;
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
    id res = [[[self class]attributesWithRelationalKeys][key]valueForInstance:self];
    if (arj_nil(res)) {
        res = nil;
    }
    return res;
}

-(void)setAttribute:(id)attribute forKey:(NSString *)key{
    if ([[self attributeForKey:key]isEqual:attribute]) {
        return;
    }else{
        self.validated = NO;
        if ([[self class]attributesWithRelationalKeys][key]) {
            [[[self class]attributesWithRelationalKeys][key]setValue:attribute forInstance:self];
        }else{
            self._updateDictionary[key]=attribute;
        }
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
    BOOL callbackResult = [self invokeCallbackOnTiming:ARJActiveRecordCallbackTimingBeforeDestroy];
    if (!callbackResult) {
        return NO;
    }else{
        NSDictionary * relations = [[self class]relations];
        if(relations.count){
            return [[ARJDatabaseManager defaultManager]runInTransaction:^BOOL(id database){
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
    
}

-(BOOL)didDestroy{
    return [self invokeCallbackOnTiming:ARJActiveRecordCallbackTimingAfterDestroy];
}
-(BOOL)willSave{
    NSDate *currentDate = [NSDate date];
    if ([self Id]==0) {
        [self setAttribute:currentDate forKey:@"created_at"];
    }
    [self setAttribute:currentDate forKey:@"updated_at"];
    
    return [self invokeCallbackOnTiming:ARJActiveRecordCallbackTimingBeforeSave];
}
-(BOOL)didSave{
    return [self invokeCallbackOnTiming:ARJActiveRecordCallbackTimingAfterSave];
}
-(BOOL)willCreate{
    return [self invokeCallbackOnTiming:ARJActiveRecordCallbackTimingBeforeCreate];
}
-(BOOL)didCreate{
    return [self invokeCallbackOnTiming:ARJActiveRecordCallbackTimingAfterCreate];;
}

-(BOOL)invokeCallbackOnTiming:(ARJActiveRecordCallbackTiming)timing{
    NSString * key = nil;
    switch (timing) {
        case ARJActiveRecordCallbackTimingBeforeCreate:
            key = ARJCallbackTimingBeforeCreate;
            break;
        case ARJActiveRecordCallbackTimingAfterCreate:
            key = ARJCallbackTimingAfterCreate;
            break;
        case ARJActiveRecordCallbackTimingBeforeSave:
            key = ARJCallbackTimingBeforeSave;
            break;
        case ARJActiveRecordCallbackTimingBeforeValidation:
            key = ARJCallbackTimingBeforeValidation;
            break;
        case ARJActiveRecordCallbackTimingAfterCommit:
            key = ARJCallbackTimingAfterCommit;
            break;
        case ARJActiveRecordCallbackTimingBeforeDestroy:
            key = ARJCallbackTimingBeforeDestroy;
            break;
        case ARJActiveRecordCallbackTimingAfterDestroy:
            key = ARJCallbackTimingAfterDestroy;
            break;
        case ARJActiveRecordCallbackTimingAfterSave:
            key = ARJCallbackTimingAfterSave;
            break;
        case ARJActiveRecordCallbackTimingAfterValidation:
            key = ARJCallbackTimingAfterValidation;
            break;
        case ARJActiveRecordCallbackTimingAfterInitialize:
            key = ARJCallbackTimingAfterInitialize;
        default:
            break;
            
    }
    NSDictionary *allCallbacks = [[self class] callbacks];
    NSArray * callbacks = allCallbacks[key];
    BOOL res = YES;
    for (NSString *selectorString in callbacks){
        SEL selector = NSSelectorFromString(selectorString);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id callbackResultValue = [self performSelector:selector withObject:self];
#pragma clang diagnostic pop
        BOOL thisResult = [callbackResultValue boolValue];
        res = thisResult;
        if (!thisResult) {
            break;
        }
    }
    return res;
}

-(BOOL)willValidate{
    return  [self invokeCallbackOnTiming:ARJActiveRecordCallbackTimingBeforeValidation];
}

-(BOOL)didValidate{
    return  [self invokeCallbackOnTiming:ARJActiveRecordCallbackTimingAfterValidation];;
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
            [self.relationCache removeAllObjects];
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

+(id)findOrCreate:(NSDictionary *)conditions{
    return [self findOrCreate:conditions inDatabaseManager:[ARJDatabaseManager defaultManager]];
}

+(id)findOrCreate:(NSDictionary *)conditions inDatabaseManager:(ARJDatabaseManager *)manager{
    id res = [self findFirst:conditions inDatabaseManager:manager];
    if (!res) {
        res = [self create:conditions inDatabaseManager:manager];
    }
    return res;
}


+(id)executeScopeForKey:(NSString *)name withParams:(NSDictionary *)params{
    return [self executeScopeForKey:name withParams:params inDatabaseManager:[ARJDatabaseManager defaultManager]];
}

+(id)executeScopeForKey:(NSString *)name withParams:(NSDictionary *)params inDatabaseManager:(ARJDatabaseManager*)manager{
    ARJScopeFactory *factory = [self scopes][name];
    ARJScope * scope = [factory produce:params];
    return [manager findModel:self invocation:scope.SQLInvocation];
}


-(id)setUpDefaults:(id)sender{
    if(!self.Id){
        NSDictionary *attributes = [[self class]attributes];
        for (NSString *key in attributes.allKeys){
            if ([attributes[key]defaultValue]) {
                if (arj_nil([self attributeForKey:key])) {
                    [self setAttribute:[attributes[key]defaultValue] forKey:key];
                }
            }
        }
    }
    return @YES;
}

-(void)dealloc{
    [[ARJPropertyObserver defaultObserver]unRegister:self];
    
}

#ifdef ARJ_USE_DYNAMIC_METHOD_IMP

static Class referenceKlassFromKVOClass(Class klass){
    return klass;
        //This is treated gracefully by KVO and not is necessary.
//    static NSString * kvoClassPrefix = @"NSKVONotifying_";
//    NSString *classString = NSStringFromClass(klass);
//    if ([classString hasPrefix:kvoClassPrefix]){
//        classString = [classString substringFromIndex:kvoClassPrefix.length];
//        return NSClassFromString(classString);
//    }else{
//        return klass;
//    }
}

static id arj_getter_IMP(id self, SEL _cmd){
    Class referenceClass = referenceKlassFromKVOClass([self class]);
    NSString *key = NSStringFromSelector(_cmd);
    if ([referenceClass attributesWithRelationalKeys][key]) {
        return [self attributeForKey:key];
    }else if([referenceClass relations][key]){
        return [self associatedForKey:key];
    }else{
        return nil;
    }
}

static void arj_setter_IMP(id self, SEL _cmd, id value){
    Class referenceClass = referenceKlassFromKVOClass([self class]);
    id val = value;
    NSMutableString *key = [NSStringFromSelector(_cmd) mutableCopy];
    [key deleteCharactersInRange:NSMakeRange(0, 3)];
    [key deleteCharactersInRange:NSMakeRange([key length] - 1, 1)];
    NSString *firstChar = [key substringToIndex:1];
    [key replaceCharactersInRange:NSMakeRange(0, 1) withString:[firstChar lowercaseString]];
    if ([referenceClass attributesWithRelationalKeys][key]) {
        [self setAttribute:val forKey:key];
    }else if([referenceClass relations][key]){
        [self setAssociated:val forKey:key];
    }
}


+ (BOOL)resolveInstanceMethod:(SEL)aSEL {
    Class referenceClass = referenceKlassFromKVOClass([self class]);
    if ([NSStringFromSelector(aSEL) hasPrefix:@"set"]) {
        NSMutableString *key = [NSStringFromSelector(aSEL) mutableCopy];
        [key deleteCharactersInRange:NSMakeRange(0, 3)];
        [key deleteCharactersInRange:NSMakeRange([key length] - 1, 1)];
        NSString *firstChar = [key substringToIndex:1];
        [key replaceCharactersInRange:NSMakeRange(0, 1) withString:[firstChar lowercaseString]];
        if ([referenceClass attributesWithRelationalKeys][key]) {
            class_addMethod([self class], aSEL, (IMP)arj_setter_IMP, "v@:@");
            return YES;
        }else if([referenceClass relations][key]){
            class_addMethod([self class], aSEL, (IMP)arj_setter_IMP, "v@:@");
            return YES;
        }else{
            return NO;
        }

    } else {
        NSString *key = NSStringFromSelector(aSEL);
        if ([referenceClass attributesWithRelationalKeys][key]) {
            class_addMethod([self class], aSEL,(IMP)arj_getter_IMP, "@@:");
            return YES;
        }else if([referenceClass relations][key]){
            class_addMethod([self class], aSEL,(IMP)arj_getter_IMP, "@@:");
            return YES;
        }else{
            return NO;
        }
    }

}
#endif /*ARJ_DYNAMIC_METHOD_IMP*/
@end

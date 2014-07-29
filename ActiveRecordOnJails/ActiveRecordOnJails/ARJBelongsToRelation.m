//
//  ARJBelongsToRelation.m
//  ActiveRecord on Jails
//
//  Created by skonb on 2013/06/21.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ARJBelongsToRelation.h"
#import "ARJExpectationHelper.h"
#import "ARJActiveRecordHelper.h"
#import "ARJModelAttribute.h"
#import "ARJActiveRecord.h"
@implementation ARJBelongsToRelation
-(BOOL)willDestroySourceInstance:(ARJActiveRecord*)instance{
    id destination = [instance associatedForKey:self.relationName];
    BOOL res = YES;
    if (self.dependency == ARJRelationDependencyDestroy) {
        if ([destination isKindOfClass:[NSArray class]]) {
            for (ARJActiveRecord *record in destination){
                if(![record destroy]){
                    res = NO;
                    break;
                }
            }
        }else{
            if (![destination destroy]){
                res = NO;
            }
        }
    }else if(self.dependency == ARJRelationDependencyNullify){
        ARJRelation *inverse = [self inverseRelation];
        if ([destination isKindOfClass:[NSArray class]]) {
            for (ARJActiveRecord *record in destination){
                [record update:@{inverse.associationKey: [NSNull null]}];
                if (record.errors.count) {
                    res = NO;
                    break;
                }
            }
        }else{
            [destination update:@{inverse.associationKey: [NSNull null]}];
            if ([[destination errors]count]) {
                res = NO;
            }
        }
    }
    return res;
}

-(BOOL)willDestroySourceInstance:(ARJActiveRecord *)instance inDatabaseManager:(ARJDatabaseManager *)manager{
    return [self willDestroySourceInstance:instance];
}

-(NSDictionary*)attributes{
//    NSString *key = [[ARJExpectationHelper defaultHelper]nonCamelizedFromCamelized:[self.relationName stringByAppendingString:@"Id"]];
//    NSString *key = [self.relationName stringByAppendingString:@"Id"];
    NSString *key = [self associationKey];
    NSDictionary *dict = @{ARJAttributeNameSpecifier: key, ARJAttributeTypeSpecifier: ARJIntegerAttributeSpecifier};
    return @{key: [ARJModelAttribute modelAttributeWithDictionary:dict]};
}

-(BOOL)setDestinationInstance:(id)destination toSourceInstance:(id)source{
    return [self setDestinationInstance:destination toSourceInstance:source inDatabaseManager:[[self class]expectedDatabaseManagerForSource:source andDestination:destination]];
}

-(BOOL)setDestinationInstance:(id)destination toSourceInstance:(id)source inDatabaseManager:(ARJDatabaseManager *)manager{
    return [self.inverseRelation setDestinationInstance:source toSourceInstance:destination inDatabaseManager:manager]; // Visitor: source and destination is vice versa
    
}


-(id)destinationForSource:(ARJActiveRecord *)source{
    return [self destinationForSource:source inDatabaseManager:source.correspondingDatabaseManager];
}

-(id)destinationForSource:(ARJActiveRecord *)source inDatabaseManager:(ARJDatabaseManager *)manager{
    id _id = [source attributeForKey:self.associationKey];
    if (!_id) {
        return nil;
    }else{
        if (self.dictionary[ARJPrimaryKeySpecifier]) {
            return [[self destinationModel] findFirst:@{self.dictionary[ARJPrimaryKeySpecifier] : _id} inDatabaseManager:manager];
        }else{
            return [[self destinationModel] findFirst:@{@"id" : _id} inDatabaseManager:manager];
        }
    }
}


@end

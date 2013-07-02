//
//  ARJBelongsToRelation.m
//  ActiveRecordOnJails
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
    ARJActiveRecord* destination = [instance associatedForKey:self.foreignKey];
    if (self.dependency == ARJRelationDependencyDestroy) {
        [destination destroy];
    }else if(self.dependency == ARJRelationDependencyNullify){
        ARJRelation *inverse = [self inverseRelation];
        [destination update:@{inverse.associationKey: [NSNull null]}];
    }
    return YES;
}

-(BOOL)willDestroySourceInstance:(ARJActiveRecord *)instance inDatabaseManager:(ARJDatabaseManager *)manager{
    return [self willDestroySourceInstance:instance];
}

-(NSDictionary*)attributes{
    NSString *key = [[ARJExpectationHelper defaultHelper]nonCamelizedFromCamelized:[self.relationName stringByAppendingString:@"Id"]];
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
    return [[self destinationModel] findFirst:@{@"id" : [source attributeForKey:self.associationKey]} inDatabaseManager:manager];
}


@end

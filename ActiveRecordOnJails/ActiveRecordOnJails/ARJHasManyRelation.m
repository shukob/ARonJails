//
//  ARJHasManyRelation.m
//  ActiveRecord on Jails
//
//  Created by skonb on 2013/06/21.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ARJHasManyRelation.h"
#import "ARJActiveRecord.h"
#import "ARJDatabaseManager.h"
@implementation ARJHasManyRelation
-(BOOL)willDestroySourceInstance:(ARJActiveRecord*)instance{
    return [self willDestroySourceInstance:instance inDatabaseManager:instance.correspondingDatabaseManager];
}

-(BOOL)willDestroySourceInstance:(ARJActiveRecord *)instance inDatabaseManager:(ARJDatabaseManager *)manager{
    [instance reload];
    return [manager runInTransaction:^BOOL(id database){
        for (ARJActiveRecord * record in [instance associatedForKey:self.relationName]){
            if (self.dependency == ARJRelationDependencyNullify) {
                if(![record update:@{self.foreignKey: [NSNull null]}]){
                    return NO;
                };
            }else if(self.dependency == ARJRelationDependencyDestroy){
                if(![record destroy]){
                    return NO;
                }
            }
        }
        return YES;
    }];
}

-(NSDictionary*)attributes{
    return @{};
}

+(ARJDatabaseManager*)expectedDatabaseManagerForSource:(ARJActiveRecord*)source andDestination:(id)destination{
    
    ARJDatabaseManager *manager = nil;
    if (destination && [destination count]) {
        manager = [[destination objectAtIndex:0] correspondingDatabaseManager];
    }
    if (!manager) {
        manager = [source correspondingDatabaseManager];
    }
    if (!manager) {
        manager =  [ARJDatabaseManager defaultManager];
    }
    return manager;
}

-(BOOL)setDestinationInstance:(id)destination toSourceInstance:(id)source{
    return [self setDestinationInstance:destination toSourceInstance:source inDatabaseManager:[[self class]expectedDatabaseManagerForSource:source andDestination:destination]];
}

-(BOOL)setDestinationInstance:(id)destination toSourceInstance:(id)source inDatabaseManager:(ARJDatabaseManager *)manager{
    return [manager runInTransaction:^BOOL(id database){
        if (![source Id]) {
            if(![source saveInDatabaseManager:manager]){
                return NO;
            }
        }
        NSArray* currentDestinations = [source associatedForKey:self.relationName];
        
        if (currentDestinations) {
            for (ARJActiveRecord * currentDestination in currentDestinations){
                if ([currentDestination Id] == [destination Id]) {
                    return YES;
                }
            }
        }
        if ([destination isKindOfClass:[NSArray class]]) {
            //TODO make it one transaction for all records
            for (ARJActiveRecord *record in destination){
                [record setAttribute:@([source Id]) forKey:self.foreignKey];
                

                if (![record saveInDatabaseManager:manager]) {
                    return NO;
                }
            }
            return YES;
        }else{
            [destination setAttribute:@([source Id]) forKey:self.foreignKey];
            if (![destination saveInDatabaseManager:manager]) {
                return NO;
            }else{
                return YES;
            }
        }
        
    }];
}

-(id)destinationForSource:(ARJActiveRecord *)source inDatabaseManager:(ARJDatabaseManager *)manager{
    if (![source Id]) {
        return [NSMutableArray array];
    }else{
    NSMutableArray * res =  [NSMutableArray arrayWithArray:[self.destinationModel find:@{self.foreignKey : @([source Id])} inDatabaseManager:manager]];
    return res;
    }
}

-(id)destinationForSource:(ARJActiveRecord *)source{
    return [self destinationForSource:source inDatabaseManager:source.correspondingDatabaseManager];
}

-(id)blankValue{
    return [NSMutableArray array];
}

@end

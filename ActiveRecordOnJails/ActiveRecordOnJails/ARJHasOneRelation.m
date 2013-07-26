//
//  ARJHasOneRelation.m
//  ActiveRecord on Jails
//
//  Created by skonb on 2013/06/21.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ARJHasOneRelation.h"
#import "ARJDatabaseManager.h"
#import "ARJActiveRecord.h"
@implementation ARJHasOneRelation
-(BOOL)willDestroySourceInstance:(ARJActiveRecord*)instance{
    return [self willDestroySourceInstance:instance inDatabaseManager:instance.correspondingDatabaseManager];
}

-(BOOL)willDestroySourceInstance:(ARJActiveRecord *)instance inDatabaseManager:(ARJDatabaseManager *)manager{
    return [manager runInTransaction:^BOOL(id database){
        ARJActiveRecord *record = [instance associatedForKey:self.relationName];
        if (self.dependency == ARJRelationDependencyNullify) {
            if(![record update:@{self.foreignKey: [NSNull null]}]){
                return NO;
            };
        }else if(self.dependency == ARJRelationDependencyDestroy){
            if(![record destroy]){
                return NO;
            }
        }
        
        return YES;
    }];
}

-(NSDictionary*)attributes{
    return @{};
}

-(BOOL)setDestinationInstance:(id)destination toSourceInstance:(id)source{
    return [self setDestinationInstance:destination toSourceInstance:source inDatabaseManager:[[self class]expectedDatabaseManagerForSource:source andDestination:destination]];
}

-(BOOL)setDestinationInstance:(id)destination toSourceInstance:(id)source inDatabaseManager:(ARJDatabaseManager *)manager{
    return [manager runInTransaction:^BOOL(id database){
        if (![source Id]) {
            if(![source save]){
                return NO;
            }
        }
        ARJActiveRecord* currentDestination = [source associatedForKey:self.relationName];
        if (currentDestination) {
            if ([currentDestination Id] == [destination Id]) {
                
            }else{
                if (self.dependency == ARJRelationDependencyDestroy) {
                    if(![currentDestination destroy]){
                        return NO;
                    }
                }else{
                    if(![currentDestination update:@{self.foreignKey: [NSNull null]} inDatabaseManager:manager]){
                        return NO;
                    }
                }
            }
        }
        [destination setAttribute:@([source Id]) forKey:self.foreignKey];
        if (![destination saveInDatabaseManager:manager]) {
            return NO;
        }else{
            return YES;
        }
    }];
}

-(id)destinationForSource:(ARJActiveRecord *)source inDatabaseManager:(ARJDatabaseManager *)manager{
    if (![source Id]) {
        return nil;
    }else{
        return [self.destinationModel findFirst:@{self.foreignKey : @([source Id])} inDatabaseManager:manager];
    }
}

-(id)destinationForSource:(ARJActiveRecord *)source{
    return [self destinationForSource:source inDatabaseManager:source.correspondingDatabaseManager];
}

@end

//
//  ARJHasManyRelation.m
//  ActiveRecordOnJails
//
//  Created by skonb on 2013/06/21.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ARJHasManyRelation.h"
#import "ARJActiveRecord.h"
#import "ARJDatabaseManager.h"
@implementation ARJHasManyRelation
-(BOOL)willDestroySourceInstance:(ARJActiveRecord*)instance{
    return [self willDestroySourceInstance:instance inDatabaseManager:[ARJDatabaseManager forRecord:instance]];
}

-(BOOL)willDestroySourceInstance:(ARJActiveRecord *)instance inDatabaseManager:(ARJDatabaseManager *)manager{
    return [manager runInTransaction:^BOOL{
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

-(BOOL)setDestinationInstance:(id)destination toSourceInstance:(id)source{
    return [self setDestinationInstance:destination toSourceInstance:source inDatabaseManager:[[self class]expectedDatabaseManagerForSource:source andDestination:destination]];
}

-(BOOL)setDestinationInstance:(id)destination toSourceInstance:(id)source inDatabaseManager:(ARJDatabaseManager *)manager{
    return [manager runInTransaction:^BOOL{
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
        [destination setAttribute:@([source Id]) forKey:self.foreignKey];
        if (![destination saveInDatabaseManager:manager]) {
            return NO;
        }else{
            return YES;
        }
    }];
}

-(id)destinationForSource:(ARJActiveRecord *)source inDatabaseManager:(ARJDatabaseManager *)manager{
    return [self.destinationModel find:@{self.foreignKey : @([source Id])} inDatabaseManager:manager];
}

-(id)destinationForSource:(ARJActiveRecord *)source{
    return [self destinationForSource:source inDatabaseManager:source.correspondingDatabaseManager];
}


@end

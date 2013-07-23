//
//  ARJAssociationValidator.m
//  ActiveRecord on Jails
//
//  Created by skonb on 2013/06/25.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ARJAssociationValidator.h"
#import "ARJActiveRecord.h"

@implementation ARJAssociationValidator
-(BOOL)validateInstance:(ARJActiveRecord*)instance{
    id value = [instance latestValueForKey:self.targetProperty];
    if ([self validateBlankValue:value]) {
        return YES;
    }else{
        BOOL res = YES;
        id associated = [instance associatedForKey:self.targetProperty];
        if (associated) {
            if ([associated isKindOfClass:[NSArray class]]) {
                for (ARJActiveRecord * record in associated){
                    res = [record validate];
                    [instance.errors mergeErrors:record.errors keyPrefix:self.targetProperty];
                }
            }else{
                res = [associated validate];
                [instance.errors mergeErrors:[associated errors] keyPrefix:self.targetProperty];
            }
        }
        return res;
    }
}

-(BOOL)validateInstance:(ARJActiveRecord *)instance inDatabaseManager:(ARJDatabaseManager *)manager{
    return [self validateInstance:instance];
}

@end

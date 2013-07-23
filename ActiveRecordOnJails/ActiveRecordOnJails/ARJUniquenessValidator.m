//
//  ARJUniquenessValidator.m
//  ActiveRecord on Jails
//
//  Created by skonb on 2013/06/24.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ARJUniquenessValidator.h"
#import "ARJActiveRecord.h"
@implementation ARJUniquenessValidator
-(BOOL)validateInstance:(ARJActiveRecord*)instance inDatabaseManager:(ARJDatabaseManager *)manager{
    id value = [instance latestValueForKey:self.targetProperty];
    if ([self validateBlankValue:value]) {
        return YES;
    }else{
        BOOL res = YES;
        ARJActiveRecord * anotherRecord = [[instance class]findFirst:@{self.targetProperty : value}inDatabaseManager:manager];
        if (anotherRecord) {
            if ([anotherRecord Id] != [instance Id]) {
                [instance.errors addErrorMessage:@"Uniqueness Error" forKey:self.targetProperty];
                res = NO;
            }
        }
        return res;
    }
}
@end

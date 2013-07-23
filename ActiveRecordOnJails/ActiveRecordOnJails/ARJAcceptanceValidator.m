//
//  ARJAcceptanceValidator.m
//  ActiveRecord on Jails
//
//  Created by skonb on 2013/06/24.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ARJAcceptanceValidator.h"
#import "ARJActiveRecord.h"
@implementation ARJAcceptanceValidator
-(BOOL)validateInstance:(ARJActiveRecord*)instance{
    [self doesNotRecognizeSelector:@selector(validateInstance:)];
    return NO;
}
@end

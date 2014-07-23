//
//  ARJDateTimeAttribute.m
//  ActiveRecord on Jails
//
//  Created by skonb on 2013/06/22.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ARJDateTimeAttribute.h"
#import "ARJActiveRecord.h"
@implementation ARJDateTimeAttribute
-(NSString*)columnTypeString{
    return @"INTEGER";
}

-(id)valueForInstance:(ARJActiveRecord *)instance{
    id val =[instance latestValueForKey:self.columnName];
    if (arj_not_nil(val)){
        NSTimeInterval serial = [val integerValue];
        return [NSDate dateWithTimeIntervalSince1970:serial];
    }else{
        return [NSNull null];
    }
}

-(void)setValue:(id)attribute forInstance:(ARJActiveRecord*)instance{
    if (arj_nil(attribute)) {
        [super setValue:[NSNull null] forInstance:instance];
    }else{
        NSTimeInterval serial = [attribute timeIntervalSince1970];
        [super setValue:@((NSInteger)serial) forInstance:instance];
    }
}

-(NSString*)defaultValueSpecifier{
    return [NSString stringWithFormat:@"%.0f", [self.defaultValue timeIntervalSince1970]];
}

@end

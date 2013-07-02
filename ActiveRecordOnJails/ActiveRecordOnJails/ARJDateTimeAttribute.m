//
//  ARJDateTimeAttribute.m
//  ActiveRecordOnJails
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
    NSTimeInterval serial = [[instance latestValueForKey:self.columnName]integerValue];
    return [NSDate dateWithTimeIntervalSince1970:serial];
}

-(void)setValue:(id)attribute forInstance:(ARJActiveRecord*)instance{
    NSTimeInterval serial = [attribute timeIntervalSince1970];
    [super setValue:@(serial) forInstance:instance];
}

-(NSString*)defaultValueSpecifier{
    return [NSString stringWithFormat:@"%.0f", [self.defaultValue timeIntervalSince1970]];
}

@end

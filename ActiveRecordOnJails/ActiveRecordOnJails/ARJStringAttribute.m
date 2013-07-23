//
//  ARJStringAttribute.m
//  ActiveRecord on Jails
//
//  Created by skonb on 2013/06/22.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ARJStringAttribute.h"

@implementation ARJStringAttribute
-(NSString*)columnTypeString{
    return @"TEXT";
}

-(NSString*)defaultValueSpecifier{
    return [NSString stringWithFormat:@"'%@'", self.defaultValue];
}

@end

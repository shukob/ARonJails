//
//  ARJScopeFactory.m
//  ActiveRecord on Jails
//
//  Created by skonb on 2013/07/20.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "ARJScopeFactory.h"
#import "ARJScope.h"
#import "ARJActiveRecord.h"
@implementation ARJScopeFactory
+(ARJScopeFactory*)scopeFactoryWithBlock:(void(^)(ARJScope*, NSDictionary*))block forModel:(Class)model{
    ARJScopeFactory * builder =[ARJScopeFactory new];
    builder.block = block;
    builder.model = model;
    return builder;
}

-(ARJScope*)produce:(NSDictionary *)params{
    __block ARJScope * scope= [self.model scoped];
    self.block(scope, params);
    return scope;
}

@end

//
//  ARJScopeFactory.h
//  ActiveRecord on Jails
//
//  Created by skonb on 2013/07/20.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ARJScope;
@interface ARJScopeFactory : NSObject
+(ARJScopeFactory*)scopeFactoryWithBlock:(void(^)(ARJScope*, NSDictionary*))block forModel:(Class)model;
-(ARJScope*)produce:(NSDictionary*)params;
@property (nonatomic, copy) void(^block)(ARJScope*, NSDictionary*);
@property (nonatomic, weak) Class model;
@end

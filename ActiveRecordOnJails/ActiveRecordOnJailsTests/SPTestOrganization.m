//
//  SPTestOrganization.m
//  ActiveRecord on Jails
//
//  Created by skonb on 2013/06/25.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "SPTestOrganization.h"

@implementation SPTestOrganization

arj_model(Organization);

arj_attributes(arj_string(name));

arj_relations(arj_has_many(users, @"class": @"SPTestUser"));

arj_validations(arj_validates_presence_of(name),
                arj_validates_associated(users));

@end

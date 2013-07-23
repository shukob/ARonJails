//
//  SPTestUser.m
//  SuccessPlanner
//
//  Created by skonb on 2013/06/25.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "SPTestUser.h"

@implementation SPTestUser
arj_model(User);


arj_attributes(arj_string(name, ARJAttributeDefaultValueSpecifier : @"test"),
               arj_integer(age, ARJAttributeDefaultValueSpecifier : @(10)),
               arj_datetime(birthday),
               arj_blob(picture),
               arj_float(height),
               arj_string(email));


arj_relations(arj_belongs_to(organization, ARJClassNameSpecifier : @"SPTestOrganization", ARJAutoSaveSpecifier : @YES));


arj_validations(arj_validates_length_of(name, ARJValidationLessThanOrEqualToSpecifier : @(12), ARJValidationAllowBlankSpecifier : @YES),
                arj_validates_numericality_of(age, ARJValidationGreaterThanOrEqualToSpecifier : @(0)),
                arj_validates_format_of(email, @"\\A([^@\\s]+)@((?:[-a-z0-9]+\\.)+[a-z]{2,})\\Z", @"allow_blank": @YES),
                arj_validate(validateSizeOfPicture:),
                arj_validates_uniqueness_of(email, @"allow_blank" : @YES));

arj_scopes(arj_scope(under_age, {([scope WHERE:@{@"age < ?" : params[@"age"]}, nil]);}),
           arj_scope(with_name, {([scope WHERE:@{@"name":params[@"name"]}, nil]);})
           );

arj_callbacks(arj_before_validation(setUpDefaults:),
              arj_after_initialize(afterInitialize:),
              arj_after_create(afterCreate:),
              arj_after_destroy(afterDestroy:),
              arj_after_save(afterSave:),
              arj_after_validation(afterValidation:),
              arj_after_comit(afterCommit),
              arj_before_validation(beforeValidation:),
              arj_before_destroy(beforeDestroy:),
              arj_before_save(beforeSave:),
              arj_before_create(beforeCreate:));

-(id)afterInitialize:(id)sender{
    self.customProperty[@"afterInitialize"]=@YES;
    return @YES;
}

-(id)afterCreate:(id)sender{
    self.customProperty[@"afterCreate"]=@YES;
    return @YES;
}

-(id)afterDestroy:(id)sender{
    self.customProperty[@"afterDestroy"]=@YES;
    return @YES;
}

-(id)afterSave:(id)sender{
    self.customProperty[@"afterSave"]=@YES;
    return @YES;
}

-(id)afterValidation:(id)sender{
    self.customProperty[@"afterValidation"]=@YES;
    return @YES;
}

-(id)afterCommit:(id)sender{
    self.customProperty[@"afterCommit"]=@YES;
    return @YES;
}

-(id)beforeValidation:(id)sender{
    self.customProperty[@"beforeValidation"]=@YES;
    return @YES;
}

-(id)beforeDestroy:(id)sender{
    self.customProperty[@"beforeDestroy"]=@YES;
    return @YES;
}

-(id)beforeSave:(id)sender{
    self.customProperty[@"beforeSave"]=@YES;
    return @YES;
}

-(id)beforeCreate:(id)sender{
    self.customProperty[@"beforeCreate"]=@YES;
    return @YES;
}

-(id)init{
    self.customProperty = [NSMutableDictionary dictionary];
    if ([super init]) {

    }
    return self;
}

+(id)validateSizeOfPicture:(id)instance{
    id value = [instance latestValueForKey:@"picture"];
    if (CMIsNil(value)) {
        return @YES;
    }else{
        UIImage *image = [UIImage imageWithData:value];
        if (image.size.height > 100 || image.size.height > 100) {
            [[instance errors]addErrorMessage:@"Picture Size" forKey:@"picture"];
            return @NO;
        }else{
            return @YES;
        }
    }
}



@end

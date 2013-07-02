//
//  SPTestUser.m
//  ActiveRecordOnJails
//
//  Created by skonb on 2013/06/25.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "SPTestUser.h"
#import <UIKit/UIKit.h>

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
+(id)validateSizeOfPicture:(id)instance{
    id value = [instance latestValueForKey:@"picture"];
    if (value == nil || value == [NSNull null])  {
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

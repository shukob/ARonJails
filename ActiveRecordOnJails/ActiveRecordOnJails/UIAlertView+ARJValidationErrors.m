//
//  UIAlertView+ARJValidationErrors.m
//  ActiveRecord on Jails
//
//  Created by skonb on 2013/07/24.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import "UIAlertView+ARJValidationErrors.h"

@implementation UIAlertView (ARJValidationErrors)
+(UIAlertView*)alertViewWithErrors:(ARJValidationErrors*)errors forDelegate:(id<UIAlertViewDelegate>)delegate{
    UIAlertView *av = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Error", @"") message:[errors.fullMessages componentsJoinedByString:@"\n"] delegate:delegate cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
    return av;
}

@end

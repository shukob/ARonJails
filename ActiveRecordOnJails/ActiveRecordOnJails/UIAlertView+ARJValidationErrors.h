//
//  UIAlertView+ARJValidationErrors.h
//  ActiveRecord on Jails
//
//  Created by skonb on 2013/07/24.
//  Copyright (c) 2013年 skonb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARJValidationErrors.h"
@interface UIAlertView (ARJValidationErrors)
+(UIAlertView*)alertViewWithErrors:(ARJValidationErrors*)errors forDelegate:(id<UIAlertViewDelegate>)delegate;
@end

Active Record on Jails
=========

RoR style ActiveRecord ORM Wrapper over FMDB on iOS


###Currently not fully tested, documented nor featured.
###It is absolutely not recommended to use this in any product now.

features
---------

1. Implement with declaration.
2. Automatic migration.
3. Validations and errors.

dependency
---------
1. FMDB[https://github.com/ccgus/fmdb]
2. ActiveSupportInflector[https://github.com/tomafro/ActiveSupportInflector]


installation
---------
Just include sources in your project, as well as dependencies.


examples
-----------

1. Models

```objective-c
//XYZUser.h

@interface XYZUser : ARJActiveRecord
@end


///XYZUser.m

@implementation XYZUser
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
```


2. SetUp

```objective-c
[[ARJDatabaseManager defaultManager]setDbName:@"test.sqlite"];
[[ARJDatabaseManager defaultManager]setModels:@[@"XYZUser", @"XYZOrganization"]];
[[ARJDatabaseManager defaultManager]migrate]; // Creates required database and tables
```


3. Interact with instances

```objective-c

//Init and save
XYZUser *user = [[XYZUser alloc]initWithDictionary:@{@"age": @(20)}];
[user save];

//Create
user = [XYZUser create:@{@"age" : @(80)}];

//Read
user = [XYZUser findFirst:@{@"age": @(80)}];


//Update
[user update:@{@"name" : @"Dave"}];


//Destroy
[user destroy];

//Set Attribute
NSData *data = UIImageJPEGRepresentation([UIImage imageNamed:@"some_picture.png"]);
[user setAttribute:data forKey:@"picture"];
[user save];

//Get Attribute
[user attributeForKey:@"name"]; // => @"Dave"

//Set Association
XYZOrganization *org = [[XYZOrgzanization alloc]initWithDictionary:@{@"name" : @"Example Inc."}];
[user setAssociated:org forKey:@"organization"];
[user save]; //Saves organization if autosave: true for this relation

org = [XYZOrganization findFirst:@{}]; // @"name" is @"Example Inc."

[user setAssociated:@(-1) forKey:@"age"];
[user save]; // => returns NO and user.errors.count becomes 1


```

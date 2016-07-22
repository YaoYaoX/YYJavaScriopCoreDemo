//
//  OCPerson.m
//  WebviewTest
//
//  Created by YaoYaoX on 16/7/22.
//  Copyright © 2016年 YY. All rights reserved.
//

#import "OCPerson.h"

@implementation OCPerson

@synthesize extMes;

- (NSString *)fullName {
    return [NSString stringWithFormat:@"%@·%@", self.firstName, self.lastName];
}

- (void)doSometing:(id)something withSomeone:(OCPerson *)someone{
    NSLog(@"%@ %@ %@",self.fullName,something,someone.fullName);
}

- (void)setFirstName:(NSString *)fn lastName:(NSString *)ln desc:(NSDictionary *)desc{
    self.firstName = fn;
    self.lastName = ln;
    self.extMes = desc;
}
@end

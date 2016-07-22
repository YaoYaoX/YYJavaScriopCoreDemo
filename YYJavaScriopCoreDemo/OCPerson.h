//
//  OCPerson.h
//  WebviewTest
//
//  Created by YaoYaoX on 16/7/22.
//  Copyright © 2016年 YY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>



@protocol OCPersonExport <JSExport>

@property (nonatomic, strong) NSDictionary *extMes;

- (NSString *)fullName;
- (void)doSometing:(id)something withSomeone:(id)someone;

// 自定义js方法名：宏JSExportAs(PropertyName, Selector)
JSExportAs(setInfo, - (void)setFirstName:(NSString *)fn lastName:(NSString *)ln desc:(NSDictionary *)desc);

@end


@interface OCPerson : NSObject<OCPersonExport>

@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;

@end

@protocol JSUITextFieldExport <JSExport>

@property(nonatomic,copy) NSString *text;

@end

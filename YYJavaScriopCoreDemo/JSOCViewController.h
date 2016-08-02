//
//  JSOCViewController.h
//  YYJavaScriopCoreDemo
//
//  Created by YaoYaoX on 16/8/1.
//  Copyright © 2016年 YY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>


@protocol JSOCViewControllerExport <JSExport>

// 拍照
- (void)takePicture;

@end


@interface JSOCViewController : UIViewController<JSOCViewControllerExport>

@end

//
//  JSOCViewController.m
//  YYJavaScriopCoreDemo
//
//  Created by YaoYaoX on 16/8/1.
//  Copyright © 2016年 YY. All rights reserved.
//

/*
 *  说明：
 *  1. 加载完网页时，获取javascript的运行环境 self.jsContext
 *  2. JS调用OC方法takePicture： 点击网页的“Select Picture”按钮时，调用 JSOCViewController 的方法 -(void)takePicture;
 *  3. OC调用JS方法showResult： 选择完图片后，OC调用JS的修改红色文字的方法
 */

#import "JSOCViewController.h"

@interface JSOCViewController ()<UIWebViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (nonatomic, strong) JSContext *jsContext;

@end

@implementation JSOCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"JSOC.html" withExtension:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    self.webview.delegate = self;
    [self.webview loadRequest:request];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    // 获取网页标题
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    // 1. 获取js执行环境
    self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    // 1.1 传递相关对象
    self.jsContext[@"ocObject"] = self;
    self.jsContext.exceptionHandler = ^(JSContext *con, JSValue *exception) {
        
        con.exception = exception;
        
        NSLog(@"%@", exception);
    };
}


/** 2. takePhote方法必须是协议JSExport中的方法，查看头文件协议 */
- (void)takePicture{
    
    // 运行时发现一个问题：会报一下问题：This application is modifying the autolayout engine from a background thread
    // 然后，发现不在主线程，但UI修改需在主线程运行，所以有了下面的GCD
    NSLog(@"%@",[NSThread currentThread]);
    
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // 对话框提示
        UIAlertController *actionSheet = [[UIAlertController alloc]init];
        
        UIAlertAction *act0 = [UIAlertAction actionWithTitle:@"OC拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            if (![UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera]) {
                // 3. OC 调用 JS 方法
                JSValue *updateFunc = self.jsContext[@"showResult"];
                [updateFunc callWithArguments:@[@"相机不支持"]];
                return ;
            }
            
            //资源类型为照相机
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = weakSelf;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [weakSelf presentViewController:picker animated:YES completion:nil];
        }];
        
        UIAlertAction *act1 = [UIAlertAction actionWithTitle:@"OC相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //资源类型为图片库
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = weakSelf;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [weakSelf presentViewController:picker animated:YES completion:nil];
        }];
        
        UIAlertAction *act2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [actionSheet addAction:act0];
        [actionSheet addAction:act1];
        [actionSheet addAction:act2];
        
        [weakSelf presentViewController:actionSheet animated:YES completion:nil];
        
    });

}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    // 3. OC 调用 JS 方法
    JSValue *updateFunc = self.jsContext[@"showResult"];
    [updateFunc callWithArguments:@[@"已选择"]];
    
    //关闭相册界面
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    // 3. OC 调用 JS 方法
    JSValue *updateFunc = self.jsContext[@"showResult"];
    [updateFunc callWithArguments:@[@"取消选择"]];
    
    //关闭相册界面
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end

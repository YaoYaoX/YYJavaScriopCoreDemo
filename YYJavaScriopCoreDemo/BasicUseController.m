//
//  BasicUseController.m
//  YYJavaScriopCoreDemo
//
//  Created by YaoYaoX on 16/7/22.
//  Copyright © 2016年 YY. All rights reserved.
//

#import "BasicUseController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "OCPerson.h"
#import <objc/runtime.h>

@interface BasicUseController ()

@property (nonatomic, strong) NSArray *data;

@end

@implementation BasicUseController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"基本使用";
    self.data = @[@{@"title":@"1.JS与OC变量之间的转换", @"func":@"jsValue2OCValue"},
                  @{@"title":@"2.JSValue的使用", @"func":@"jsValueProperty"},
                  @{@"title":@"3.JS调用OC方法", @"func":@"js_call_oc_block"},
                  @{@"title":@"4.OC调用JS方法", @"func":@"oc_call_js_func"},
                  @{@"title":@"5.异常处理", @"func":@"jsExceptionHandler"},
                  @{@"title":@"6.block使用注意", @"func":@"blockUse"},
                  @{@"title":@"7.JSExport的使用", @"func":@"jsExportTest"},
                  @{@"title":@"8.为已定义的类扩展协议", @"func":@"extendJSExportProtocal"},
                  @{@"title":@"9.内存处理", @"func":@"memoryTest"}];
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"reuseIdentifier";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ID];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    cell.textLabel.text = self.data[indexPath.row][@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *funcStr = self.data[indexPath.row][@"func"];
    [self performSelector:NSSelectorFromString(funcStr)];
}


#pragma mark - 基本使用


/** JS与OC变量之间的转换 */
- (void)jsValue2OCValue{
    
    /**
     *  1.JSContext：为javaScript提供运行环境
     *  2.JSContext通过-evaluateScript:方法执行JavaScript代码，并且代码中的方法、变量等信息都会被存储在JSContext实例中以便在需要的时候使用
     *  3.JSValue: OC对象与JS对象之间的转换桥梁
     
     Objective-C type  |   JavaScript type
     --------------------+---------------------
     nil         |     undefined
     NSNull       |        null
     NSString      |       string
     NSNumber      |   number, boolean
     NSDictionary    |   Object object
     NSArray       |    Array object
     NSDate       |     Date object
     NSBlock (1)   |   Function object (1)
     id (2)     |   Wrapper object (2)
     Class (3)    | Constructor object (3)
     *
     */
    
    // 1. 创建javaScript的运行环境
    JSContext *jsC = [[JSContext alloc] init];
    
    // 2. 执行js代码： - (JSValue *)evaluateScript:(NSString *)script
    NSString *jsCode = @"var jsv1 = 123; var jsv2 = 'jsString' ";
    [jsC evaluateScript:jsCode];
    
    // 3. 通过JSValue获取js中的变量jsv1
    JSValue *jsv1 = jsC[@"jsv1"];
    
    // 4. 将JSValue转换为OC变量
    int ocv1 = [jsv1 toInt32];
    NSLog(@"%d",ocv1);
    
    // 5. 获取变量jsv2并转换
    JSValue *jsv2 = jsC[@"jsv2"];
    NSString *ocv2 = [jsv2 toString];
    NSLog(@"%@",ocv2);
}

/** JSValue的使用：JSValue通过下标可以获取对象及对象的属性值，也可以通过下标直接取值和赋值 */
- (void)jsValueProperty{
    
    // 1. 创建js运行环境并执行js代码
    JSContext *jsC = [[JSContext alloc] init];
    NSString *jsCode = @"var jsvArr = [123,'jsString'] ";
    [jsC evaluateScript:jsCode];
    
    // 2. 以下标的方式，通过变量名从JSContext中获取jsvArr
    JSValue *jsvArr = jsC[@"jsvArr"];
    NSLog(@"------Before set-----\n");
    NSLog(@"%@",jsvArr);
    
    // 3. 直接通过下标赋值（js无下标越位，自动延展数组大小）
    jsvArr[3] = @(YES);
    NSLog(@"------After set-----\n");
    NSLog(@"%@",jsvArr);
    
    // 4. 获取数组的属性值：length
    NSLog(@"------Property-----\n");
    NSLog(@"Array length = %@,%@",jsvArr[@"length"],[jsvArr[@"length"] class]);
}

/** JS调用OC方法 */
- (void)js_call_oc_block{
    
    /** JS调用OC方法
     *  1. 方式：在JSContext中传入OC的Block当做JS的function
     *  2. 获取JS参数列表:JSContext的方法，+(JSContext *)currentArguments
     *  3. 获取调用该方法的对象：JSContext的方法，+ (JSValue *)currentThis)
     */
    
    // 1. 创建js运行环境
    JSContext *jsC = [[JSContext alloc] init];
    
    // 2. 定义block方法供js使用
    jsC[@"log"] = ^(){
        
        NSLog(@"-------Begin Log-------");
        
        // 获取调用该方法时的参数
        NSArray *args = [JSContext currentArguments];
        for (JSValue *jsVal in args) {
            id dict = [jsVal toObject];
            NSLog(@"%@", dict);
        }
        
        
        // 获取调用该方法的对象
        JSValue *this = [JSContext currentThis];
        NSLog(@"this: %@",this);
        
        
        NSLog(@"-------End Log-------");
        
    };
    
    // 3. js直接调用oc传入的block
    NSString *jsCode = @"log('logVal1', [7, 21], { hello:'world', js:100 });";
    [jsC evaluateScript:jsCode];
    
    
    // 4. js直接使用oc传入的变量
    jsC[@"newJSValue1"] = @(456);
    [jsC evaluateScript:@"log(newJSValue1)"];
}

/** OC调用JS方法 */
- (void)oc_call_js_func{
    /*
     * OC调用JS方法：
     * 1. JS的Func不能转化成OC的Block：JavaScript方法的参数不固定,Block的参数个数和类型已经返回类型都是固定的
     * 2. 方式1: JSValue的方法-(JSValue *)callWithArguments:(NSArray *)arguments可以运行JS的func
     * 3. 方式2: JSValue的方法- (JSValue *)invokeMethod:(NSString *)method withArguments:(NSArray *)arguments直接简单地调用对象上的方法。
     * 4. 对于方式2，如果是全局函数，用JSContext的globalObject对象调用；如果是某JavaScript对象上的方法，就应该用相应的JSValue对象调用。
     */
    
    // 1. 创建js运行环境并执行js代码
    JSContext *jsC = [[JSContext alloc] init];
    NSString *jsCode = @"function add(a, b) { return a + b; }";
    [jsC evaluateScript:jsCode];
    
    // 2. 获取方法
    JSValue *add = jsC[@"add"];
    NSLog(@"Func: %@", add);
    
    // 3. 方式1调用js的Func
    JSValue *sum1 = [add callWithArguments:@[@(7), @(21)]];
    NSLog(@"Sum1: %d",[sum1 toInt32]);
    
    // 4. 方式2调用js的Func:全局函数
    JSValue *sum2 = [[jsC globalObject] invokeMethod:@"add" withArguments:@[@(1), @(2)]];
    NSLog(@"Sum2: %d",[sum2 toInt32]);
    
}

/** 异常处理 */
- (void)jsExceptionHandler{
    
    /*
     * 异常处理
     * OC异常会在运行时被Xcode捕获，而在JSContext中执行的JavaScript异常只会被JSContext捕获并存储在exception属性上，不会向外抛出。
     * 如果需要监测JSContext的异常，最合理的方式是给JSContext对象设置exceptionHandler
     */
    
    JSContext *context = [[JSContext alloc] init];
    context.exceptionHandler = ^(JSContext *con, JSValue *exception) {
        NSLog(@"%@", exception);
        
        //别忘了给exception赋值，否则JSContext的异常信息为空
        con.exception = exception;
    };
    
    [context evaluateScript:@"arrar[0] = 21"];
}

/** block使用注意 */
- (void)blockUse{

    /*
     * 在Block内都不要直接使用其外部定义的JSContext对象或者JSValue，否则会造成循环引用使得内存无法被正确释放。
     * 应该将其当做参数传入到Block中，或者通过JSContext的类方法+ (JSContext *)currentContext获得。
     * 原因：
     1. JSContext会强引用Block
     2. Block引用外部对象时会做强引用
     3. 每个JSValue都会强引用一个JSContext
     4. block引用外部JScontext(箭头都代表强引用)：     JSContext --> Block --> JSContext  循环引用
     5. block引用外部JSValue：           JSValue --> JSContext --> Block --> JSValue  循环引用
     */
}

/** JSExport的使用 */
- (void)jsExportTest{
    
    
    /*
     * 1. 所有JSExport协议(或子协议)中定义的方法和属性，都可以在JSContext中被使用
     * 2. 遵守了JSExport协议(或子协议)的类，额外定义的方法/属性，JSContext访问不到
     * 3. JSExport可以正确反映属性声明,例如readonly的属性，在JavaScript中也就只能读取值而不能赋值。
     * 4. 对于多参数的方法，为能被js使用，JavaScriptCore会对其进行转换。
     *      4.1 转换方式：将OC方法冒号后的字母大写，并移除冒号, 参数移到后面。
     *      4.2 例如:方法- (void)doSometing:(id)something withSomeone:(id)someone;
     *          在JavaScript调用就是：doSometingWithSomeone(something, someone);
     * 5. 自定义js方法名：宏JSExportAs(functionName, ocFunction),在js中只要调用方法名functionName，就可以访问oc对象的ocFunction方法
     */
    
    // 1.初始化
    JSContext *jsC = [[JSContext alloc] init];
    jsC[@"log"] = ^(){
        NSArray *args = [JSContext currentArguments];
        for (JSValue *jsVal in args) {
            NSLog(@"%@", jsVal);
        }
    };
    jsC.exceptionHandler = ^(JSContext *con, JSValue *exception) {
        NSLog(@"%@", exception);
        con.exception = exception;
    };
    
    
    // 2.创建oc类，并传入js运行环境中
    OCPerson *person = [[OCPerson alloc] init];
    person.firstName = @"O";
    person.lastName = @"C";
    person.extMes = @{@"desc":@"这是OC类1",@"value":@(123)};
    jsC[@"person"] = person;
    
    
    // 3.js使用oc对象的属性和方法
    // 3.1 调用OCPersonExport中的方法 -(NSString *)fullName;
    [jsC evaluateScript:@"log('-----fullName-----',person.fullName());"];
    
    // 3.2 未获取到，OCPersonExport没有定义该属性／方法
    [jsC evaluateScript:@"log('-----firstName-----',person.firstName);"];
    
    // 3.3 未获取到，OCPersonExport没有定义该属性／方法
    [jsC evaluateScript:@"log('-----lastName-----',person.lastName);"];
    
    // 3.4 获取OCPersonExport的属性值extMes;
    [jsC evaluateScript:@"log('-----extMes-----','desc:', person.extMes.desc, 'value:', person.extMes.value);"];
    
    // 3.5 修改OCPersonExport的属性值extMes;
    [jsC evaluateScript:@"person.extMes = {desc:'被js修改后的OC类1'}"];
    
    // 3.6 获取属性extMes
    [jsC evaluateScript:@"log('-----extMes-----','desc:', person.extMes.desc, 'value:', person.extMes.value);"];
    
    // 4. oc对象里面的值也确实被修改了
    NSLog(@"-----AFTER-----");
    NSLog(@"\n%@", person.extMes);
    
    
    // 5. 多参数方法调用
    OCPerson *person2 = [[OCPerson alloc] init];
    person2.firstName = @"J";
    person2.lastName = @"S";
    jsC[@"person2"] = person2;
    NSLog(@"－－－JS调用OC多参数方法－－－");
    [jsC evaluateScript:@"person.doSometingWithSomeone('talk to', person2);"]; // 获取属性
    
    
    // 6. 自定义js方法名
    // JSExportAs(setInfo, - (void)setFirstName:(NSString *)fn lastName:(NSString *)ln desc:(NSDictionary *)desc);
    // js调用setInfo(),相当于oc调用方法 -setFirstName:lastName:desc:
    NSLog(@"－－－定义js方法名－－－");
    [jsC evaluateScript:@"person2.setInfo('JS', 'New', {desc: ' call custom functionName'});"];
    [jsC evaluateScript:@"var str = person2.fullName() + person2.extMes.desc; log(str);"];
}

/** 为已定义的类扩展协议 */
- (void)extendJSExportProtocal{
    
    /**
     *  为已定义的类扩展协议－－class_addProtocol
     *  1. 自定义的OC类，可以继承自定义的JSExport的协议实现与JavaScript的交互
     *  2. 对于已经定义好的系统类或者外部类，预先不会定义协议提供与JavaScript的交互，OC可以在运行时实时对类拓展协议。
     */
    
    // 1. 初始化
    JSContext *jsC = [[JSContext alloc] init];
    jsC[@"log"] = ^(){
        NSArray *args = [JSContext currentArguments];
        for (JSValue *jsVal in args) {
            NSLog(@"%@", jsVal);
        }
    };
    jsC.exceptionHandler = ^(JSContext *con, JSValue *exception) {
        NSLog(@"%@", exception);
        con.exception = exception;
    };
    
    
    // 2. 扩展协议
    class_addProtocol([UITextField class], @protocol(JSUITextFieldExport));
    UITextField *textField = [[UITextField alloc]init];
    textField.text = @"0";
    jsC[@"textField"] = textField;
    
    
    // 3. 获取扩展协议的属性，并赋值
    NSLog(@"－－为已定义的类扩展协议－－");
    NSString *script = @"var num = parseInt(textField.text, 10);"// js获取属性值
    "textField.text = 10;"                                       // js赋值
    "var string = 'oldText:'+num+' newText:'+textField.text;"
    "log(string)";
    [jsC evaluateScript:script];
}

/** 内存处理 */
- (void)memoryTest{
    
    /** 内存处理
     *  1. Objective-C是基于引用计数MRC/自动引用计数ARC, javaScript是垃圾回收机制GC, JavaScript对对象的引用为强引用
     
     *  2. js引用oc变量异常情况：在一个方法中创建了一个临时的OC对象，将其加入到JSContext后被js使用，js会对该变量进行强引用不会释放回收（不会增加变量的引用计数器的值），但是OC上的对象可能在方法调用结束后，引用计数变0而被回收内存，此后JavaScript层面容易造成错误访问。
     
     *  3. oc引用js变量异常情况：如果用JSContext创建了对象或者数组，返回JSValue到Objective-C，即使把JSValue变量retain下，但可能因为JavaScript中因为变量没有了引用而被释放内存，那么对应的JSValue也没有用了。
     
     *  4. JSVirtualMachine： JSVirtualMachine就是一个用于保存弱引用对象的数组，加入该数组的弱引用对象因为会被该数组 retain，保证了使用时不会被释放，当数组里的对象不再需要时，就从数组中移除，没有了引用的对象就会被系统释放。
     
     *  5. JSManagedValue：将 JSValue 转为 JSManagedValue 类型后，可以添加到 JSVirtualMachine 对象中，这样能够保证你在使用过程中 JSValue 对象不会被释放掉，当你不再需要该 JSValue 对象后，从 JSVirtualMachine 中移除该 JSManagedValue 对象，JSValue 对象就会被释放并置空。）
     */
    
    
    /*
    
    // 1. 初始化
    JSContext *jsC = [[JSContext alloc] init];
    
    JSValue *value = [[JSValue alloc]init];
    JSManagedValue *managedV = [JSManagedValue managedValueWithValue:value];
    
    // 2. 需要的时候加入virtualMachine中
    [jsC.virtualMachine addManagedReference:managedV withOwner:self];
    
    // 3. 不需要的时候移除
    [jsC.virtualMachine removeManagedReference:managedV withOwner:self];
     
     */
}

@end

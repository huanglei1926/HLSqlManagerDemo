//
//  ViewController.m
//  HLSqlManagerDemo
//
//  Created by cainiu on 2019/3/5.
//  Copyright © 2019 Len. All rights reserved.
//

#import "ViewController.h"
#import "HLSqlManager/HLSqlTableManager.h"
#import "HLSqlManager/HLDBSqlManager.h"
#import "TestModel/HLTestModel1.h"
#import "TestModel/HLTestModel2.h"
#import "TestModel/HLTestModel3.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [HLSqlTableManager createTable];
    [self initTestDatas];
}

- (void)initTestDatas{
    HLTestModel1 *testModel1 = [HLTestModel1 new];
    testModel1.testModel1Num1 = 11;
    testModel1.testModel1Num2 = 12;
    testModel1.testModel1Num3 = 13;
    testModel1.testModel1String1 = @"11";
    testModel1.testModel1String2 = @"12";
    testModel1.testModel1String3 = @"13";
    
    HLTestModel2 *testModel2 = [HLTestModel2 new];
    testModel2.testModel2Num1 = 21;
    testModel2.testModel2Num2 = 22;
    testModel2.testModel2Num3 = 23;
    testModel2.testModel2String1 = @"21";
    testModel2.testModel2String2 = @"22";
    testModel2.testModel2String3 = @"23";
    
    HLTestModel3 *testModel3 = [HLTestModel3 new];
    testModel3.testModel3Num1 = 31;
    testModel3.testModel3Num2 = 32;
    testModel3.testModel3Num3 = 33;
    testModel3.testModel3String1 = @"31";
    testModel3.testModel3String2 = @"32";
    testModel3.testModel3String3 = @"33";
    [[HLDBSqlManager defaultManger] insertModel:testModel1];
    [[HLDBSqlManager defaultManger] insertModel:testModel2];
    [[HLDBSqlManager defaultManger] insertModel:testModel3];
}

@end

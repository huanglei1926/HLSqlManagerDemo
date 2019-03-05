//
//  HLSqlTableManager.m
//  HLSqlManagerDemo
//
//  Created by cainiu on 2019/3/5.
//  Copyright © 2019 Len. All rights reserved.
//

#import "HLSqlTableManager.h"
#import "HLDBSqlManager.h"

@implementation HLSqlTableManager

+ (NSArray *)modelTables{
    return @[@"HLTestModel1",@"HLTestModel2",@"HLTestModel3"];
}

+ (void)createTable{
    for (NSString *classNameString in [self modelTables]) {
        [self dataBaseUpdateTableWithTableName:classNameString];
    }
}

//数据库迁移
+ (void)dataBaseUpdateTableWithTableName:(NSString *)tableName{
    if (!tableName || !tableName.length) {
        return;
    }
    //判断表是否已创建
    if ([self isExistTableWithTableName:tableName]) {
        NSLog(@"===%@===存在",tableName);
        //开始更新数据库
        [self startUpdateTableWithTableName:tableName];
    }else{
        NSLog(@"===%@===不存在",tableName);
        [self createSql:NSClassFromString(tableName)];
    }
}

//数据库表是否存在
+ (BOOL)isExistTableWithTableName:(NSString *)tableName{
    NSString *sqlStr = [NSString stringWithFormat:@"select count(*) from sqlite_master where type = 'table' and name = '%@'",tableName];
    int count = [[HLDBSqlManager defaultManger] executeCount:sqlStr];
    return count > 0;
}

//开始更新数据库
+ (void)startUpdateTableWithTableName:(NSString *)tableName{
    Class tableModel = NSClassFromString(tableName);
    //获取模型属性列表
    NSArray *propertyList = [[HLDBSqlManager defaultManger] getAllPropertyNamesWithClass:tableModel];
    NSString *sqlStr = [NSString stringWithFormat:@"PRAGMA table_info(%@)",tableName];
    NSArray *sqlResultList = [[HLDBSqlManager defaultManger] executeQuery:sqlStr];
    if (propertyList == nil || sqlResultList == nil) {
        return;
    }
    //获取数据库字段列表
    NSMutableArray *sqlNameArray = [NSMutableArray array];
    for (NSDictionary *sqlResult in sqlResultList) {
        if (sqlResult[@"name"]) {
            [sqlNameArray addObject:sqlResult[@"name"]];
        }
    }
    
    BOOL isNeedUpdate = NO;
    //如果模型属性数量大于数据库字段数量,一定新增了字段
    if (propertyList.count > sqlNameArray.count) {
        isNeedUpdate = YES;
    }else{
        //对比字段是否有新增或修改
        for (NSString *propertyName in propertyList) {
            if (![sqlNameArray containsObject:propertyName]) {
                isNeedUpdate = YES;
                break;
            }
        }
    }
    if (isNeedUpdate) {
        //对原始数据库重命名
        //先删除旧数据
        if ([self isExistTableWithTableName:[NSString stringWithFormat:@"%@_old",tableName]]) {
            [self deleteTableWithTableName:[NSString stringWithFormat:@"%@_old",tableName]];
        }
        
        NSString *renameTableSql = [NSString stringWithFormat:@"alter table '%@' rename to '%@_old'",tableName,tableName];
        BOOL isSuccess = [[HLDBSqlManager defaultManger] execute:renameTableSql];
        if (!isSuccess) {
            NSLog(@"===============重命名表(%@)失败===============",tableName);
        }
        //新建数据库
        isSuccess = [self createSql:tableModel];
        if (!isSuccess) {
            NSLog(@"===============创建数据表(%@)失败===============",tableName);
        }
        //原始数据库内容迁移
        NSArray *repeatNameArray = [self filterSameArr:propertyList andArr2:sqlNameArray];
        NSString *repeatSqlString = [repeatNameArray componentsJoinedByString:@","];
        NSString *updateContentSql = [NSString stringWithFormat:@"insert into '%@' (%@) select %@ from '%@_old'",tableName,repeatSqlString,repeatSqlString,tableName];
        isSuccess = [[HLDBSqlManager defaultManger] execute:updateContentSql];
        if (!isSuccess) {
            NSLog(@"===============更新数据表(%@)失败===============",tableName);
        }
        //删除原始数据库
        isSuccess = [self deleteTableWithTableName:[NSString stringWithFormat:@"%@_old",tableName]];
        if (!isSuccess) {
            NSLog(@"===============删除表(%@_old)失败===============",tableName);
        }
    }
}
//删除数据库表
+ (BOOL)deleteTableWithTableName:(NSString *)tableName{
    NSString *deleteSql = [NSString stringWithFormat:@"drop table '%@'",tableName];
    BOOL isSuccess = [[HLDBSqlManager defaultManger] execute:deleteSql];
    return isSuccess;
}

+ (BOOL)createSql:(Class)modelType{
    NSString *tableName=[NSString stringWithFormat:@"%@",modelType];
    NSMutableString *sql = [NSMutableString stringWithFormat:@"create table if not exists %@ (",tableName];
    NSMutableArray *names =[NSMutableArray arrayWithArray:[[HLDBSqlManager defaultManger] allPropertyNameInClass:modelType]];
    for (NSDictionary *dic in names) {
        NSString *name = dic[@"name"];
        NSString *type = dic[@"type"];
        [sql appendString:[NSString stringWithFormat:@"%@ %@ ,",name,type]];
    }
    NSString *realSql = [sql substringToIndex:sql.length-1];
    realSql = [realSql stringByAppendingString:@")"];
    BOOL isSuccess = [[HLDBSqlManager defaultManger] execute:realSql];
    return isSuccess;
}

//比较两个数组,返回相同的数据
+ (NSArray *)filterSameArr:(NSArray *)arr1 andArr2:(NSArray *)arr2 {
    NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"SELF IN %@",arr2];
    return [arr1 filteredArrayUsingPredicate:filterPredicate];
}



@end

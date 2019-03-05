//
//  HLDBSqlManager.m
//  HLSqlManagerDemo
//
//  Created by cainiu on 2019/3/5.
//  Copyright © 2019 Len. All rights reserved.
//

#import "HLDBSqlManager.h"
#import <objc/runtime.h>
#import <sqlite3.h>
//#import "fun_fso.h"

#define CachePath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define DataBaseName @"consult.sqlite"

static HLDBSqlManager *dbManager;
static sqlite3 *sql3;

@implementation HLDBSqlManager

+ (instancetype)defaultManger{
    if (dbManager == nil) {
        dbManager = [HLDBSqlManager new];
    }
    return dbManager;
}

- (int)ToInt32:(NSString *)str
{
    @try {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        if (![str isKindOfClass:[NSString class]]) {
            id temp = str;
            str = [NSString stringWithFormat:@"%d",[temp intValue]];
        }
        id result = [f numberFromString:str];
        if(!result)
        {
            result = str;
        }
        return (int)[result integerValue];
    } @catch (NSException *exception) {
        return 0;
    }
}

- (int)IndexOf:(NSString *)ostr :(NSString *)sstr
{
    NSRange range = [ostr rangeOfString:sstr];
    int temp= (int)range.location;
    if(temp>[ostr length]){
        return -1;
    }else{
        return temp;
    }
}

- (NSString *)Replace:(NSString *)str :(NSString *)oldstr :(NSString *)newstr{
    if([str isEqual:nil] || [oldstr isEqual:nil] || [newstr isEqual:nil])
    {
        return  @"";
    }
    return [str stringByReplacingOccurrencesOfString:oldstr withString:newstr];
}

-(int)executeCount:(NSString *)sql{
    
    @synchronized(self){
        [self open];
        int count = 0;
        sqlite3_stmt *stmt = nil;
        int res = sqlite3_prepare(sql3, sql.UTF8String, -1, &stmt, NULL);
        if (res == SQLITE_OK) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                const char *value = (const char*)sqlite3_column_text(stmt, 0);
                count = [self ToInt32:[NSString stringWithUTF8String:value]];
            }
            sqlite3_finalize(stmt);
            [self close];
        }else {
        }
        return count;
    }
}

-(NSMutableArray *)executeNOOpenQuery:(Class)cls :(NSString *)sql{
    @synchronized(self){
        [self open];
        sqlite3_stmt *stmt = nil;
        NSMutableArray *arr = [NSMutableArray array];
        int res = sqlite3_prepare(sql3, sql.UTF8String, -1, &stmt, NULL);
        if (res == SQLITE_OK) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                int count = sqlite3_column_count(stmt);
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                for (int i = 0; i < count; i++) {
                    const char *columName = sqlite3_column_name(stmt, i);
                    const char *value = (const char*)sqlite3_column_text(stmt, i);
                    if (value!=NULL) {
                        NSString *columValue =[NSString stringWithUTF8String:value];
                        if([self IndexOf:columValue :@" +0000"]>-1)
                        {
                            columValue=[columValue stringByReplacingOccurrencesOfString:@" +0000" withString:@""];
                        }
                        [dic setObject:columValue forKey:[NSString stringWithUTF8String:columName]];
                    }else{
                        [dic setObject:@"" forKey:[NSString stringWithUTF8String:columName]];
                    }
                }
                //dic为一个字典
                [arr addObject:[self NSDictToModel:cls :dic]];
                
            }
            sqlite3_finalize(stmt);
            [self close];
            return arr;
        }else{
            return nil;
        }
        return nil;
    }
}

-(NSMutableArray *)executeQuery:(NSString *)sql{
    @synchronized(self){
        [self open];
        sqlite3_stmt *stmt = nil;
        NSMutableArray *arr = [NSMutableArray array];
        int res = sqlite3_prepare(sql3, sql.UTF8String, -1, &stmt, NULL);
        if (res == SQLITE_OK) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                int count = sqlite3_column_count(stmt);
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                for (int i = 0; i < count; i++) {
                    const char *columName = sqlite3_column_name(stmt, i);
                    const char *value = (const char*)sqlite3_column_text(stmt, i);
                    if (value!=NULL) {
                        NSString *columValue =[NSString stringWithUTF8String:value];
                        if([self IndexOf:columValue :@" +0000"]>-1)
                        {
                            columValue=[columValue stringByReplacingOccurrencesOfString:@" +0000" withString:@""];
                        }
                        [dic setObject:columValue forKey:[NSString stringWithUTF8String:columName]];
                        
                    }else{
                        [dic setObject:@"" forKey:[NSString stringWithUTF8String:columName]];
                    }
                }
                //dic为一个字典
                [arr addObject:dic];
                
            }
            sqlite3_finalize(stmt);
            [self close];
            return arr;
        }else{
            return nil;
        }
        return nil;
    }
}


-(NSMutableArray *)executeQuery:(Class)cls :(NSString *)sql{
    @synchronized(self){
        [self open];
        sqlite3_stmt *stmt = nil;
        NSMutableArray *arr = [NSMutableArray array];
        int res = sqlite3_prepare(sql3, sql.UTF8String, -1, &stmt, NULL);
        if (res == SQLITE_OK) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                int count = sqlite3_column_count(stmt);
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                for (int i = 0; i < count; i++) {
                    const char *columName = sqlite3_column_name(stmt, i);
                    const char *value = (const char*)sqlite3_column_text(stmt, i);
                    if (value!=NULL) {
                        NSString *columValue =[NSString stringWithUTF8String:value];
                        if([self IndexOf:columValue :@" +0000"]>-1)
                        {
                            columValue=[columValue stringByReplacingOccurrencesOfString:@" +0000" withString:@""];
                        }
                        [dic setObject:columValue forKey:[NSString stringWithUTF8String:columName]];
                        
                    }else{
                        [dic setObject:@"" forKey:[NSString stringWithUTF8String:columName]];
                    }
                }
                //dic为一个字典
                [arr addObject:[self NSDictToModel:cls :dic]];
                
            }
            sqlite3_finalize(stmt);
            [self close];
            return arr;
        }else{
            return nil;
        }
        return nil;
    }
}

//执行查询,查询表内某个字段的所有集合
//- (NSMutableArray *)executeOneStringArrayWithSql:(NSString *)sql
//{
//    @synchronized(self){
//        [self open];
//        sqlite3_stmt *stmt = nil;
//        NSMutableArray *arr = [NSMutableArray array];
//        int res = sqlite3_prepare(sql3, sql.UTF8String, -1, &stmt, NULL);
//        if (res == SQLITE_OK) {
//            while (sqlite3_step(stmt) == SQLITE_ROW) {
//                int count = sqlite3_column_count(stmt);
//
//                for (int i = 0; i < count; i++) {
//                    sqlite3_result_value(stmt, sqlite3_value *)
//                    const char *value = (const char*)sqlite3_column_text(stmt, i);
//                    if (value!=NULL) {
//                        NSString *columValue =[NSString stringWithUTF8String:value];
//                        if([fun_str IndexOf:columValue :@" +0000"]>-1)
//                        {
//                            columValue=[columValue stringByReplacingOccurrencesOfString:@" +0000" withString:@""];
//                        }
//                        [arr addObject:columValue];
//                    }
//                }
//            }
//            sqlite3_finalize(stmt);
//            [self close];
//            return arr;
//        }else{
//            return nil;
//        }
//        return nil;
//    }
//}

-(id)executeNOOpenQueryOne:(Class)cls :(NSString *)sql
{
    @synchronized(self){
        [self open];
        sqlite3_stmt *stmt = nil;
        int res = sqlite3_prepare(sql3, sql.UTF8String, -1, &stmt, NULL);
        if (res == SQLITE_OK) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                int count = sqlite3_column_count(stmt);
                for (int i = 0; i < count; i++) {
                    const char *columName = sqlite3_column_name(stmt, i);
                    const char *value = (const char*)sqlite3_column_text(stmt, i);
                    if (value!=NULL) {
                        NSString *columValue =[NSString stringWithUTF8String:value];
                        if([self IndexOf:columValue :@" +0000"]>-1)
                        {
                            columValue=[columValue stringByReplacingOccurrencesOfString:@" +0000" withString:@""];
                        }
                        [dic setObject:columValue forKey:[NSString stringWithUTF8String:columName]];
                    }else{
                        [dic setObject:@"" forKey:[NSString stringWithUTF8String:columName]];
                    }
                }
                //dic为一个字典
                break;
            }
            sqlite3_finalize(stmt);
            [self close];
            return [self NSDictToModel:cls :dic];
        }else{
            return nil;
        }
        return nil;
    }
}


-(id)executeQueryOne:(Class)cls :(NSString *)sql
{
    @synchronized(self){
        [self open];
        sqlite3_stmt *stmt = nil;
        int res = sqlite3_prepare(sql3, sql.UTF8String, -1, &stmt, NULL);
        if (res == SQLITE_OK) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                int count = sqlite3_column_count(stmt);
                for (int i = 0; i < count; i++) {
                    const char *columName = sqlite3_column_name(stmt, i);
                    const char *value = (const char*)sqlite3_column_text(stmt, i);
                    if (value!=NULL) {
                        NSString *columValue =[NSString stringWithUTF8String:value];
                        if([self IndexOf:columValue :@" +0000"]>-1)
                        {
                            columValue=[columValue stringByReplacingOccurrencesOfString:@" +0000" withString:@""];
                        }
                        [dic setObject:columValue forKey:[NSString stringWithUTF8String:columName]];
                    }else{
                        [dic setObject:@"" forKey:[NSString stringWithUTF8String:columName]];
                    }
                }
                //dic为一个字典
                break;
            }
            sqlite3_finalize(stmt);
            [self close];
            return [self NSDictToModel:cls :dic];
        }else{
            return nil;
        }
        
        return nil;
    }
}

//1.建表 create table if not exists 表名字（Student）
//2.插入表 insert into Student (name,age) values (@"占三",@"2")
//3.查询 select *from Student where name like
//4.修改 update Student set name = "dd" where age =10
//5.删除 delete Student where  age =10
//
//查询---插入----更新
-(BOOL)executeSql:(NSString *)sql andTag:(NSInteger)tag andModel:(id)model and:(Class)modelType and:(NSArray*)dataArray{
    @synchronized(self){
        if (tag==1) {
            //建表
            NSString *tableName=[NSString stringWithFormat:@"%@",modelType];
            
            NSMutableString *sql = [NSMutableString stringWithFormat:@"create table if not exists %@ (",tableName];
            NSMutableArray *names =[NSMutableArray arrayWithArray:[self allPropertyNameInClass:modelType]];
            for (NSDictionary *dic in names) {
                NSString *name = dic[@"name"];
                NSString *type = dic[@"type"];
                //if([name isEqualToString:@"guid"] && [type isEqualToString:@"integer"])
                //{
                //    [sql appendString:@"guid INTEGER PRIMARY KEY AUTOINCREMENT,"];
                //}
                // else
                {
                    [sql appendString:[NSString stringWithFormat:@"%@ %@ ,",name,type]];
                }
            }
            NSString *realSql = [sql substringToIndex:sql.length-1];
            realSql = [realSql stringByAppendingString:@")"];
            return [self execute:realSql];
        }else
            
            if (tag==2) {
                //查
                [self open];
                char * errorMsg = nil;
                int res = sqlite3_exec(sql3, sql.UTF8String, NULL, NULL, &errorMsg);
                if (res == SQLITE_OK) {
                } else {
                    NSLog(@"===========SQL=========== execute error: %s for sql=%@", errorMsg,sql);
                }
                sqlite3_free(errorMsg);
                [self close];
                return !res;
            }else if(tag==3){
                //插
                unsigned int count;
                Class cls=[model class];
                objc_property_t *pros = class_copyPropertyList(cls, &count);
                
                NSMutableString *keys = [NSMutableString string];
                NSMutableString *values = [NSMutableString string];
                for(int i=0;i<count;i++)
                {
                    objc_property_t property = pros[i];
                    const char* char_f =property_getName(property);
                    NSString *key =[NSString stringWithUTF8String:char_f];
                    NSString *keyx=[key lowercaseString]; //转成小写
                    
                    NSString *type = [self attrValueWithName:@"T" InProperty:pros[i]];
                    if(![keyx isEqualToString:@"guid"])
                    {
                        [keys appendFormat:@"%@,",key];
                        id value =[model valueForKey:key];
                        
                        //类型转换
                        if ([type isEqualToString:@"q"]||[type isEqualToString:@"i"]) {
                            //数字型
                            [values appendFormat:@"%@,",value];
                        }
                        else
                        {
                            //字串或日期
                            if (value == nil) {
                                [values appendFormat:@"'',"];
                            }else{
                                [values appendFormat:@"'%@',",value];
                            }
                            
                        }
                    }
                    else{
                        //if ([type isEqualToString:@"q"]||[type isEqualToString:@"i"]) {
                        //数字型 是自增 无需处理
                        // }
                        // else
                        {
                            //字串guid
                            [keys appendFormat:@"%@,",key];
                            id value =[model valueForKey:key];
                            [values appendFormat:@"'%@',",value];
                        }
                    }
                }
                
                NSString * tablename=[NSString stringWithFormat:@"%@",[model class]];
                
                
                NSString *sql;
                if(![tablename isEqual:@"(null)"])
                    
                {
                    sql = [NSString stringWithFormat:@"insert into %@(%@) values (%@)",tablename,[keys substringToIndex:keys.length -1],[values substringToIndex:values.length -1]];
                }
                
                free(pros);
                return [self execute:sql];
            }else if(tag==4){
                //更新
                unsigned int count;
                Class cls=[model class];
                objc_property_t *pros = class_copyPropertyList(cls, &count);
                
                NSMutableString *keys = [NSMutableString string];
                
                
                NSString *myidv=@"0";
                for(int i=0;i<count;i++)
                {
                    objc_property_t property = pros[i];
                    const char* char_f =property_getName(property);
                    NSString *key =[NSString stringWithUTF8String:char_f];
                    NSString *keyx=[key lowercaseString];
                    
                    NSString *type = [self attrValueWithName:@"T" InProperty:pros[i]];
                    if(![keyx isEqualToString:@"guid"])
                    {
                        [keys appendFormat:@"%@=",key];
                        id value =[model valueForKey:key];
                        
                        //Ivar ivar = class_getInstanceVariable(cls, [NSString stringWithFormat:@"_%@",key].UTF8String);
                        // id value =object_getIvar(model, ivar);
                        
                        //类型转换
                        
                        if ([type isEqualToString:@"q"]||[type isEqualToString:@"i"]) {
                            //数字型
                            [keys appendFormat:@"%@,",value];
                        }
                        else
                        {
                            //字串或日期
                            if (value == nil) {
                                [keys appendFormat:@"'',"];
                            }else{
                                [keys appendFormat:@"'%@',",value];
                            }
                            
                        }
                    }
                    else
                    {
                        //GuidID 的值
                        if ([type isEqualToString:@"q"]||[type isEqualToString:@"i"]) {
                            //数字型
                            id value =[model valueForKey:key];
                            myidv=[NSString stringWithFormat:@"%@",value];
                        }
                        else
                        {
                            id value =[model valueForKey:key];
                            myidv=[NSString stringWithFormat:@"'%@'",value];
                        }
                    }
                }
                
                NSString * tablename=[NSString stringWithFormat:@"%@",[model class]];
                NSString *sql;
                if(![tablename isEqual:@"(null)"])
                    
                {
                    sql = [NSString stringWithFormat:@"update %@ set %@",tablename,[keys substringToIndex:keys.length -1]];
                    sql=[NSString stringWithFormat:@"%@ where guid=%@",sql,myidv];
                }
                
                //  CNLog(sql);
                free(pros);
                return [self execute:sql];
                
            }else if(tag==41){
                //更新旧版本
                unsigned int count;
                Class cls=[model class];
                objc_property_t *pros = class_copyPropertyList(cls, &count);
                
                NSMutableString *keys = [NSMutableString string];
                NSString *myidv=@"0";
                for(int i=0;i<count;i++)
                {
                    objc_property_t property = pros[i];
                    const char* char_f =property_getName(property);
                    NSString *key =[NSString stringWithUTF8String:char_f];
                    if(![key isEqualToString:@"id"])
                    {
                        [keys appendFormat:@"%@=",key];
                        id value =[model valueForKey:key];
                        
                        
                        NSString *type = [self attrValueWithName:@"T" InProperty:pros[i]];
                        //类型转换
                        
                        if ([type isEqualToString:@"q"]||[type isEqualToString:@"i"]) {
                            //数字型
                            [keys appendFormat:@"%@,",value];
                        }
                        else
                        {
                            //字串或日期
                            if (value == nil) {
                                [keys appendFormat:@"'',"];
                            }else{
                                [keys appendFormat:@"'%@',",value];
                            }
                            
                        }
                    }
                    else
                    {
                        id value =[model valueForKey:key];
                        myidv=[NSString stringWithFormat:@"%@",value];
                    }
                }
                
                NSString * tablename=[NSString stringWithFormat:@"%@",[model class]];
                NSString *sql;
                if(![tablename isEqual:@"(null)"])
                    
                {
                    sql = [NSString stringWithFormat:@"update %@ set %@",tablename,[keys substringToIndex:keys.length -1]];
                    sql=[NSString stringWithFormat:@"%@ where id=%@",sql,myidv];
                }
                
                free(pros);
                return [self execute:sql];
                
            }else if(tag == 5){
                //更新
                unsigned int count;
                Class cls=[model class];
                objc_property_t *pros = class_copyPropertyList(cls, &count);
                
                NSMutableString *keys = [NSMutableString string];
                
                
                NSString *myidv=@"0";
                for(int i=0;i<count;i++)
                {
                    objc_property_t property = pros[i];
                    const char* char_f =property_getName(property);
                    NSString *key =[NSString stringWithUTF8String:char_f];
                    NSString *keyx=[key lowercaseString];
                    
                    NSString *type = [self attrValueWithName:@"T" InProperty:pros[i]];
                    if(![keyx isEqualToString:@"guid"])
                    {
                        [keys appendFormat:@"%@=",key];
                        id value =[model valueForKey:key];
                        
                        //Ivar ivar = class_getInstanceVariable(cls, [NSString stringWithFormat:@"_%@",key].UTF8String);
                        // id value =object_getIvar(model, ivar);
                        
                        //类型转换
                        
                        if ([type isEqualToString:@"q"]||[type isEqualToString:@"i"]) {
                            //数字型
                            [keys appendFormat:@"%@,",value];
                        }
                        else
                        {
                            //字串或日期
                            if (value == nil) {
                                [keys appendFormat:@"'',"];
                            }else{
                                [keys appendFormat:@"'%@',",value];
                            }
                            
                            
                        }
                    }
                    else
                    {
                        //GuidID 的值
                        if ([type isEqualToString:@"q"]||[type isEqualToString:@"i"]) {
                            //数字型
                            id value =[model valueForKey:key];
                            myidv=[NSString stringWithFormat:@"%@",value];
                        }
                        else
                        {
                            id value =[model valueForKey:key];
                            myidv=[NSString stringWithFormat:@"'%@'",value];
                        }
                    }
                }
                free(pros);
                NSString * tablename=[NSString stringWithFormat:@"%@",[model class]];
                NSString *sql;
                if(![tablename isEqual:@"(null)"]){
                    sql =[NSString stringWithFormat:@"select * from %@ where guId = %@ limit 1",tablename,myidv];
                    NSArray* result = [self executeQuery:cls :sql];
                    if (result.count==0) {
                        [self insertModel:model];
                    }else{
                        [self UpdateModel:model];
                    }
                }
                
                dataArray=nil;
                return YES;
            }else  if(tag == 6){
                
                NSMutableArray *insertArray = [NSMutableArray array];
                NSMutableArray *updateArray = [NSMutableArray array];
                NSMutableArray *seleteArray = [NSMutableArray array];
                for (int j = 0; j<dataArray.count; j++) {
                    //插
                    unsigned int count;
                    Class cls=[dataArray[j] class];
                    objc_property_t *pros = class_copyPropertyList(cls, &count);
                    
                    NSMutableArray *keyArray = [NSMutableArray array];
                    NSMutableArray *valueArray = [NSMutableArray array];
                    NSString *guid;
                    for(int i=0;i<count;i++){
                        objc_property_t property = pros[i];
                        const char* char_f =property_getName(property);
                        NSString *key =[NSString stringWithUTF8String:char_f];
                        NSString *keyx=[key lowercaseString]; //转成小写
                        
                        NSString *type = [self attrValueWithName:@"T" InProperty:pros[i]];
                        if(![keyx isEqualToString:@"guid"]){
                            [keyArray addObject:[NSString stringWithFormat:@"%@",key]];
                            id value =[dataArray[j] valueForKey:key];
                            
                            //类型转换
                            
                            if ([type isEqualToString:@"q"]||[type isEqualToString:@"i"]) {
                                //数字型
                                [valueArray addObject:value];
                                
                            }else{
                                if([value isKindOfClass:[NSString class]]&&value!=nil){
                                    //字串或日期
                                    [valueArray addObject:[NSString stringWithFormat:@"'%@'",[self Replace:value :@"'" :@"&apos;"]]];
                                }else{
                                    if (value == nil) {
                                        [valueArray addObject:[NSString stringWithFormat:@"''"]];
                                    }else{
                                        [valueArray addObject:[NSString stringWithFormat:@"'%@'",value]];
                                    }
                                }
                                
                            }
                        }else{
                            [keyArray addObject:key];
                            id value =[dataArray[j] valueForKey:key];
                            if ([type isEqualToString:@"q"]||[type isEqualToString:@"i"]) {
                                //数字型
                                [valueArray addObject:value];
                                guid = value;
                                
                            }else{
                                //字串或日期
                                if (value == nil) {
                                    [valueArray addObject:[NSString stringWithFormat:@"''"]];
                                    guid = [NSString stringWithFormat:@"''"];
                                }else{
                                    [valueArray addObject:[NSString stringWithFormat:@"'%@'",value]];
                                    guid = [NSString stringWithFormat:@"'%@'",value];
                                }
                            }
                            
                        }
                    }
                    free(pros);
                    //            NSLog(@"ddd-----%@",guid);
                    if ([guid isKindOfClass:[NSString class]]&&[guid isEqualToString:@"'(null)'"]) {
                        continue;
                    }
                    NSString * tablename=[NSString stringWithFormat:@"%@",[dataArray[j] class]];
                    //            NSLog(@"tablename-%@--%@-%@",tablename,[keyArray toString],[valueArray toString]);
                    NSString *sql;
                    if(![tablename isEqual:@"(null)"]){//插入
                        //                NSArray *keyArray = [fun_str Split:[keys substringToIndex:keys.length -1] :@","];
                        //                NSArray *valueArray = [fun_str Split:[values substringToIndex:values.length -1] :@","];
                        
                        sql = [NSString stringWithFormat:@"insert into %@(%@) values (%@)",tablename,[keyArray componentsJoinedByString:@","],[valueArray componentsJoinedByString:@","]];
                        
                        [insertArray addObject:sql];
                        
                        NSMutableString *updateFiled = [NSMutableString string];
                        for (int i=0;i<keyArray.count;i++) {
                            [updateFiled appendString:[NSString stringWithFormat:@"%@=%@,",keyArray[i],valueArray[i]]];
                        }
                        
                        sql = [NSString stringWithFormat:@"update %@ set %@ where guid = %@",tablename,[updateFiled substringToIndex:updateFiled.length-1 ],guid];
                        [updateArray addObject:sql];
                        
                        sql = [NSString stringWithFormat:@"select count(*) from %@ where guid = %@",tablename,guid];
                        [seleteArray addObject:sql];
                    }
                }
                
                
                [self execInsertTransactionSql:insertArray :updateArray :seleteArray];
                insertArray=nil;
                seleteArray=nil;
                dataArray=nil;
                return YES;
            }else{
                
                [self execSqlTransactionSql:[NSMutableArray arrayWithArray:dataArray]];
                dataArray=nil;
                return YES;
            }
    }
}



//1.建表 create table if not exists 表名字（Student）
//2.插入表 insert into Student (name,age) values (@"占三",@"2")
//3.查询 select *from Student where name like
//4.修改 update Student set name = "dd" where age =10
//5.删除 delete Student where  age =10
//6.keyStr 有些表并不是以guid为查询键,此字段可自定义查询键,不自定义传nil,默认为guid
//为了防止和之前的数据起冲突,因此不复用之前的方法
//查询---插入----更新
-(BOOL)executeSql:(NSString *)sql andTag:(NSInteger)tag andModel:(id)model and:(Class)modelType and:(NSArray*)dataArray andKeyStr:(NSString *)keyStr{
    @synchronized(self){
        if (keyStr == nil) {
            keyStr = @"guid";
        }
        if (tag==1) {
            //建表
            NSString *tableName=[NSString stringWithFormat:@"%@",modelType];
            
            NSMutableString *sql = [NSMutableString stringWithFormat:@"create table if not exists %@ (",tableName];
            NSMutableArray *names =[NSMutableArray arrayWithArray:[self allPropertyNameInClass:modelType]];
            for (NSDictionary *dic in names) {
                NSString *name = dic[@"name"];
                NSString *type = dic[@"type"];
                //if([name isEqualToString:@"guid"] && [type isEqualToString:@"integer"])
                //{
                //    [sql appendString:@"guid INTEGER PRIMARY KEY AUTOINCREMENT,"];
                //}
                // else
                {
                    [sql appendString:[NSString stringWithFormat:@"%@ %@ ,",name,type]];
                }
            }
            NSString *realSql = [sql substringToIndex:sql.length-1];
            realSql = [realSql stringByAppendingString:@")"];
            return [self execute:realSql];
        }else
            
            if (tag==2) {
                //查
                [self open];
                char * errorMsg = nil;
                int res = sqlite3_exec(sql3, sql.UTF8String, NULL, NULL, &errorMsg);
                if (res == SQLITE_OK) {
                } else {
                    NSLog(@"===========SQL=========== execute error: %s for sql=%@", errorMsg,sql);
                }
                sqlite3_free(errorMsg);
                [self close];
                return !res;
            }else if(tag==3){
                //插
                unsigned int count;
                Class cls=[model class];
                objc_property_t *pros = class_copyPropertyList(cls, &count);
                
                NSMutableString *keys = [NSMutableString string];
                NSMutableString *values = [NSMutableString string];
                for(int i=0;i<count;i++)
                {
                    objc_property_t property = pros[i];
                    const char* char_f =property_getName(property);
                    NSString *key =[NSString stringWithUTF8String:char_f];
                    NSString *keyx=[key lowercaseString]; //转成小写
                    
                    NSString *type = [self attrValueWithName:@"T" InProperty:pros[i]];
                    if(![keyx isEqualToString:keyStr])
                    {
                        [keys appendFormat:@"%@,",key];
                        id value =[model valueForKey:key];
                        
                        //类型转换
                        
                        if ([type isEqualToString:@"q"]||[type isEqualToString:@"i"]) {
                            //数字型
                            [values appendFormat:@"%@,",value];
                        }
                        else
                        {
                            //字串或日期
                            if (value == nil) {
                                [values appendFormat:@"'',"];
                            }else{
                                [values appendFormat:@"'%@',",value];
                            }
                            
                        }
                    }
                    else{
                        //if ([type isEqualToString:@"q"]||[type isEqualToString:@"i"]) {
                        //数字型 是自增 无需处理
                        // }
                        // else
                        {
                            //字串guid
                            [keys appendFormat:@"%@,",key];
                            id value =[model valueForKey:key];
                            [values appendFormat:@"'%@',",value];
                        }
                    }
                }
                
                NSString * tablename=[NSString stringWithFormat:@"%@",[model class]];
                
                
                NSString *sql;
                if(![tablename isEqual:@"(null)"])
                    
                {
                    sql = [NSString stringWithFormat:@"insert into %@(%@) values (%@)",tablename,[keys substringToIndex:keys.length -1],[values substringToIndex:values.length -1]];
                }
                
                free(pros);
                return [self execute:sql];
            }else if(tag==4){
                //更新
                unsigned int count;
                Class cls=[model class];
                objc_property_t *pros = class_copyPropertyList(cls, &count);
                
                NSMutableString *keys = [NSMutableString string];
                
                
                NSString *myidv=@"0";
                for(int i=0;i<count;i++)
                {
                    objc_property_t property = pros[i];
                    const char* char_f =property_getName(property);
                    NSString *key =[NSString stringWithUTF8String:char_f];
                    NSString *keyx=[key lowercaseString];
                    
                    NSString *type = [self attrValueWithName:@"T" InProperty:pros[i]];
                    if(![keyx isEqualToString:keyStr])
                    {
                        [keys appendFormat:@"%@=",key];
                        id value =[model valueForKey:key];
                        
                        //Ivar ivar = class_getInstanceVariable(cls, [NSString stringWithFormat:@"_%@",key].UTF8String);
                        // id value =object_getIvar(model, ivar);
                        
                        //类型转换
                        
                        if ([type isEqualToString:@"q"]||[type isEqualToString:@"i"]) {
                            //数字型
                            [keys appendFormat:@"%@,",value];
                        }
                        else
                        {
                            //字串或日期
                            if (value == nil) {
                                [keys appendFormat:@"'',"];
                            }else{
                                [keys appendFormat:@"'%@',",value];
                            }
                            
                        }
                    }
                    else
                    {
                        //GuidID 的值
                        if ([type isEqualToString:@"q"]||[type isEqualToString:@"i"]) {
                            //数字型
                            id value =[model valueForKey:key];
                            myidv=[NSString stringWithFormat:@"%@",value];
                        }
                        else
                        {
                            id value =[model valueForKey:key];
                            myidv=[NSString stringWithFormat:@"'%@'",value];
                        }
                    }
                }
                
                NSString * tablename=[NSString stringWithFormat:@"%@",[model class]];
                NSString *sql;
                if(![tablename isEqual:@"(null)"])
                    
                {
                    sql = [NSString stringWithFormat:@"update %@ set %@",tablename,[keys substringToIndex:keys.length -1]];
                    sql=[NSString stringWithFormat:@"%@ where %@=%@",sql,keyStr,myidv];
                }
                
                //  CNLog(sql);
                free(pros);
                return [self execute:sql];
                
            }else if(tag==41){
                //更新旧版本
                unsigned int count;
                Class cls=[model class];
                objc_property_t *pros = class_copyPropertyList(cls, &count);
                
                NSMutableString *keys = [NSMutableString string];
                NSString *myidv=@"0";
                for(int i=0;i<count;i++)
                {
                    objc_property_t property = pros[i];
                    const char* char_f =property_getName(property);
                    NSString *key =[NSString stringWithUTF8String:char_f];
                    if(![key isEqualToString:keyStr])
                    {
                        [keys appendFormat:@"%@=",key];
                        id value =[model valueForKey:key];
                        
                        
                        NSString *type = [self attrValueWithName:@"T" InProperty:pros[i]];
                        //类型转换
                        
                        if ([type isEqualToString:@"q"]||[type isEqualToString:@"i"]) {
                            //数字型
                            [keys appendFormat:@"%@,",value];
                        }
                        else
                        {
                            //字串或日期
                            if (value == nil) {
                                [keys appendFormat:@"'',"];
                            }else{
                                [keys appendFormat:@"'%@',",value];
                            }
                        }
                    }
                    else
                    {
                        id value =[model valueForKey:key];
                        myidv=[NSString stringWithFormat:@"%@",value];
                    }
                }
                
                NSString * tablename=[NSString stringWithFormat:@"%@",[model class]];
                NSString *sql;
                if(![tablename isEqual:@"(null)"])
                    
                {
                    sql = [NSString stringWithFormat:@"update %@ set %@",tablename,[keys substringToIndex:keys.length -1]];
                    sql=[NSString stringWithFormat:@"%@ where %@=%@",sql,myidv,keyStr];
                }
                
                free(pros);
                return [self execute:sql];
                
            }else if(tag == 5){
                //更新
                unsigned int count;
                Class cls=[model class];
                objc_property_t *pros = class_copyPropertyList(cls, &count);
                
                NSMutableString *keys = [NSMutableString string];
                
                
                NSString *myidv=@"0";
                for(int i=0;i<count;i++)
                {
                    objc_property_t property = pros[i];
                    const char* char_f =property_getName(property);
                    NSString *key =[NSString stringWithUTF8String:char_f];
                    NSString *keyx=[key lowercaseString];
                    
                    NSString *type = [self attrValueWithName:@"T" InProperty:pros[i]];
                    if(![keyx isEqualToString:keyStr])
                    {
                        [keys appendFormat:@"%@=",key];
                        id value =[model valueForKey:key];
                        
                        //Ivar ivar = class_getInstanceVariable(cls, [NSString stringWithFormat:@"_%@",key].UTF8String);
                        // id value =object_getIvar(model, ivar);
                        
                        //类型转换
                        
                        if ([type isEqualToString:@"q"]||[type isEqualToString:@"i"]) {
                            //数字型
                            [keys appendFormat:@"%@,",value];
                        }
                        else
                        {
                            //字串或日期
                            if (value == nil) {
                                [keys appendFormat:@"'',"];
                            }else{
                                [keys appendFormat:@"'%@',",value];
                            }
                        }
                    }
                    else
                    {
                        //GuidID 的值
                        if ([type isEqualToString:@"q"]||[type isEqualToString:@"i"]) {
                            //数字型
                            id value =[model valueForKey:key];
                            myidv=[NSString stringWithFormat:@"%@",value];
                        }
                        else
                        {
                            id value =[model valueForKey:key];
                            myidv=[NSString stringWithFormat:@"'%@'",value];
                        }
                    }
                }
                free(pros);
                NSString * tablename=[NSString stringWithFormat:@"%@",[model class]];
                NSString *sql;
                if(![tablename isEqual:@"(null)"]){
                    sql =[NSString stringWithFormat:@"select * from %@ where %@ = %@ limit 1",tablename,keyStr,myidv];
                    NSArray* result = [self executeQuery:cls :sql];
                    if (result.count==0) {
                        [self insertModel:model];
                    }else{
                        [self UpdateModel:model keyStr:keyStr];
                    }
                }
                
                dataArray=nil;
                return YES;
            }else  if(tag == 6){
                
                NSMutableArray *insertArray = [NSMutableArray array];
                NSMutableArray *updateArray = [NSMutableArray array];
                NSMutableArray *seleteArray = [NSMutableArray array];
                for (int j = 0; j<dataArray.count; j++) {
                    //插
                    unsigned int count;
                    Class cls=[dataArray[j] class];
                    objc_property_t *pros = class_copyPropertyList(cls, &count);
                    
                    NSMutableArray *keyArray = [NSMutableArray array];
                    NSMutableArray *valueArray = [NSMutableArray array];
                    NSString *guid;
                    for(int i=0;i<count;i++){
                        objc_property_t property = pros[i];
                        const char* char_f =property_getName(property);
                        NSString *key =[NSString stringWithUTF8String:char_f];
                        NSString *keyx=[key lowercaseString]; //转成小写
                        
                        NSString *type = [self attrValueWithName:@"T" InProperty:pros[i]];
                        if(![keyx isEqualToString:keyStr]){
                            [keyArray addObject:[NSString stringWithFormat:@"%@",key]];
                            id value =[dataArray[j] valueForKey:key];
                            
                            //类型转换
                            
                            if ([type isEqualToString:@"q"]||[type isEqualToString:@"i"]) {
                                //数字型
                                [valueArray addObject:value];
                                
                            }else{
                                if([value isKindOfClass:[NSString class]]&&value!=nil){
                                    //字串或日期
                                    [valueArray addObject:[NSString stringWithFormat:@"'%@'",[self Replace:value :@"'" :@"&apos;"]]];
                                }else{
                                    if (value == nil) {
                                        [valueArray addObject:[NSString stringWithFormat:@"''"]];
                                    }else{
                                        [valueArray addObject:[NSString stringWithFormat:@"'%@'",value]];
                                    }
                                    
                                }
                                
                            }
                        }else{
                            [keyArray addObject:key];
                            id value =[dataArray[j] valueForKey:key];
                            if ([type isEqualToString:@"q"]||[type isEqualToString:@"i"]) {
                                //数字型
                                [valueArray addObject:value];
                                guid = value;
                                
                            }else{
                                //字串或日期
                                if (value == nil) {
                                    [valueArray addObject:[NSString stringWithFormat:@"''"]];
                                    guid = [NSString stringWithFormat:@"''"];
                                }else{
                                    [valueArray addObject:[NSString stringWithFormat:@"'%@'",value]];
                                    guid = [NSString stringWithFormat:@"'%@'",value];
                                }
                                
                                
                            }
                            
                        }
                    }
                    free(pros);
                    //            NSLog(@"ddd-----%@",guid);
                    if ([guid isKindOfClass:[NSString class]]&&[guid isEqualToString:@"'(null)'"]) {
                        continue;
                    }
                    NSString * tablename=[NSString stringWithFormat:@"%@",[dataArray[j] class]];
                    //            NSLog(@"tablename-%@--%@-%@",tablename,[keyArray toString],[valueArray toString]);
                    NSString *sql;
                    if(![tablename isEqual:@"(null)"]){//插入
                        //                NSArray *keyArray = [fun_str Split:[keys substringToIndex:keys.length -1] :@","];
                        //                NSArray *valueArray = [fun_str Split:[values substringToIndex:values.length -1] :@","];
                        
                        sql = [NSString stringWithFormat:@"insert into %@(%@) values (%@)",tablename,[keyArray componentsJoinedByString:@","],[valueArray componentsJoinedByString:@","]];
                        
                        [insertArray addObject:sql];
                        
                        NSMutableString *updateFiled = [NSMutableString string];
                        for (int i=0;i<keyArray.count;i++) {
                            [updateFiled appendString:[NSString stringWithFormat:@"%@=%@,",keyArray[i],valueArray[i]]];
                        }
                        
                        sql = [NSString stringWithFormat:@"update %@ set %@ where %@ = %@",tablename,[updateFiled substringToIndex:updateFiled.length-1 ],keyStr,guid];
                        [updateArray addObject:sql];
                        
                        sql = [NSString stringWithFormat:@"select count(*) from %@ where %@ = %@",tablename,keyStr,guid];
                        [seleteArray addObject:sql];
                    }
                }
                
                
                [self execInsertTransactionSql:insertArray :updateArray :seleteArray];
                insertArray=nil;
                seleteArray=nil;
                dataArray=nil;
                return YES;
            }else{
                
                [self execSqlTransactionSql:[NSMutableArray arrayWithArray:dataArray]];
                dataArray=nil;
                return YES;
            }
    }
}

//tag=1;建表
-(BOOL)createTabel:(Class)modelType{
    return [self executeSql:nil andTag:1 andModel:nil and:modelType and:nil];
}
//tag=2;查询
-(BOOL)execute:(NSString *)sql{
    return [self executeSql:sql andTag:2 andModel:nil and:nil and:nil];
}

//tag=3;插入
-(BOOL)insertModel:(id)model
{
    return [self executeSql:nil andTag:3 andModel:model and:nil and:nil];
}

//tag=5;插入或者更新
-(BOOL)insertOrReplaceModel:(id)model{
    
    return [self executeSql:nil andTag:5 andModel:model and:nil and:nil];
}

//与insertOrReplaceModel方法不同的是并不是以Guid作为查询键,自定义查询键(eg:s_id)
-(BOOL)insertOrReplaceModel:(id)model keyStr:(NSString *)keyStr
{
    return [self executeSql:nil andTag:5 andModel:model and:nil and:nil andKeyStr:keyStr];
}

//tag=4;更新
-(BOOL)UpdateModel:(id)model
{
    return [self executeSql:nil andTag:4 andModel:model and:nil and:nil];
}
-(BOOL)UpdateModel:(id)model keyStr:(NSString *)keyStr
{
    return [self executeSql:nil andTag:4 andModel:model and:nil and:nil andKeyStr:keyStr];
}
//tag=41;更新旧版本
-(BOOL)UpdateOldModel:(id)model
{
    return [self executeSql:nil andTag:41 andModel:model and:nil and:nil];
}
//tag=6;批量插入
-(BOOL)insertArray:(NSArray*)array
{
    if (array.count>0) {
        return [self executeSql:nil andTag:6 andModel:nil and:nil and:array];
    }else{
        return YES;
    }
}

//tag=7;批量执行sql
-(BOOL)executeSqlArray:(NSArray*)array
{
    return [self executeSql:nil andTag:7 andModel:nil and:nil and:array];
}


//********************************************* 本类辅助函数 ***************************************//

- (NSString *)pathFileName
{
    if (!_pathFileName) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _pathFileName = [[paths objectAtIndex:0] stringByAppendingPathComponent:DataBaseName];
        NSLog(@"===========SQL=========== path=.....%@",_pathFileName);
    }
    return _pathFileName;
}


-(BOOL)open{
    /*
     NSString *fileName = [CachePath stringByAppendingPathComponent:DataBaseName];
     CNLog(@"path=%@",fileName);
     */
    return sqlite3_open_v2(self.pathFileName.UTF8String, &sql3, SQLITE_OPEN_READWRITE|SQLITE_OPEN_CREATE, NULL);
    //    return sqlite3_open(self.pathFileName.UTF8String, &sql3);//与以上方法等同
    
}

-(BOOL)close{
    if (sql3 == NULL || sql3 == nil) {
        return NO;
    }
    return !sqlite3_close(sql3);
}
//字典与对象的转换函数
//对象转换为字典
-(NSDictionary*)DictionaryFromModel:(id)model{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    Class modelClass = object_getClass(model);
    unsigned int count = 0;
    objc_property_t *pros = class_copyPropertyList(modelClass, &count);
    
    for (int i = 0; i < count; i++) {
        objc_property_t pro = pros[i];
        NSString *name = [NSString stringWithFormat:@"%s", property_getName(pro)] ;
        id value = [model valueForKey:name];
        if (value !=nil) {
            [dic setObject:value forKey:name];
        }
    }
    free(pros);
    return dic;
}
//********************************************* 属性动态解析部分 ***************************************//
//Runtime辅助函数解析类的属性特征等行为
//获取属性的特征值
-(NSString*)attrValueWithName:(NSString*)name InProperty:(objc_property_t)pro{
    unsigned int count = 0;
    objc_property_attribute_t *attrs = property_copyAttributeList(pro, &count);
    for (int i = 0; i < count; i++) {
        objc_property_attribute_t attr = attrs[i];
        if (strcmp(attr.name, name.UTF8String) == 0) {
            free(attrs);
            return [NSString stringWithUTF8String:attr.value];
        }
    }
    free(attrs);
    return nil;
}

//获取属性的值
-(id)valueOfproperty:(objc_property_t)pro cls:(Class)cls{
    Ivar ivar = class_getInstanceVariable(cls, [self attrValueWithName:@"V" InProperty:pro].UTF8String);
    return object_getIvar(cls, ivar);
}

//获取类的所有属性名称与类型
-(NSArray *)allPropertyNameInClass:(Class)cls{
    NSMutableArray *arr = [NSMutableArray array];
    unsigned int count;
    objc_property_t *pros = class_copyPropertyList(cls, &count);
    for (int i = 0; i < count; i++) {
        NSString *name =[NSString stringWithFormat:@"%s",property_getName(pros[i])];
        NSString *type = [self attrValueWithName:@"T" InProperty:pros[i]];
        //类型转换
        //  CNLog(@"name=%@   type=%@",name,type);
        if ([type isEqualToString:@"q"]||[type isEqualToString:@"i"]) {
            type = @"integer";
        }else if([type isEqualToString:@"f"] || [type isEqualToString:@"d"]){
            type = @"REAL";
        }
        else if([self IndexOf:type :@"Date"]>-1)
        {
            type = @"DateTime";
            
        }else{
            type = @"text";
        }
        NSDictionary *dic = @{@"name":name,@"type":type};
        [arr addObject:dic];
    }
    free(pros);
    return arr;
}

//获取类的所有属性名称
- (NSArray *)getAllPropertyNamesWithClass:(Class)className{
    NSMutableArray *allNames = [NSMutableArray array];
    unsigned int propertyCount = 0;
    objc_property_t *propertyArray = class_copyPropertyList(className, &propertyCount);
    for (int i = 0; i < propertyCount; i++) {
        objc_property_t property = propertyArray[i];
        const char *propertyName = property_getName(property);
        [allNames addObject:[NSString stringWithUTF8String:propertyName]];
    }
    free(propertyArray);
    return allNames;
}

//字典转成实体
-(id) NSDictToModel :(Class)cls :(NSDictionary *)model
{
    //导入才牛工具类后此处判断需要去掉
    //    if (model == nil || model.allKeys.count == 0) {
    //        return nil;
    //    }
    
    unsigned int count;
    id cs = [[cls alloc] init];
    objc_property_t *pros = class_copyPropertyList(cls, &count);
    for(int i=0;i<count;i++)
    {
        NSString *name =[NSString stringWithFormat:@"%s",property_getName(pros[i])];
        for (int j=0; j<model.allKeys.count; j++) {
            NSString *key = model.allKeys[j];
            if([key isEqualToString:name])
            {
                NSString *value = model.allValues[j];
                [cs setValue:value forKey:key];
            }
        }
    }
    free(pros);
    return cs;
}

-(void)execInsertTransactionSql:(NSMutableArray *)insertSql :(NSMutableArray*)updateSql :(NSMutableArray*)selectSql{
    //使用事务，提交插入sql语句sqlite3_exec(sql3, sql.UTF8String, NULL, NULL, &errorMsg);
    @try{
        char *errorMsg = nil;
        //        int a = sqlite3_exec(sql3,"BEGIN TRANSACTION;",NULL,NULL,NULL);
        [self open];
        if (sqlite3_exec(sql3, "BEGIN;", NULL, NULL, &errorMsg)==SQLITE_OK){
            NSLog(@"启动事务成功");
            sqlite3_free(errorMsg);
            sqlite3_stmt *statement;
            for (int i = 0;i<insertSql.count; i++){
                
                int count = 0;
                sqlite3_stmt *stmt = nil;
                int res = sqlite3_prepare(sql3, [selectSql[i] UTF8String], -1, &stmt, NULL);
                if (res == SQLITE_OK) {
                    while (sqlite3_step(stmt) == SQLITE_ROW) {
                        const char *value = (const char*)sqlite3_column_text(stmt, 0);
                        count = [self ToInt32:[NSString stringWithUTF8String:value]];
                    }
                } else {
                    
                }
                if(count>0){
                    if (sqlite3_prepare_v2(sql3,[[updateSql objectAtIndex:i] UTF8String], -1, &statement,NULL)==SQLITE_OK){
                        if (sqlite3_step(statement)!=SQLITE_DONE) sqlite3_finalize(statement);
                    }
                }else{
                    if (sqlite3_prepare_v2(sql3,[[insertSql objectAtIndex:i] UTF8String], -1, &statement,NULL)==SQLITE_OK){
                        if (sqlite3_step(statement)!=SQLITE_DONE) sqlite3_finalize(statement);
                    }
                }
                
                
            }
            
            if (sqlite3_exec(sql3, "COMMIT;", NULL, NULL, &errorMsg)==SQLITE_OK)   NSLog(@"提交事务成功");
            sqlite3_free(errorMsg);
        }
        else sqlite3_free(errorMsg);
    }@catch(NSException *e){
        char *errorMsg;
        if (sqlite3_exec(sql3, "ROLLBACK;", NULL, NULL, &errorMsg)==SQLITE_OK)  NSLog(@"回滚事务成功");
        sqlite3_free(errorMsg);
    }@finally{
        [self close];
    }
}

#pragma mark - 事务批量执行
-(void)execSqlTransactionSql:(NSMutableArray *)sqlArray{
    //使用事务，提交插入sql语句sqlite3_exec(sql3, sql.UTF8String, NULL, NULL, &errorMsg);
    @try{
        char *errorMsg = nil;
        //        int a = sqlite3_exec(sql3,"BEGIN TRANSACTION;",NULL,NULL,NULL);
        [self open];
        if (sqlite3_exec(sql3, "BEGIN;", NULL, NULL, &errorMsg)==SQLITE_OK){
            NSLog(@"启动事务成功");
            sqlite3_free(errorMsg);
            sqlite3_stmt *statement;
            for (int i = 0;i<sqlArray.count; i++){
                if (sqlite3_prepare_v2(sql3,[[sqlArray objectAtIndex:i] UTF8String], -1, &statement,NULL)==SQLITE_OK){
                    if (sqlite3_step(statement)!=SQLITE_DONE) sqlite3_finalize(statement);
                }
            }
            if (sqlite3_exec(sql3, "COMMIT;", NULL, NULL, &errorMsg)==SQLITE_OK)   NSLog(@"提交事务成功");
            sqlite3_free(errorMsg);
        }
        else sqlite3_free(errorMsg);
    }@catch(NSException *e){
        char *errorMsg;
        if (sqlite3_exec(sql3, "ROLLBACK;", NULL, NULL, &errorMsg)==SQLITE_OK)  NSLog(@"回滚事务成功");
        sqlite3_free(errorMsg);
    }@finally{
        [self close];
    }
}

/** 判断某个表是否存在某个字段 */
- (BOOL)checkHasSqlNameWithTableName:(NSString *)tableName sqlName:(NSString *)sqlName{
    @synchronized(self){
        NSString *sql = [NSString stringWithFormat:@"select * from sqlite_master where name='%@' and sql like '%@'",tableName,sqlName];
        int count = [self executeCount:sql];
        if (count > 0) {
            return YES;
        }else{
            return NO;
        }
    };
}


@end

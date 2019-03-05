//
//  HLDBSqlManager.h
//  HLSqlManagerDemo
//
//  Created by cainiu on 2019/3/5.
//  Copyright © 2019 Len. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLDBSqlManager : NSObject

/** 数据库路径 */
@property (nonatomic, copy) NSString *pathFileName;

+(instancetype)defaultManger;

/**
  *  使用实体类型进行自动建表
  *
  *  @param modelType 实体类型 用于自动检索实体的属性
  *
  *  @return 返回bool
  */
-(BOOL)createTabel:(Class)modelType;
/**
  *  增删改语句通用执行方法
  *
  *  @param sql 传入sql语句
  *
  *  @return 返回bool值
  */
-(BOOL)execute:(NSString*)sql;

/**
  *  执行查询
  *
 
  *  @return 返回 数组<字典> 字典的键与数据库字段名相同
  */
-(NSMutableArray *)executeQuery:(Class)cls :(NSString *)sql;

/**
  *  得到一条记录的实体
  *
  *  @sql 为指领
  *
  *  @return 返回一个实体
  */
-(id)executeQueryOne:(Class)cls :(NSString *)sql;

/**
  *  插入一个实体对象到某一张表
  *
  *  model     实体对象
  *
  *  @return 返回bool值
  */
-(BOOL)insertModel:(id)model;
/**
  *  更新一个实体对象到某一张表
  *
  *
  *  @return 返回bool值
  */
-(BOOL)UpdateModel:(id)model;
-(BOOL)UpdateModel:(id)model keyStr:(NSString *)keyStr;

//tag=41;更新旧版本
-(BOOL)UpdateOldModel:(id)model;

/**
  *  执行sql,返回记录数
  *
  *
  *  @return 返回bool值
  */
-(int)executeCount:(NSString *)sql;

//tag=6;批量插入
-(BOOL)insertArray:(NSArray*)array;

//tag=7;批量执行sql
-(BOOL)executeSqlArray:(NSArray*)array;

-(BOOL)insertOrReplaceModel:(id)model;

//与insertOrReplaceModel方法不同的是并不是以Guid作为查询键,自定义查询键(eg:s_id)
-(BOOL)insertOrReplaceModel:(id)model keyStr:(NSString *)keyStr;

-(NSMutableArray *)executeNOOpenQuery:(Class)cls :(NSString *)sql;
-(NSMutableArray *)executeQuery:(NSString *)sql;
-(id)executeNOOpenQueryOne:(Class)cls :(NSString *)sql;

////执行查询,查询表内某个字段的所有集合
//- (NSMutableArray *)executeOneStringArrayWithSql:(NSString *)sql;

-(BOOL)open;
-(BOOL)close;

/** 判断某个表是否存在某个字段 */
- (BOOL)checkHasSqlNameWithTableName:(NSString *)tableName sqlName:(NSString *)sqlName;

/** 获取类的所有属性名称与类型 */
- (NSArray *)allPropertyNameInClass:(Class)cls;

/** 获取类的所有属性名称 */
- (NSArray *)getAllPropertyNamesWithClass:(Class)className;

@end

NS_ASSUME_NONNULL_END

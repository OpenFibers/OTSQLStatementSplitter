//
//  OTSQLSplittedStatement.h
//  OTSQLStatementSplitter
//
//  Created by openthread on 3/5/14.
//  Copyright (c) 2014 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTSQLSplittedStatement : NSObject
@property (nonatomic, retain) NSString *statementString;//statement string
@end

@interface OTSQLStatementSplitter : NSObject

+ (instancetype)sharedInstance;

- (NSArray *)statementsFromBatchSqlStatement:(NSString *)batchStatement;

@end

//
//  OTSQLSplittedStatement.m
//  OTSQLStatementSplitter
//
//  Created by openthread on 3/5/14.
//  Copyright (c) 2014 openthread. All rights reserved.
//

#import "OTSQLStatementSplitter.h"
#import "OTSQLStatementSplitterKeywordRecogniser.h"
#import "OTSQLStatementSplitterQuotedRecogniser.h"
#import "OTSQLStatementSplitterMacros.h"

@implementation OTSQLSplittedStatement

- (NSString *)description
{
    NSString *description = [super description];
    description = [description stringByAppendingFormat:@" %@", self.statementString];
    return description;
}

@end

@implementation OTSQLStatementSplitter
{
    NSMutableArray *_tokenRecognisers;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _tokenRecognisers = [NSMutableArray array];
        OTSQLStatementSplitterRetain(_tokenRecognisers);
        
        //' quote
        OTSQLStatementSplitterQuotedRecogniser *singleQuoteRecogniser = nil;
        singleQuoteRecogniser = [OTSQLStatementSplitterQuotedRecogniser quotedRecogniserWithStartQuote:@"'"
                                                                         endQuote:@"'"
                                                                   escapeSequence:@"\\"
                                                                             name:@"SingleQuote"];
        singleQuoteRecogniser.shouldQuoteEscapeSequence = YES;
        [_tokenRecognisers addObject:singleQuoteRecogniser];
        
        //" quote
        OTSQLStatementSplitterQuotedRecogniser *doubleQuoteRecogniser = nil;
        doubleQuoteRecogniser = [OTSQLStatementSplitterQuotedRecogniser quotedRecogniserWithStartQuote:@"\""
                                                                     endQuote:@"\""
                                                               escapeSequence:@"\\"
                                                                         name:@"DoubleQuote"];
        
        doubleQuoteRecogniser.shouldQuoteEscapeSequence = NO;
        [_tokenRecognisers addObject:doubleQuoteRecogniser];
        
        //` quote
        OTSQLStatementSplitterQuotedRecogniser *sqlashQuoteRecogniser = nil;
        sqlashQuoteRecogniser = [OTSQLStatementSplitterQuotedRecogniser quotedRecogniserWithStartQuote:@"`"
                                                                          endQuote:@"`"
                                                                    escapeSequence:@"\\"
                                                                              name:@"SqlashQuote"];
        sqlashQuoteRecogniser.shouldQuoteEscapeSequence = NO;
        [_tokenRecognisers addObject:sqlashQuoteRecogniser];
        
        //; recognizer
        NSArray *operatorKeywords = @[@";"];
        [_tokenRecognisers addObject:[OTSQLStatementSplitterKeywordRecogniser recogniserForKeywords:operatorKeywords]];
    }
    return self;
}

- (void)dealloc
{
    OTSQLStatementSplitterRelease(_tokenRecognisers);
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

+ (instancetype)sharedInstance
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


- (NSArray *)statementsFromBatchSqlStatement:(NSString *)input;
{
    NSUInteger currentTokenOffset = 0;
    NSUInteger inputLength = [input length];
    NSArray *recs = _tokenRecognisers;
    NSScanner *scanner = [NSScanner scannerWithString:input];

    NSMutableArray *resultArray = [NSMutableArray array];
    NSUInteger lastSplitterLocation = 0;

    while (currentTokenOffset < inputLength)
    {
        @autoreleasepool
        {
            BOOL recognised = NO;
            for (NSUInteger i = 0; i < recs.count; i++)
            {
                id<OTSQLStatementSplitterTokenRecogniser> recogniser = recs[i];
                NSRange range = [recogniser recogniseRangeWithScanner:scanner currentTokenPosition:&currentTokenOffset];
                if (NSNotFound != range.location)
                {
                    if (i == 3)//Recognised ; keyword
                    {
                        OTSQLSplittedStatement *statement = [[OTSQLSplittedStatement alloc] init];
                        statement.statementString = [input substringWithRange:NSMakeRange(lastSplitterLocation, currentTokenOffset - lastSplitterLocation)];
                        lastSplitterLocation = currentTokenOffset;
                        [resultArray addObject:statement];
                        OTSQLStatementSplitterRelease(statement);
                   }
                    recognised = YES;
                    break;
                }
            }
            
            if (!recognised)
            {
                currentTokenOffset ++;
            }
            
            if (currentTokenOffset == inputLength && lastSplitterLocation != inputLength)
                //input comes to end, put all string remaining to the last statement
            {
                OTSQLSplittedStatement *statement = [[OTSQLSplittedStatement alloc] init];
                statement.statementString = [input substringWithRange:NSMakeRange(lastSplitterLocation, currentTokenOffset - lastSplitterLocation)];
                lastSplitterLocation = currentTokenOffset;
                [resultArray addObject:statement];
                OTSQLStatementSplitterRelease(statement);
            }
        }
    }
    
    return [NSArray arrayWithArray:resultArray];
}

+ (void)test
{
    NSArray *statementStringArray = @[
    @"SELECT TABLE IF EXISTS ';' `web_offline_track`;",
    @"select TABLE IF NOT EXISTS \";\" `web_offline_track` (`id` VARCHAR(40) NOT NULL, `type` INT NULL, `type_extra` BIGINT NULL, `track_id` BIGINT NULL, `detail` TEXT NULL, `size` INT NULL, `dfsid` BIGINT NULL, `bitrate` INT NULL, `state` INT NULL, `download_time` INT NULL, `complete_time` INT NULL, `sou;rce_href` TEXT NULL, `source_text` TEXT NULL, `source_extra` TEXT NULL, `album_id` VARCHAR(40) NULL, `relative_path` TEXT NULL, `track_name` TEXT NULL, `artist_name` TEXT NULL, `album_name` TEXT NULL, PRIMARY KEY (`id`));",
    @"create TABLE select IF EXISTS `web_playl;ist_order`;",
    @"select TABLE IF NOT EXISTS `web_playlist_order` (`playlist_id` BIGINT NOT NULL, `field` VARCHAR(40) NULL, `order` VARCHAR(40) NULL, PRIMARY KEY select (`playlist_SELECTid`));",
    @"'\\\\';",
    @"'blah blah"];
    
    NSMutableString *batchStatement = [NSMutableString string];
    for (NSString *str in statementStringArray)
    {
        [batchStatement appendString:str];
    }
    
    //Result
    NSArray *statements = [[OTSQLStatementSplitter sharedInstance] statementsFromBatchSqlStatement:batchStatement];
    NSLog(@"%@ test with parsed result: %@",[super description], statements);
    
    //counts
    NSLog(@"statement count :%lu expected %lu.",
          (unsigned long)statements.count,
          (unsigned long)statementStringArray.count);
    
    //single statement
    for (NSUInteger i = 0; i<statementStringArray.count && i<statements.count; i++)
    {
        NSLog(@"statement check successed : %d", [statementStringArray[i] isEqualToString:((OTSQLSplittedStatement *)statements[i]).statementString]);
    }
}

//+ (void)load
//{
//    [super load];
//    [self test];
//}

@end

#OTStatementSplitter

Cut batch sql statement into single ones.

Here is a batch statement:

```
    NSString *batchStatement =
    @"SELECT TABLE IF EXISTS ';' `web_offline_track`;"
    @"select TABLE IF NOT EXISTS \";\" `web_offline_track` (`id` VARCHAR(40) NOT NULL, `type` INT NULL, `type_extra` BIGINT NULL, `track_id` BIGINT NULL, `detail` TEXT NULL, `size` INT NULL, `dfsid` BIGINT NULL, `bitrate` INT NULL, `state` INT NULL, `download_time` INT NULL, `complete_time` INT NULL, `sou;rce_href` TEXT NULL, `source_text` TEXT NULL, `source_extra` TEXT NULL, `album_id` VARCHAR(40) NULL, `relative_path` TEXT NULL, `track_name` TEXT NULL, `artist_name` TEXT NULL, `album_name` TEXT NULL, PRIMARY KEY (`id`));"
    @"create TABLE select IF EXISTS `web_playl;ist_order`;"
    @"select TABLE IF NOT EXISTS `web_playlist_order` (`playlist_id` BIGINT NOT NULL, `field` VARCHAR(40) NULL, `order` VARCHAR(40) NULL, PRIMARY KEY select (`playlist_SELECTid`));"
    @"'\\\\';"
    @"'blah blah";
```

Let's cut it into single ones:

```
    NSArray *statements = [[OTSQLStatementSplitter sharedInstance] statementsFromBatchSqlStatement:batchStatement];
```

Read from splitted statements:

```
    for (OTSQLSplittedStatement *statement in statements)
    {
        NSString *splittedStatement = statement.statementString;
        //Do something with `splittedStatement`
    }
```

Lisence:
MIT
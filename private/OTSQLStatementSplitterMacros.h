//
//  OTSQLStatementSplitterMacros.h
//  1
//
//  Created by openfibers on 28/5/14.
//  Copyright (c) 2014 1111. All rights reserved.
//

#ifndef __OTSQLStatementSplitterMacros_h
#define __OTSQLStatementSplitterMacros_h

#if ! __has_feature(objc_arc)
    #define OTSQLStatementSplitterAutorelease(__v) ([__v autorelease]);
    #define OTSQLStatementSplitterReturnAutoreleased OTSQLStatementSplitterAutorelease

    #define OTSQLStatementSplitterRetain(__v) ([__v retain]);
    #define OTSQLStatementSplitterReturnRetained OTSQLStatementSplitterRetain

    #define OTSQLStatementSplitterRelease(__v) ([__v release]);

    #define OTSQLStatementSplitterDispatchQueueRelease(__v) (dispatch_release(__v));
#else
    // -fobjc-arc
    #define OTSQLStatementSplitterAutorelease(__v)
    #define OTSQLStatementSplitterReturnAutoreleased(__v) (__v)

    #define OTSQLStatementSplitterRetain(__v)
    #define OTSQLStatementSplitterReturnRetained(__v) (__v)

    #define OTSQLStatementSplitterRelease(__v)

    // If OS_OBJECT_USE_OBJC=1, then the dispatch objects will be treated like ObjC objects
    // and will participate in ARC.
    // See the section on "Dispatch Queues and Automatic Reference Counting" in "Grand Central Dispatch (GCD) Reference" for details.
    #if OS_OBJECT_USE_OBJC
        #define OTSQLStatementSplitterDispatchQueueRelease(__v)
    #else
        #define OTSQLStatementSplitterDispatchQueueRelease(__v) (dispatch_release(__v));
    #endif
#endif

#endif

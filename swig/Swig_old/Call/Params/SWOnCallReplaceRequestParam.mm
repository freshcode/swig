//
//  SWOnCallReplaceRequestParam.m
//  swig
//
//  Created by Pierre-Marc Airoldi on 2014-08-19.
//  Copyright (c) 2014 PeteAppDesigns. All rights reserved.
//

#import "SWOnCallReplaceRequestParam.h"

@implementation SWOnCallReplaceRequestParam

+(instancetype)onParamFromParam:(pj::OnCallReplaceRequestParam)param {
    
    return [SWOnCallReplaceRequestParam new];
}

@end
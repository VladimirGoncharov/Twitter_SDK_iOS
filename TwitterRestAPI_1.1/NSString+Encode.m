//
//  NSString+Encode.m
//  TwitterRestAPI_1.1
//
//  Created by admin on 24.09.13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import "NSString+Encode.h"

@implementation NSString (Encode)

- (NSString *)stringByAddingPercentEscapes
{
    return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]{}", kCFStringEncodingUTF8));
}

@end

////////////////////////////////////////////////////////////////////////////////
//
//  TYPHOON FRAMEWORK
//  Copyright 2013, Jasper Blues & Contributors
//  All Rights Reserved.
//
//  NOTICE: The authors permit you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

#import "NSNullTypeConverter.h"

@implementation NSNullTypeConverter

- (id)supportedType
{
    return [NSNull class];
}

- (id)convert:(NSString *)stringValue
{
    return [NSNull null];
}

@end

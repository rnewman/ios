//
//  Foo.m
//  FxA
//
//  Created by Richard Newman on 2014-09-22.
//  Copyright (c) 2014 Mozilla. All rights reserved.
//

#import "Foo.h"

@implementation Foo

- (instancetype) init {
    NSLog(@"Inited Foo instance.");
    self = [super init];
    return self;
}

@end

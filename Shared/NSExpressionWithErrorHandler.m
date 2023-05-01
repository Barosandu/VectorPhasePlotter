//
//  NSExpressionWithErrorHandler.m
//  Vector Phase Plotter
//
//  Created by Alexandru Ariton on 24.06.2021.
//

#import <Foundation/Foundation.h>
#import "NSExpressionWithErrorHandler.h"
@implementation NSExpressionWithErrorHandler
@synthesize format;
@synthesize errorOfFormat;

- (instancetype)initWithFormat:(NSString *)frmt {
    self = [super init];
    if (self) {
        self.format = frmt;
        self.errorOfFormat = @"No error";
    }
    @try {
        NSExpression* expression = [NSExpression expressionWithFormat:frmt];
        NSString * frmt2 = [[[frmt stringByReplacingOccurrencesOfString:@"x" withString:@"1.1"]stringByReplacingOccurrencesOfString:@"y" withString:@"2.1"]stringByReplacingOccurrencesOfString:@"z" withString:@"0.1"];
        NSExpression* expression2 = [NSExpression expressionWithFormat:frmt2];
        id value = [expression2 expressionValueWithObject:nil context:nil];
    } @catch (NSException *exception) {
        NSLog(@"Error");
        
        self.errorOfFormat = [NSString stringWithFormat:@"%@", [exception description]];
        
        
    } @finally {
        NSLog(@"Finally");
        NSLog(self.errorOfFormat);
    }
    return self;
}

- (NSString *)getError {
    return self.errorOfFormat;
}
@end

//
//  NSExpressionWithErrorHandler.h
//  Vector Phase Plotter
//
//  Created by Alexandru Ariton on 24.06.2021.
//

#ifndef NSExpressionWithErrorHandler_h
#define NSExpressionWithErrorHandler_h
#import <Foundation/Foundation.h>

@interface NSExpressionWithErrorHandler : NSObject
@property(strong, nonatomic) NSString * format;
@property(strong, nonatomic) NSString * errorOfFormat;
- (instancetype)initWithFormat:(NSString *) frmt;
- (NSString *)getError;
@end
#endif /* NSExpressionWithErrorHandler_h */

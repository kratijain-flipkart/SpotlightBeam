//
//  SpotlightErrors.m
//  Pods
//
//  Created by Krati Jain on 16/12/15.
//
//

#import "SpotlightErrors.h"

@implementation SpotlightErrors

NSString *const CS_ERROR_DOMAIN = @"com.flipkart.spotlightBeam.errorDomain";

+(NSError *)prepareErrorWithCode:(int)errorCode andErrorObject:(id)errorObject forKey:(NSString *)key{
    
    NSMutableDictionary *userInfoDict = [[NSMutableDictionary alloc]init];
    [userInfoDict setObject:errorObject forKey:key];
    
    return [NSError errorWithDomain:CS_ERROR_DOMAIN code:InvalidDomainIdError userInfo:userInfoDict];
}
@end

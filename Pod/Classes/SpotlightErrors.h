//
//  SpotlightErrors.h
//  Pods
//
//  Created by Krati Jain on 16/12/15.
//
//

#import <Foundation/Foundation.h>

@interface SpotlightErrors : NSObject

extern NSString *const CS_ERROR_DOMAIN ;
enum {
    InvalidIndexDictionaryError,
    InvalidUniqueIdError,
    InvalidDomainIdError,
    InvalidBulkIndicesArrayError,
    InvalidActionError
};

+(NSError *)prepareErrorWithCode:(int)errorCode andErrorObject:(id)errorObject forKey:(NSString *)key;
@end

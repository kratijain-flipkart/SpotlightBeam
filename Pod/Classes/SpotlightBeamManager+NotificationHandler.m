//
//  SpotlightBeamManager+NotificationHandler.m
//  Pods
//
//  Created by Krati Jain on 16/12/15.
//
//

#import "SpotlightBeamManager+NotificationHandler.h"
#import "SpotlightErrors.h"
#import "SpotlightBeamConstants.h"
#import <CoreSpotlight/CoreSpotlight.h>
#import <MobileCoreServices/UTCoreTypes.h>

@implementation SpotlightBeamManager(NotificationHandler)

/* This notification should necessarily contain action(as either create_single/create_bulk/delete)
 * and optional completionHandler
 *
 * create_bulk : expects array against key 'indices_array',each element in which is a dictionary speciying title,unique_id,domain_id
 *
 * create_single : title,unique_id,domain_id are necessary, thumbnail(optional), description(optional)
 *
 * delete_by_uid : should specify array of unique ids for which indices are to be deleted
 *
 * delete_by_domain : should specify array of domain ids for which indices are to be deleted
 *
 * completionHandler will be passed an NSError object if there was an error during operation; so please handle both succes and failure blocks in completionHandler on basis of presence of error object
 */
-(void)spotlightNotificationReceived:(NSNotification *)notification{
    
    NSDictionary *userInfoDict = notification.userInfo;
    void (^completionBlock)(NSError * __nullable error) = [userInfoDict objectForKey:CS_COMPLETION_HANDLER];
    
    if (userInfoDict && [userInfoDict objectForKey:CS_ACTION_TYPE]) {
        
        //check for action
        NSString *actionType = [userInfoDict objectForKey:CS_ACTION_TYPE];
        
        if ([actionType isEqualToString:CS_ACTION_CREATE_BULK]){
            
            [self handleBulkCreationForDetailsDict:userInfoDict];
        }
        //for creation, domainid and uniqueId are expected to be valid NSString instances
        else if ([actionType isEqualToString:CS_ACTION_CREATE_SINGLE]) {
            
            [self handleSingleIndexCreationForDetailsDict:userInfoDict];
        }
        //for deletion, domainId and uniqueId are expected to be valid NSArray instances
        else if ([actionType isEqualToString:CS_ACTION_DELETE_BY_UID]){
            
            [self handleDeletionByIdForDetailsDict:userInfoDict];
        }else if([actionType isEqualToString:CS_ACTION_DELETE_BY_DOMAIN]){
            
            [self handleDeletionByDomainForDetailsDict:userInfoDict];
        }else{
            NSError *error = [SpotlightErrors prepareErrorWithCode:InvalidActionError andErrorObject:userInfoDict forKey:CS_INVALID_INDICES_ARRAY];
            completionBlock(error);
        }
    }else{
        NSError *error = [SpotlightErrors prepareErrorWithCode:InvalidActionError andErrorObject:userInfoDict forKey:CS_INVALID_INDICES_ARRAY];
        completionBlock(error);
    }
}

//validate input from notification and create indices in bulk, else report error
-(void)handleBulkCreationForDetailsDict:(NSDictionary *)userInfoDict{
    
    id arrayObject = [userInfoDict objectForKey:CS_INDICES_ARRAY];
    void (^completionBlock)(NSError * __nullable error) = [userInfoDict objectForKey:CS_COMPLETION_HANDLER];
    
    if(arrayObject && [arrayObject isKindOfClass:[NSArray class]]) {
        NSArray *indicesArray = (NSArray *)arrayObject;
        
        NSMutableArray *validIndicesArray = [[NSMutableArray alloc]init];
        NSMutableArray *invalidIndicesArray = [[NSMutableArray alloc]init];
        
        for(int i=0;i<indicesArray.count;i++){
            
            if ([indicesArray[i] isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary *detailsDict = (NSDictionary *)indicesArray[i];
                
                CSSearchableItem *indexItem = [self prepareIndexWithTitle:[detailsDict objectForKey:CS_TITLE] andDescription:[detailsDict objectForKey:CS_DESC] andUniqueID:[detailsDict objectForKey:CS_UNIQ_ID_KEY] andDomainID:[detailsDict objectForKey:CS_DOMAIN_ID_KEY] andThumbnailData:[detailsDict objectForKey:CS_THUMBNAIL]];
                
                if (indexItem) {
                    [validIndicesArray addObject:indexItem];
                }else{
                    [invalidIndicesArray addObject:detailsDict];
                }
                
            }else{
                [invalidIndicesArray addObject:indicesArray[i]];
            }
        }
        
        if (validIndicesArray.count>0) {
            //put valid indices into defaultSearchableIndex of the system
            [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:validIndicesArray completionHandler:completionBlock];
        }
        
        //report back the error
        if (invalidIndicesArray.count>0 && completionBlock) {
            
            NSError *error = [SpotlightErrors prepareErrorWithCode:InvalidIndexDictionaryError andErrorObject:userInfoDict forKey:InvalidIndexDictionaryError];
            completionBlock(error);
        }
        
    }else{
        
        NSError *error = [SpotlightErrors prepareErrorWithCode:InvalidBulkIndicesArrayError andErrorObject:userInfoDict forKey:CS_INVALID_INDICES_ARRAY];
        completionBlock(error);
    }
    
}

//validate input from notification and create single index, else report error
-(void)handleSingleIndexCreationForDetailsDict:(NSDictionary *)userInfoDict{
    
    void (^completionBlock)(NSError * __nullable error) = [userInfoDict objectForKey:CS_COMPLETION_HANDLER];
    
    CSSearchableItem *indexItem = [self prepareIndexWithTitle:[userInfoDict objectForKey:CS_TITLE] andDescription:[userInfoDict objectForKey:CS_DESC] andUniqueID:[userInfoDict objectForKey:CS_UNIQ_ID_KEY] andDomainID:[userInfoDict objectForKey:CS_DOMAIN_ID_KEY] andThumbnailData:[userInfoDict objectForKey:CS_THUMBNAIL]];
    
    if (indexItem) {
        //create index
        [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:@[indexItem] completionHandler:completionBlock];
    }else{
        NSError *error = [SpotlightErrors prepareErrorWithCode:InvalidIndexDictionaryError andErrorObject:userInfoDict forKey:CS_INVALID_INDICES_ARRAY];
        completionBlock(error);
    }
    
}

//validate input from notification and delete indices in bulk by unique ids, else report error
-(void)handleDeletionByIdForDetailsDict:(NSDictionary *)userInfoDict{
    NSObject *uniqueId = [userInfoDict objectForKey:CS_UNIQ_ID_KEY];
    
    void (^completionBlock)(NSError * __nullable error) = [userInfoDict objectForKey:CS_COMPLETION_HANDLER];
    
    if (uniqueId && [uniqueId isKindOfClass:[NSArray class]]) {
        
        [self deleteIndicesWithUniqueIdArray:((NSArray *)uniqueId) withCompletionHandler:completionBlock];
        
    }else{
        
        NSError *error = [SpotlightErrors prepareErrorWithCode:InvalidUniqueIdError andErrorObject:userInfoDict forKey:CS_INVALID_INDICES_ARRAY];
        completionBlock(error);
    }
}

//validate input from notification and delete indices in bulk by domain ids, else report error
-(void)handleDeletionByDomainForDetailsDict:(NSDictionary *)userInfoDict{
    
    NSObject *domainId = [userInfoDict objectForKey:CS_DOMAIN_ID_KEY];
    
    void (^completionBlock)(NSError * __nullable error) = [userInfoDict objectForKey:CS_COMPLETION_HANDLER];
    
    if (domainId && [domainId isKindOfClass:[NSArray class]]) {
        [self deleteIndicesWithDomainIdArray:((NSArray *)domainId) withCompletionHandler:completionBlock];
    }else{
        
        NSError *error = [SpotlightErrors prepareErrorWithCode:InvalidDomainIdError andErrorObject:userInfoDict forKey:CS_INVALID_INDICES_ARRAY];
        completionBlock(error);
    }
}
@end

//
//  SpotlightBeamManager.m
//  Pods
//
//  Created by Krati Jain on 15/12/15.
//
//

#import "SpotlightBeamManager.h"
#import <CoreSpotlight/CoreSpotlight.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "SpotlightBeamConstants.h"
#import "SpotlightErrors.h"

static SpotlightBeamManager *sharedInstance;

@implementation SpotlightBeamManager

+ (instancetype) getSharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SpotlightBeamManager alloc] init];
    });
    return sharedInstance;
}

- (id) init {
    if(self = [super init]) {
        [self startListeningToNotifications];
    }
    return self;
}
/* SpotlightBeamManager listens to Notifications with Name @"CS_NOTIFICATION"
 
 The dictionary sent with the notification should contain following keys:
 
 action(NSString)
 title(NSString),
 unique_id(NSString if create/array if delete),
 domain_id(NSString if create/array if delete),
 
 desc(NSString,optional),
 thumbnail(NSData,optional)
 
 Refer to Constant.h for related constants for above keys
 */
-(void)startListeningToNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(spotlightNotificationReceived:)
                                                 name:CS_NOTIFICATION
                                               object:nil];
}

//prepares a valid CSSearchableIndex after validating the input
-(CSSearchableItem *)prepareIndexWithTitle:(id)title andDescription:(id)description andUniqueID:(id)uniqueId andDomainID:(id)domainID andThumbnailData:(id)thumbnailData{
    
    CSSearchableItem *index = nil;
    
    //if data is valid, create index
    if(uniqueId && [uniqueId isKindOfClass:[NSString class]] && domainId && [domainId isKindOfClass:[NSString class]] && title && [title isKindOfClass:[NSString class]]) {
        
        CSSearchableItemAttributeSet *attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString *)kUTTypeText];
        
        attributeSet.title = (NSString *)title;
        attributeSet.contentDescription = description;
        
        if (thumbnailData!=nil && [thumbnailData isKindOfClass:[NSData class]]) {
            attributeSet.thumbnailData = (NSData *)thumbnailData;
        }
        
        // Create a searchable item, specifying its ID, associated domain, and the attribute set you created earlier.
        index = [[CSSearchableItem alloc] initWithUniqueIdentifier:(NSString *)uniqueId domainIdentifier:(NSString *)domainID attributeSet:attributeSet];
    }
    return index;
}


//this method prepares the attributes based on parameters passed and creates an index for spotlight search
-(void)indexSpotlightItemWithTitle:(NSString *)title andDescription:(NSString *)description andUniqueID:(NSString *)uniqueId andDomainID:(NSString *)domainID andThumbnailData:(NSData *)thumbnailData withCompletionHandler:(void (^ __nullable)(NSError * __nullable error))completionHandler{
    
    CSSearchableIndex *index = [self prepareIndexWithTitle:title andDescription:description andUniqueID:uniqueId andDomainID:domainID andThumbnailData:thumbnailData];
    
    //put the index in defaultSearchableIndex
    [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:@[index] completionHandler:completionHandler];
}

//delete all indices with specified unique id array
-(void)deleteIndicesWithUniqueIdArray:(NSArray *)uniqueIDArray withCompletionHandler:(void (^ __nullable)(NSError * __nullable error))completionHandler{

    [[CSSearchableIndex defaultSearchableIndex] deleteSearchableItemsWithIdentifiers:uniqueIDArray completionHandler:completionHandler];
}

//delete indices with specified domain id array
-(void)deleteIndicesWithDomainIdArray:(NSArray *)domainIDArray withCompletionHandler:(void (^ __nullable)(NSError * __nullable error))completionHandler{
    
    [[CSSearchableIndex defaultSearchableIndex] deleteSearchableItemsWithDomainIdentifiers:domainIDArray completionHandler:completionHandler];
}

//this method identifies the action from the userInfo dictionary obtained from the Spotlight Search Result and acts on it
-(void)actOnIndexDict:(NSDictionary *)indexDict{
    
    NSString *uniqueItemId = [indexDict objectForKey:CSSearchableItemActivityIdentifier];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(actOnUniqueId:)]) {
        [self.delegate actOnUniqueId:uniqueItemId];
    }
}
@end
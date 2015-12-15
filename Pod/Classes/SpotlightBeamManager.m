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

/* This notification should necessarily contain action as either create_single/create_bulk/delete
 *
 * create_bulk : expects array against key 'indices_array',each element in which is a dictionary speciying title,unique_id,domain_id
 *
 * Create_single : title,unique_id,domain_id are necessary
 *
 * Delete : either unique_id or domain_id should be present and should specify array of unique ids or array of domain ids respectively.
 *
 */
-(void)spotlightNotificationReceived:(NSNotification *)notification{
    
    NSDictionary *details = notification.userInfo;
    
    //check for action
    NSString *actionType = [details objectForKey:CS_ACTION_TYPE];
    
    if (actionType) {
        
        if ([actionType isEqualToString:CS_ACTION_CREATE_BULK] && [details objectForKey:CS_INDICES_ARRAY]) {
            
            NSArray *indicesArray = [details objectForKey:CS_INDICES_ARRAY];
            
            for(int i=0;i<indicesArray.count;i++){
                
                if ([indicesArray[i] isKindOfClass:[NSDictionary class]]) {
                    
                    NSDictionary *detailsDict = (NSDictionary *)indicesArray[i];
                    [self createIndexFromDictionary:detailsDict];
                }
            }
        }
        //for creation, domainid and uniqueId are expected to be valid NSString instances
        else if ([actionType isEqualToString:CS_ACTION_CREATE_SINGLE]) {
            
            [self createIndexFromDictionary:details];
            
        }
        //for deletion, domainId and uniqueId are expected to be valid NSArray instances
        else if ([actionType isEqualToString:CS_ACTION_DELETE]) {
            
            NSObject *uniqueId = [details objectForKey:CS_UNIQ_ID_KEY];
            NSObject *domainId = [details objectForKey:CS_DOMAIN_ID_KEY];
            
            if (uniqueId && [uniqueId isKindOfClass:[NSArray class]]) {
                
                [self deleteIndicesWithUniqueIdArray:((NSArray *)uniqueId)];
                
            }else if(domainId && [domainId isKindOfClass:[NSArray class]]){
                
                [self deleteIndicesWithDomainIdArray:((NSArray *)domainId)];
            }
            
        }
    }
}

-(void)createIndexFromDictionary:(NSDictionary *)details{
    
    NSObject *uniqueId = [details objectForKey:CS_UNIQ_ID_KEY];
    NSObject *domainId = [details objectForKey:CS_DOMAIN_ID_KEY];
    NSString *title =[details objectForKey:CS_TITLE];
    
    if(uniqueId && [uniqueId isKindOfClass:[NSString class]] && domainId && [domainId isKindOfClass:[NSString class]] && title) {
        
        [self indexSpotlightItemWithTitle:title andDescription:[details objectForKey:CS_DESC] andUniqueID:(NSString *)uniqueId andDomainID:(NSString *)domainId andThumbnailData:[details objectForKey:CS_THUMBNAIL]];
    }
}

//this method prepares the attributes based on parameters passed and creates an index for spotlight search
-(void)indexSpotlightItemWithTitle:(NSString *)title andDescription:(NSString *)description andUniqueID:(NSString *)uniqueId andDomainID:(NSString *)domainID andThumbnailData:(NSData *)thumbnailData{
    
    CSSearchableItemAttributeSet *attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString *)kUTTypeImage];
    attributeSet.title=title;
    attributeSet.contentDescription = description;
    attributeSet.pixelHeight = [NSNumber numberWithInteger:50];
    attributeSet.pixelWidth = [NSNumber numberWithInteger:50];
    if (thumbnailData!=nil) {
        attributeSet.thumbnailData = thumbnailData;
    }
    
    // Create a searchable item, specifying its ID, associated domain, and the attribute set you created earlier.
    CSSearchableItem *index = [[CSSearchableItem alloc] initWithUniqueIdentifier:uniqueId domainIdentifier:domainID attributeSet:attributeSet];
    
    //create index
    [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:@[index] completionHandler: nil];
    
}

//delete all indices with specified unique id array
-(void)deleteIndicesWithUniqueIdArray:(NSArray *)uniqueIDArray{

    [[CSSearchableIndex defaultSearchableIndex] deleteSearchableItemsWithIdentifiers:uniqueIDArray completionHandler:nil];
}

//delete indices with specified domain id array
-(void)deleteIndicesWithDomainIdArray:(NSArray *)domainIDArray{
    
    [[CSSearchableIndex defaultSearchableIndex] deleteSearchableItemsWithDomainIdentifiers:domainIDArray completionHandler:nil];
}

//this method identifies the action from the userInfo dictionary obtained from the Spotlight Search Result and acts on it
-(void)actOnIndexDict:(NSDictionary *)indexDict{
    
    NSString *uniqueItemId = [indexDict objectForKey:CSSearchableItemActivityIdentifier];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(actOnUniqueId:)]) {
        [self.delegate actOnUniqueId:uniqueItemId];
    }
}
@end
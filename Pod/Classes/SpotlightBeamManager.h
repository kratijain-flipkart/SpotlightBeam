//
//  SpotlightBeamManager.h
//  Pods
//
//  Created by Krati Jain on 15/12/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreSpotlight/CoreSpotlight.h>

@protocol SpotlightActionDelegate <NSObject>
-(void)actOnUniqueId:(NSString * __nonnull)uniqueId;
@end

@interface SpotlightBeamManager : NSObject

@property (nonatomic, weak) id <SpotlightActionDelegate> delegate;

+ (instancetype __nonnull) getSharedInstance;
-(CSSearchableItem * __nullable)prepareIndexWithTitle:(id __nonnull)title andDescription:(id __nullable)description andUniqueID:(id __nonnull)uniqueId andDomainID:(id __nonnull)domainID andThumbnailData:(id __nonnull)thumbnailData;
-(void)indexSpotlightItemWithTitle:(NSString *__nonnull)title andDescription:(NSString *__nullable)description andUniqueID:(NSString *__nonnull)uniqueId andDomainID:(NSString *__nonnull)domainID andThumbnailData:(NSData *__nullable)thumbnailData withCompletionHandler:(void (^ __nullable)(NSError * __nullable error))completionHandler;

-(void)deleteIndicesWithDomainIdArray:(NSArray *__nonnull)domainIDArray withCompletionHandler:(void (^ __nullable)(NSError * __nullable error))completionHandler;
-(void)deleteIndicesWithUniqueIdArray:(NSArray *__nonnull)uniqueIDArray withCompletionHandler:(void (^ __nullable)(NSError * __nullable error))completionHandler;

-(void)actOnIndexDict:(NSDictionary *__nonnull)indexDict;
@end

//
//  SpotlightBeamManager.h
//  Pods
//
//  Created by Krati Jain on 15/12/15.
//
//

#import <Foundation/Foundation.h>

@protocol SpotlightActionDelegate <NSObject>
-(void)actOnUniqueId:(NSString *)uniqueId;
@end

@interface SpotlightBeamManager : NSObject

@property (nonatomic, weak) id <SpotlightActionDelegate> delegate;

+ (instancetype) getSharedInstance;

-(void)indexSpotlightItemWithTitle:(NSString *)title andDescription:(NSString *)description andUniqueID:(NSString *)uniqueId andDomainID:(NSString *)domainID andThumbnailData:(NSData *)thumbnailData withCompletionHandler:(void (^ __nullable)(NSError * __nullable error))completionHandler;

-(void)deleteIndicesWithDomainIdArray:(NSArray *)domainIDArray withCompletionHandler:(void (^ __nullable)(NSError * __nullable error))completionHandler;
-(void)deleteIndicesWithUniqueIdArray:(NSArray *)uniqueIDArray withCompletionHandler:(void (^ __nullable)(NSError * __nullable error))completionHandler;

-(void)actOnIndexDict:(NSDictionary *)indexDict;
@end

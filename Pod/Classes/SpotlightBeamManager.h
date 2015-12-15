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
-(void)indexSpotlightItemWithTitle:(NSString *)title andDescription:(NSString *)description andUniqueID:(NSString *)uniqueId andDomainID:(NSString *)domainID andThumbnailData:(NSData *)thumbnailData;
-(void)deleteIndicesWithDomainIdArray:(NSArray *)domainIDArray;
-(void)deleteIndicesWithUniqueIdArray:(NSArray *)uniqueIDArray;
-(void)actOnIndexDict:(NSDictionary *)indexDict;
@end

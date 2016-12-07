//
//  WebServiceClient.m
//  AcronymsFinder
//
//  Created by Tejashree Deshpande on 12/7/16.
//  Copyright © 2016 Tejashree Deshpande. All rights reserved.
//

#import "WebServiceClient.h"
#import "Meaning.h"

@implementation WebServiceClient

+(WebServiceClient *) sharedManager {
    
    static WebServiceClient *sharedManager = nil;
    static dispatch_once_t once ;
    dispatch_once(&once, ^{
        sharedManager = [[WebServiceClient alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    return self;
}

- (void)getResponseForURLString: (NSString *)urlString Parameters:(NSDictionary *) parameters success:(ServiceSuccessBlock) success failure:(ServiceFailureBlock) failure
{
    
    /*
     http://www.nactem.ac.uk/software/acromine/dictionary.py API sending "Content-Type" = "text/plain". But AFURLResponseSerialization can accept @"application/json", @"text/json", @"text/javascript". To fix this make acceptableContentTypes = nil
     */
    
    self.responseSerializer.acceptableContentTypes = nil;
    
    [self GET:urlString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject){
        if (success) {
            success(task, [self parseResponseObject:responseObject]);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(task, error);
        }
    }];
}

#pragma mark- Simple JSON to Object mapper methods

/*
 * Specific parsing method for object mapping.
 *
 */

-(Acronym *) parseResponseObject:(id) responseObject {
    
    NSLog(@"%@", responseObject);
    if([responseObject isKindOfClass:[NSArray class]] && [responseObject count] > 0 ){
        for(NSDictionary *dict in responseObject){
            
            Acronym *acronym = [[Acronym alloc] init];
            [acronym setShortForm: [dict objectForKey:@"sf"]] ;
            [acronym setMeanings:[self getMeanings:[dict objectForKey:@"lfs"]]];
            return acronym;
        }
        
    }
    return nil;
}
-(NSMutableArray *) getMeanings:(NSMutableArray *) responseArray {
    NSMutableArray *meaningArray = [NSMutableArray array];
    for(NSDictionary *dict in responseArray){
        
        Meaning *meaning = [[Meaning alloc] init];
        [meaning setMeaning: [dict objectForKey:@"lf"]] ;
        [meaningArray addObject:meaning];
    }
    return meaningArray;
}

@end

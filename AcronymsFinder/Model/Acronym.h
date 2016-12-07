//
//  Acronym.h
//  AcronymsFinder
//
//  Created by Tejashree Deshpande on 12/7/16.
//  Copyright © 2016 Tejashree Deshpande. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Acronym : NSObject
@property (nonatomic,copy) NSString *shortForm;
@property (nonatomic,strong) NSMutableArray *meanings;
@end

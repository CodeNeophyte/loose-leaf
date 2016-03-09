//
//  MMPaperStackViewDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/4/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMImageSidebarContainerView.h"
#import "MMShareSidebarContainerView.h"

@protocol MMPaperStackViewDelegate <NSObject>

-(void) animatingToListView;

-(void) animatingToPageView;

-(MMImageSidebarContainerView*) importImageSidebar;

-(MMShareSidebarContainerView*) sharePageSidebar;

@end

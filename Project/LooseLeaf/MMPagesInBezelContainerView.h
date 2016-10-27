//
//  MMPagesInBezelContainerView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/27/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMCountableSidebarContainerView.h"
#import "MMUntouchableView.h"
#import "MMScrapView.h"
#import "MMScrapSidebarContainerViewDelegate.h"
#import "MMScrapsOnPaperStateDelegate.h"
#import "MMCountBubbleButton.h"
#import "MMScrapsInSidebarStateDelegate.h"
#import "MMScrapsInSidebarState.h"
#import "MMPagesSidebarContainerViewDelegate.h"


@interface MMPagesInBezelContainerView : MMCountableSidebarContainerView <MMEditablePaperView*>

@property (nonatomic, weak) NSObject<MMPagesSidebarContainerViewDelegate>* bubbleDelegate;

- (void)savePageContainerToDisk;

- (void)loadFromDisk;

@end

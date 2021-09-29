//
//  UICollectionView+Adapter.m
//  ArtChat
//
//  Created by weijingyun on 2017/10/9.
//

#import "UICollectionView+Adapter.h"
#import "ArtUIDefine.h"

@implementation UICollectionView (Adapter)

+ (void)load {
    uiswizzling_exchangeMethod([self class], @selector(initWithFrame:collectionViewLayout:), @selector(swizz_initWithFrame:collectionViewLayout:));
}

- (instancetype)swizz_initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
   
    UICollectionView *view = [self swizz_initWithFrame:frame collectionViewLayout:layout];
    if (@available(iOS 11.0, *)) {
        view.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    return view;
}

@end

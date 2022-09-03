//
//  NSObject+OCUP.h
//  unipets-ios
//
//  Created by LRanger on 2021/10/28.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (UP)

- (BOOL)isKindOfClassName:(NSString *)name;

@end

@interface UIImage (UP)

- (UIImage *)fixOrientation;

- (UIImage *)imageByGrayscale;

- (UIImage *)imageByBlurSoft;

- (UIImage *)imageByBlurLight;

- (UIImage *)imageByBlurExtraLight;

- (UIImage *)imageByBlurDark;

- (UIImage * _Nullable)imageByBlurRadius:(CGFloat)blurRadius
                     tintColor:(UIColor * _Nullable)tintColor
                      tintMode:(CGBlendMode)tintBlendMode
                    saturation:(CGFloat)saturation
                     maskImage:(UIImage * _Nullable)maskImage;

- (UIImage * _Nullable)imageByBlurRadius:(CGFloat)blurRadius;

- (UIImage * _Nullable)imageByResizeToSize:(CGSize)size;

- (UIImage * _Nullable)imageByResizeToSize:(CGSize)size contentMode:(UIViewContentMode)contentMode;

- (UIImage * _Nullable)imageByRotate:(CGFloat)radians fitSize:(BOOL)fitSize;

- (UIImage * _Nullable)imageByInsetEdge:(UIEdgeInsets)insets withColor:(UIColor *)color;

- (UIImage * _Nullable)imageByRoundCornerRadius:(CGFloat)radius
                          borderWidth:(CGFloat)borderWidth
                          borderColor:(UIColor *)borderColor;
@end

@interface UIView (UP)

- (UIImage * _Nullable)snapshotImage;

- (UIImage * _Nullable)snapshotImageAfterScreenUpdates:(BOOL)afterUpdates cropRect:(CGRect)rect;

- (UIImage * _Nullable)snapshotImageAfterScreenUpdates:(BOOL)afterUpdates;

@end


NS_ASSUME_NONNULL_END

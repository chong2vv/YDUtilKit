//
//  UILabel+YDAddtion.m
//  YDUtilKit
//
//  Created by 王远东 on 2022/8/16.
//

#import "UILabel+YDAddtion.h"
#import <CoreText/CoreText.h>
#import <objc/runtime.h>

@implementation UILabel (YDAddtion)

//最多显示x行，显示不下以。。。结尾
- (void)changeLineSpaceForLabelByTruncatingTail:(UIFont *)tailFont withTail:(NSString *)tailText tailTextColor:(UIColor*)tailTextColor showLine:(NSInteger)line labelWidth:(CGFloat)width {
    self.tailText = tailText;
    NSArray *array = [self getSeparatedLinesWithWidth:width];
    
    if (array.count>=line) {
        NSString *lastLineString = [array[line - 1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
        NSMutableAttributedString *tailAttr = [[NSMutableAttributedString alloc]initWithString:tailText];
        [tailAttr addAttribute:NSFontAttributeName value:tailFont range:NSMakeRange(0, tailAttr.string.length)];
        CGFloat tailW = [self sizeWithAttributeText:tailAttr].width;
        NSMutableAttributedString *lastLineAttr = [[NSMutableAttributedString alloc]initWithString:lastLineString];
        [lastLineAttr addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, lastLineString.length)];
        CGFloat lastLineW = [self sizeWithAttributeText:lastLineAttr].width;
        if (lastLineW + tailW < width) {
            //添加空格 (根据业务需求)
            while (lastLineW + tailW < width) {
                lastLineString = [NSString stringWithFormat:@"%@ ",lastLineString];
                NSMutableAttributedString *lastLineAttr1 = [[NSMutableAttributedString alloc]initWithString:lastLineString];
                [lastLineAttr1 addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, lastLineString.length)];
                lastLineW = [self sizeWithAttributeText:lastLineAttr1].width;
            }
            if (lastLineW + tailW > width) {
                lastLineString = [lastLineString substringToIndex:lastLineString.length-1];
            }
            
        }else{
            while (lastLineW + tailW > width) {
                lastLineString = [lastLineString substringToIndex:lastLineString.length-1];
                NSMutableAttributedString *lastLineAttr1 = [[NSMutableAttributedString alloc]initWithString:lastLineString];
                [lastLineAttr1 addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, lastLineString.length)];
                lastLineW = [self sizeWithAttributeText:lastLineAttr1].width;
            }
        }
        NSMutableString *showText = [NSMutableString string];
        for (NSInteger i = 0; i < line-1; i++) {
            [showText appendString:array[i]];
        }
        [showText appendString:lastLineString];
        [showText appendString:tailText];
        
        NSRange attributeRange = [showText rangeOfString:tailText];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:showText];
        //其他字的也得设置，不然计算点击区域会有问题
        [attributedString addAttribute:NSForegroundColorAttributeName value:self.textColor range:NSMakeRange(0, attributedString.string.length)];
        [attributedString addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, attributedString.string.length)];
        //高亮字
        [attributedString addAttribute:NSForegroundColorAttributeName value:tailTextColor range:attributeRange];
        [attributedString addAttribute:NSFontAttributeName value:tailFont range:attributeRange];
        self.attributedText = attributedString;

        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tap];
    }
    
    
}

-(void)tapAction:(UITapGestureRecognizer *)tap{
    [self layoutIfNeeded];
    //方案一
    BOOL didTapLink = [tap didTapAttributedTextInLabel:self
                                                      inRange:[self.attributedText.string rangeOfString:self.tailText]];
//    if (didTapLink) {
//        NSLog(@"点击了 高亮字 (%@)",@"点击查看");
        !self.tapAction?:self.tapAction();
//    }else{
//        NSLog(@"点击了其他字");
//    }
    
    // 二
    //[self touchPoint:[tap locationInView:self]];
}
//MARK: - 方案二
- (void)touchPoint:(CGPoint)p
{
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributedText);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    CTFrameRef  frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, self.attributedText.length), path, NULL);
    CFRange     range = CTFrameGetVisibleStringRange(frame);

    if (self.attributedText.length > range.length) {
        UIFont *font = nil;
        if ([self.attributedText attribute:NSFontAttributeName atIndex:0 effectiveRange:nil]) {
            font = [self.attributedText attribute:NSFontAttributeName atIndex:0 effectiveRange:nil];
        } else if (self.font){
            font = self.font;
        } else {
            font = [UIFont systemFontOfSize:17];
        }

        CGPathRelease(path);
        path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height + font.lineHeight));
        frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    }

    CFArrayRef  lines = CTFrameGetLines(frame);
    CFIndex     count = CFArrayGetCount(lines);
    NSInteger   numberOfLines = self.numberOfLines > 0 ? MIN(self.numberOfLines,count) : count;

    if (!numberOfLines) {
        CFRelease(frame);
        CFRelease(framesetter);
        CGPathRelease(path);
        return;
    }

    CGPoint origins[count];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), origins);

    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.f, -1.f);;
    CGFloat verticalOffset = 0;

    for (CFIndex i = 0; i < numberOfLines; i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);

        CGFloat ascent = 0.0f;
        CGFloat descent = 0.0f;
        CGFloat leading = 0.0f;
        CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGFloat height = ascent + fabs(descent*2) + leading;

        CGRect flippedRect = CGRectMake(p.x, p.y , width, height);
        CGRect rect = CGRectApplyAffineTransform(flippedRect, transform);

        rect = CGRectInset(rect, 0, 0);
        rect = CGRectOffset(rect, 0, verticalOffset);

        NSParagraphStyle *style = [self.attributedText attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:nil];

        CGFloat lineSpace;

        if (style) {
            lineSpace = style.lineSpacing;
        } else {
            lineSpace = 0;
        }

        CGFloat lineOutSpace = (self.bounds.size.height - lineSpace * (count - 1) -rect.size.height * count) / 2;
        rect.origin.y = lineOutSpace + rect.size.height * i + lineSpace * i;

        if (CGRectContainsPoint(rect, p)) {
            CGPoint relativePoint = CGPointMake(p.x, p.y);
            CFIndex index = CTLineGetStringIndexForPosition(line, relativePoint);
            CGFloat offset;
            CTLineGetOffsetForStringIndex(line, index, &offset);

            if (offset > relativePoint.x) {
                index = index - 1;
            }
            NSRange ran = [self.attributedText.string rangeOfString:self.tailText];
            if (NSLocationInRange(index, ran)) {
                NSLog(@"点击了高亮字  (%@)",self.tailText);
                !self.tapAction?:self.tapAction();
            }else{
                NSLog(@"点击了其他字");
            }
        
        }
    }

    CFRelease(frame);
    CFRelease(framesetter);
    CGPathRelease(path);
}


//获取每行文字
- (NSArray *)getSeparatedLinesWithWidth:(CGFloat)width
{
    NSString *text = [self text];
    if (!text || text.length<1) {
        return 0;
    }
    UIFont *font = [self font];
    CTFontRef myFont = CTFontCreateWithName((__bridge CFStringRef)([font fontName]), [font pointSize], NULL);
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:text];
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)myFont range:NSMakeRange(0, attStr.length)];
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attStr);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,width,100000));
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];
    for (id line in lines) {
        CTLineRef lineRef = (__bridge CTLineRef )line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        NSString *lineString = [text substringWithRange:range];
        [linesArray addObject:lineString];
        
    }
    return linesArray;
    
}

-(CGSize)sizeWithAttributeText:(NSAttributedString *)attributeText{
    
    CGSize maxSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    NSStringDrawingOptions opts = NSStringDrawingUsesLineFragmentOrigin |
    NSStringDrawingUsesFontLeading;
    CGRect rect = [attributeText boundingRectWithSize:maxSize options:opts context:nil];
    
    return rect.size;
}

//MARK: - 属性
static NSString *TailTextKey = @"TailTextKey";

-(void)setTailText:(NSString *)tailText{
    objc_setAssociatedObject(self, &TailTextKey, tailText, OBJC_ASSOCIATION_COPY);
}
-(NSString *)tailText{
    return objc_getAssociatedObject(self, &TailTextKey);
}

static NSString *TapActionKey = @"TapActionKey";
-(void)setTapAction:(TapAction)tapAction{
    objc_setAssociatedObject(self, &TapActionKey, tapAction, OBJC_ASSOCIATION_COPY);
}
-(TapAction)tapAction{
    return objc_getAssociatedObject(self, &TapActionKey);
}


@end

//
//  Extension.swift
//
//  Created by hyd on 2024/3/20.
//  类的扩展

import UIKit
import RxSwift
import RxCocoa

enum GradientDirection {
    case leftToRight
    case topToBottom
    // 其他方向...
}

/// 字号
struct FontSizes {
    static let regular10 = UIFont.systemFont(ofSize: 10)
    static let regular11 = UIFont.systemFont(ofSize: 11)
    static let regular12 = UIFont.systemFont(ofSize: 12)
    static let regular13 = UIFont.systemFont(ofSize: 13)
    static let regular14 = UIFont.systemFont(ofSize: 14)
    static let regular15 = UIFont.systemFont(ofSize: 15)
    static let regular16 = UIFont.systemFont(ofSize: 16)
    static let regular18 = UIFont.systemFont(ofSize: 18)
    static let regular20 = UIFont.systemFont(ofSize: 20)
    static let regular22 = UIFont.systemFont(ofSize: 22)
    static let regular24 = UIFont.systemFont(ofSize: 24)

    static let medium10 = UIFont.systemFont(ofSize: 10, weight: .medium)
    static let medium11 = UIFont.systemFont(ofSize: 11, weight: .medium)
    static let medium12 = UIFont.systemFont(ofSize: 12, weight: .medium)
    static let medium13 = UIFont.systemFont(ofSize: 13, weight: .medium)
    static let medium14 = UIFont.systemFont(ofSize: 14, weight: .medium)
    static let medium15 = UIFont.systemFont(ofSize: 15, weight: .medium)
    static let medium16 = UIFont.systemFont(ofSize: 16, weight: .medium)
    static let medium17 = UIFont.systemFont(ofSize: 17, weight: .medium)
    static let medium18 = UIFont.systemFont(ofSize: 18, weight: .medium)
    static let medium20 = UIFont.systemFont(ofSize: 20, weight: .medium)
    static let medium22 = UIFont.systemFont(ofSize: 22, weight: .medium)
    static let medium24 = UIFont.systemFont(ofSize: 24, weight: .medium)
    
    ///  自定义字体    
    static let DINBoldFont24: UIFont = {
        guard let font = UIFont(name: "DINCondensed-Bold", size: 24) else {
            fatalError("Failed to load the custom font.")
        }
        return font
    }()
    static let DINBoldFont32: UIFont = {
        guard let font = UIFont(name: "DINCondensed-Bold", size: 32) else {
            fatalError("Failed to load the custom font.")
        }
        return font
    }()
    static let DINBoldFont15: UIFont = {
        guard let font = UIFont(name: "DINCondensed-Bold", size: 15) else {
            fatalError("Failed to load the custom font.")
        }
        return font
    }()
    static let DINBoldFont17: UIFont = {
        guard let font = UIFont(name: "DINCondensed-Bold", size: 17) else {
            fatalError("Failed to load the custom font.")
        }
        return font
    }()
}

/// 颜色
struct AppColors {
    static let c_000000 = UIColor.colorWithHexString("#000000")
    static let c_2A2A2A = UIColor.colorWithHexString("#2A2A2A")

    static let c_222222 = UIColor.colorWithHexString("#222222")
    static let c_333333 = UIColor.colorWithHexString("#333333")

    static let c_111111 = UIColor.colorWithHexString("#111111")
    static let c_666666 = UIColor.colorWithHexString("#666666")
    static let c_FFA555 = UIColor.colorWithHexString("#FFA555")
    static let c_FFF7F0 = UIColor.colorWithHexString("#FFF7F0")
    static let c_FCF2DE = UIColor.colorWithHexString("#FCF2DE")
    static let c_FFF8F0 = UIColor.colorWithHexString("#FFF8F0")

    static let c_999999 = UIColor.colorWithHexString("#999999")
    static let c_F0F0F0 = UIColor.colorWithHexString("#F0F0F0")
    static let c_FFB26D = UIColor.colorWithHexString("#FFB26D")
    static let c_C0C0C0 = UIColor.colorWithHexString("#C0C0C0")
    static let c_F8F8F8 = UIColor.colorWithHexString("#F8F8F8")
    static let c_CA9C72 = UIColor.colorWithHexString("#CA9C72")
    static let c_FF995B = UIColor.colorWithHexString("#FF995B")
    static let c_D0D0D0 = UIColor.colorWithHexString("#D0D0D0")
    static let c_6EC64A = UIColor.colorWithHexString("#6EC64A")
    static let c_FFCC7C = UIColor.colorWithHexString("#FFCC7C")
    static let c_4F4F4F = UIColor.colorWithHexString("#4F4F4F")
    static let c_D0AF84 = UIColor.colorWithHexString("#D0AF84")
    static let c_FFAF2A = UIColor.colorWithHexString("#FFAF2A")
    static let c_4D4A42 = UIColor.colorWithHexString("#4D4A42")
    static let c_FFE6CF = UIColor.colorWithHexString("#FFE6CF")
    static let c_FFB74A = UIColor.colorWithHexString("#FFB74A")
    static let c_DDDDDD = UIColor.colorWithHexString("#DDDDDD")
    static let c_F4F5F7 = UIColor.colorWithHexString("#F4F5F7")
    static let c_FBF7F2 = UIColor.colorWithHexString("#FBF7F2")
    static let c_DADBDD = UIColor.colorWithHexString("#DADBDD")
    static let c_FFF9EE = UIColor.colorWithHexString("#FFF9EE")
    static let c_00C08A = UIColor.colorWithHexString("#00C08A")
    static let c_F3E3CF = UIColor.colorWithHexString("#F3E3CF")


}

extension Double {
    func formattedString() -> String {
        self.truncatingRemainder(dividingBy: 1) == 0
        ? String(format: "%.0f", self)
        : String(format: "%.1f", self)
    }
}

extension String {
    
    /// 计算文本宽度
    /// - Parameters:
    ///   - height: <#height description#>
    ///   - font: <#font description#>
    /// - Returns: <#description#>
    func widthWithConstrainedHeight(height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(boundingBox.width)
    }
    
    
    /// 中国大陆手机号码正则
    /// - Parameter number: <#number description#>
    /// - Returns: <#description#>
    func isValidChinesePhoneNumber(_ number: String) -> Bool {
        let regex = "^1[3-9]\\d{9}$"
        let phoneNumberPredicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return phoneNumberPredicate.evaluate(with: number)
    }
}
extension UIColor {
    
    /// 十六进制颜色转化
    /// - Parameters:
    ///   - hex: <#hex description#>
    ///   - alpha: <#alpha description#>
    /// - Returns: <#description#>
    static func colorWithHexString(_ hex: String, alpha: CGFloat = 1.0) -> UIColor {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    // 生成随机颜色
     static func randomColor(alpha: CGFloat = 1.0) -> UIColor {
         let red = CGFloat.random(in: 0...1)
         let green = CGFloat.random(in: 0...1)
         let blue = CGFloat.random(in: 0...1)
         
         return UIColor(red: red, green: green, blue: blue, alpha: alpha)
     }
    
    /// 用于颜色插值
    /// - Parameters:
    ///   - color: <#color description#>
    ///   - amount: <#amount description#>
    /// - Returns: <#description#>
    func lerp(to color: UIColor, amount: CGFloat) -> UIColor {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return UIColor(
            red: r1 + (r2 - r1) * amount,
            green: g1 + (g2 - g1) * amount,
            blue: b1 + (b2 - b1) * amount,
            alpha: a1 + (a2 - a1) * amount
        )
    }
}


extension UIView {
    
    /// 底部加虚线
    /// - Parameters:
    ///   - borderColor: <#borderColor description#>
    ///   - borderWidth: <#borderWidth description#>
    func addDashedBottomBorder(borderColor: UIColor = AppColors.c_F0F0F0, borderWidth: CGFloat = 1.0) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = borderColor.cgColor
        shapeLayer.lineWidth = borderWidth
//        shapeLayer.lineDashPattern = [2, 2]
        self.layer.addSublayer(shapeLayer)

        // 使用 RxSwift 来观察视图尺寸的变化
        self.rx.observe(CGRect.self, "bounds")
            .subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else { return }
                let path = CGMutablePath()
                path.addLines(between: [CGPoint(x: 0, y: strongSelf.bounds.height - borderWidth / 2),
                                        CGPoint(x: strongSelf.bounds.width, y: strongSelf.bounds.height - borderWidth / 2)])
                shapeLayer.path = path
            }).disposed(by: rx.disposeBag)
    }
    
    func gradientColor(startColor: UIColor, endColor: UIColor, direction: GradientDirection = .topToBottom) {
        // 移除已存在的渐变层
        self.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        switch direction {
        case .leftToRight:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        case .topToBottom:
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        }
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    static func creatLineView() ->UIView{
        let lineView = UIView.init()
        lineView.backgroundColor = AppColors.c_F0F0F0
        return lineView
    }

    
    private struct AssociatedKeys {
        static var isSelect = "isSelect"
        static var selectedColor = "selectedColor"  // 新增关联键用于存储颜色
    }
    
    var isSelect: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.isSelect) as? Bool ?? false
        }
        set(value) {
            objc_setAssociatedObject(self, &AssociatedKeys.isSelect, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateTitleLabelColor(isSelected: value)
        }
    }
    
    // 新增属性用于设置和获取颜色
    var selectedTextColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.selectedColor) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.selectedColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if isSelect {  // 当设置颜色时如果已经是选中状态，则立即更新颜色
                updateTitleLabelColor(isSelected: true)
            }
        }
    }
    
    func updateTitleLabelColor(isSelected: Bool) {
        guard let label = self as? UILabel else { return }
        let color = isSelected ? (selectedTextColor ?? UIColor.black) : AppColors.c_999999
        label.textColor = color
    }
    

    func renderToImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }

}

///使用 RxCocoa 中的 Reactive 扩展来观察 UIView 的 bounds 的变化，以保证在视图尺寸变化时虚线的宽度能够相应地更新
extension Reactive where Base: UIView {
    var disposeBag: DisposeBag {
        get {
            if let bag = objc_getAssociatedObject(base, &disposeBagKey) as? DisposeBag {
                return bag
            }
            let bag = DisposeBag()
            objc_setAssociatedObject(base, &disposeBagKey, bag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bag
        }
        set {
            objc_setAssociatedObject(base, &disposeBagKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

private var disposeBagKey: UInt8 = 0


extension UIImageView {

    convenience init(image: UIImage?, contentMode: UIView.ContentMode = .scaleAspectFit, enableInteraction: Bool = true) {
        self.init(image: image)
        self.contentMode = contentMode
        self.isUserInteractionEnabled = enableInteraction
    }
}

extension UIImage {
    public class func gif(data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        return UIImage.animatedImageWithSource(source)
    }

    public class func gif(url: String) -> UIImage? {
        guard let imageData = try? Data(contentsOf: URL(string: url)!) else { return nil }
        return gif(data: imageData)
    }

    public class func gif(name: String) -> UIImage? {
        guard let bundleURL = Bundle.main.url(forResource: name, withExtension: "gif") else { return nil }
        guard let imageData = try? Data(contentsOf: bundleURL) else { return nil }
        return gif(data: imageData)
    }

    class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1

        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        defer { gifPropertiesPointer.deallocate() }

        if CFDictionaryGetValueIfPresent(cfProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque(), gifPropertiesPointer) == false {
            return delay
        }

        let gifProperties: CFDictionary = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)
        var delayObject: AnyObject = unsafeBitCast(CFDictionaryGetValue(gifProperties, Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()), to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }

        if let delayObject = delayObject as? Double, delayObject > 0 {
            delay = delayObject
        }

        return delay
    }

    class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }

        if a! < b! {
            let c = a
            a = b
            b = c
        }

        var rest: Int
        while true {
            rest = a! % b!

            if rest == 0 {
                return b!
            } else {
                a = b
                b = rest
            }
        }
    }

    class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }

        var gcd = array[0]

        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }

        return gcd
    }

    class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()

        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }

            let delaySeconds = UIImage.delayForImageAtIndex(Int(i), source: source)
            delays.append(Int(delaySeconds * 1000.0))
        }

        let duration: Int = {
            var sum = 0

            for val: Int in delays {
                sum += val
            }

            return sum
        }()

        let gcd = gcdForArray(delays)
        var frames = [UIImage]()

        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)

            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }

        let animation = UIImage.animatedImage(with: frames, duration: Double(duration) / 1000.0)

        return animation
    }
    
    func withTintColor(_ color: UIColor) -> UIImage? {
        let image = self.withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.set()
        image.draw(in: CGRect(origin: .zero, size: size))
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage
    }
    
    func withRoundedCorners(radius: CGFloat) -> UIImage? {
        let rect = CGRect(origin: .zero, size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()
        
        let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
        context?.addPath(path.cgPath)
        context?.clip()
        
        self.draw(in: rect)
        
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return roundedImage
    }
}


extension UILabel {
    static func labelLayout(text:String?, font:UIFont, textColor:UIColor, ali:NSTextAlignment, isPriority:Bool, tag:Int) -> UILabel{
        let lab = UILabel()
    //    富文本
        if (text != nil) {
            let  dic = [NSAttributedString.Key.kern : 0.0]
            let attributedString  = NSMutableAttributedString.init(string: text ?? "", attributes: dic)
            let paragraphStyle = NSMutableParagraphStyle.init()
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text?.count ?? 0))
            lab.attributedText = attributedString
        }
        lab.textColor = textColor
        lab.font = font
        lab.textAlignment = ali
        lab.backgroundColor = .clear
        if isPriority == true {
            lab.setContentCompressionResistancePriority(.required, for: .horizontal)
            lab.setContentHuggingPriority(.required, for: .horizontal)
            lab.setContentCompressionResistancePriority(.required, for: .vertical)
            lab.setContentHuggingPriority(.required, for: .vertical)
        }
        lab.tag = tag
        return lab
        
    }
    
    func markAsRequired() {
        let requiredLabel = UILabel.labelLayout(text: "*", font: FontSizes.regular13, textColor: AppColors.c_FF995B, ali: .left, isPriority: true, tag: 0)
        self.superview?.addSubview(requiredLabel)
        
        requiredLabel.snp.makeConstraints { make in
            make.trailing.equalTo(self.snp.leading).offset(-4)
            make.centerY.equalTo(self)
        }
    }
}

extension UIButton {
    
    // 便利构造函数，用于创建自定义按钮
    convenience init(title: String = "",
                     backgroundColor: UIColor = .white,
                     titleColor: UIColor = .white,
                     font: UIFont = FontSizes.medium16,
                     alignment: UIControl.ContentHorizontalAlignment = .center,
                     image: UIImage? = nil) {
        self.init(type: .custom) // 选择按钮类型，这里使用.custom
        self.setTitle(title, for: .normal)
        self.backgroundColor = backgroundColor
        self.setTitleColor(titleColor, for: .normal)
        self.titleLabel?.font = font
        self.contentHorizontalAlignment = alignment
        self.setImage(image, for: .normal)
        self.adjustsImageWhenHighlighted = false  // 禁用高亮状态变灰
        if image != nil {
            self.imageView?.contentMode = .scaleToFill
            self.imageView
        }
    }
    
    /// 左标题右图片
    func adjustTitleAndImage(spacing: CGFloat = 8) {
        guard let imageSize = self.imageView?.frame.size,
              let text = self.titleLabel?.text,
              let font = self.titleLabel?.font else { return }

        let titleSize = text.size(withAttributes: [NSAttributedString.Key.font: font])

        let totalWidth = titleSize.width + imageSize.width + spacing
        
        // Image右边距增加文字宽度和额外间距
        self.imageEdgeInsets = UIEdgeInsets(
            top: 0,
            left: titleSize.width + spacing,
            bottom: 0,
            right: -(titleSize.width + spacing)
        )
        
        // Title左边距减去图片宽度和额外间距
        self.titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: -(imageSize.width + spacing),
            bottom: 0,
            right: imageSize.width + spacing
        )
        
        // 增加按钮的内容边距以防止内容挤在按钮边缘
        let edgeOffset = abs(titleSize.width - imageSize.width) / 2
        self.contentEdgeInsets = UIEdgeInsets(
            top: 0,
            left: edgeOffset + spacing,
            bottom: 0,
            right: edgeOffset + spacing
        )
    }
    
    //上图片下文字
    func alignImageAboveLabel(withSpacing spacing: CGFloat) {
        guard let imageSize = self.imageView?.image?.size,
              let text = self.titleLabel?.text,
              let font = self.titleLabel?.font else { return }

        let titleSize = text.size(withAttributes: [NSAttributedString.Key.font: font])
        let totalHeight = imageSize.height + titleSize.height + spacing

        self.imageEdgeInsets = UIEdgeInsets(
            top: -(totalHeight - imageSize.height),
            left: 0,
            bottom: 0,
            right: -titleSize.width
        )

        self.titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: -imageSize.width,
            bottom: -(totalHeight - titleSize.height),
            right: 0
        )
    }
    
}

extension UITextField {

    convenience init(placeholder: String,
                     font: UIFont,
                     textColor: UIColor,
                     borderStyle: UITextField.BorderStyle,
                     keyboardType: UIKeyboardType,
                     isSecureTextEntry: Bool = false,
                     clearButtonMode: UITextField.ViewMode = .never) {
        self.init(frame: .zero)
        self.placeholder = placeholder
        self.font = font
        self.textColor = textColor
        self.borderStyle = borderStyle
        self.keyboardType = keyboardType
        self.isSecureTextEntry = isSecureTextEntry
        self.clearButtonMode = clearButtonMode
    }
}




extension UIStackView {
    convenience init(axis: NSLayoutConstraint.Axis,
                     spacing: CGFloat = 0,
                     distribution: UIStackView.Distribution = .fill,
                     alignment: UIStackView.Alignment = .fill){
        self.init()
        self.axis = axis
        self.spacing = spacing
        self.distribution = distribution
        self.alignment = alignment
        
    }
}

extension UIViewController {
    
    /// 从给定的视图获取最近的视图控制器
    /// - Parameter view: 要查找其所属视图控制器的视图
    /// - Returns: 找到的视图控制器，如果没找到则返回nil
    static func findViewController(from view: UIView) -> UIViewController? {
        // 如果视图是UITableViewCell，查找其所属的UITableView
        if let cell = view as? UITableViewCell, let tableView = cell.superview as? UITableView {
            return findViewController(from: tableView)
        }
        
        // 如果视图是UICollectionViewCell，查找其所属的UICollectionView
        if let cell = view as? UICollectionViewCell, let collectionView = cell.superview as? UICollectionView {
            return findViewController(from: collectionView)
        }
        
        // 递归向上查找视图层级
        var responder: UIResponder? = view
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        
        return nil
    }
    
    func topMostViewController() -> UIViewController {
        if let presented = self.presentedViewController {
            return presented.topMostViewController()
        }
        
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }
        
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        
        return self
    }
}

/// 获取当面视图的导航控制器
extension UINavigationController {
    static func getCurrentNavigationController() -> UINavigationController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return nil }

        for window in windowScene.windows {
            if let rootViewController = window.rootViewController {
                var currentController: UIViewController = rootViewController
                while let presentedController = currentController.presentedViewController {
                    currentController = presentedController
                }

                // 找到最顶层的 NavigationController
                if let navigationController = findTopmostNavigationController(in: currentController) {
                    return navigationController
                }
            }
        }
        return nil
    }

    private static func findTopmostNavigationController(in viewController: UIViewController) -> UINavigationController? {
        if let navigationController = viewController as? UINavigationController {
            return navigationController
        } else if let tabBarController = viewController as? UITabBarController {
            if let selectedNavigationController = tabBarController.selectedViewController as? UINavigationController {
                return selectedNavigationController
            }
        }
        return viewController.navigationController
    }
}




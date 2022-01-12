//
//  SNTabBar.swift
//  SNTabBarDemo-Swift
//
//  Created by ShawnWong on 2022/1/11.
//

import UIKit

protocol SNTabBarDelegate: NSObjectProtocol {
    /// callback selected index
    func sn_tabBarDidSelectItem(tabBar: SNTabBar, tabBarItem: SNTabBarItem)
}

class SNTabBar: UIView, CAAnimationDelegate {
    
// MARK: - private porperty
    private var itemCount: Int = 0
    private let kScreenWidth = UIScreen.main.bounds.size.width
    private var _lastClickItem: SNTabBarItem?
    private var _lastItemPointX: CGPoint = CGPoint.zero
    
// MARK: - public porperty
    weak var delegate: SNTabBarDelegate?
    
    public var items = [SNTabBarItem]() {
        didSet {
            if items.count > 0 {
                let btnW: CGFloat = kScreenWidth / CGFloat(items.count)
                for (index, item) in items.enumerated() {
                    item.frame = CGRect.init(x: btnW * CGFloat(index), y: 0, width: btnW, height: 49)
                    item.tag = 10000 + index;
                    item.addTarget(self, action: #selector(itemTapAction(item:)), for: UIControl.Event.touchUpInside)
                    self.addSubview(item)
                    
                    if index == selectedIndex {
                        _lastClickItem = item
                        item.isSelected = true
                    }
                }
            }
        }
    }
    
    /// set bar backgroud color. default is white color. If a background image is set, the background color will not be valid
    public var barTintColor: UIColor! {
        didSet {
            if(barTintColor != nil) {
                self.backgroudLayer.backgroundColor = barTintColor.cgColor
            }
        }
    }
    
    /// set bar backgroud image
    public var backgroudImage: UIImage! {
        didSet {
            if(backgroudImage != nil) {
                self.backgroudLayer.contents = backgroudImage.cgImage
                self.backgroudLayer.contentsGravity = CALayerContentsGravity(rawValue: "resizeAspectFill")
                self.backgroudLayer.contentsScale = UIScreen.main.scale
            }
        }
    }
    
    public var selectedIndex: NSInteger {
        didSet {
            self.setupBackgroudMaskLayerPathWithSelectedIndex(selectedIndex: selectedIndex)
            self.setIndicatorLayerAnimationWithSelectedIndex(selectedIndex: selectedIndex)
        }
    }
    
    public var indicatorColors = [UIColor]() {
        didSet {
            if (indicatorColors.count == 2) {
                let colors = NSMutableArray()
                for item: UIColor in indicatorColors {
                    colors.add(item.cgColor)
                }
                self.indicatoGradientLayer.colors = colors as? [Any]
            }
        }
    }
    
// MARK: - private porperty
    private var origTabBar: UITabBar?
    private let safeAreaH: CGFloat = 34.0
    private let indicatorR: CGFloat = 28.0
    
    lazy private var backgroudLayer: CAShapeLayer   = self.initialBackgroudLayer()
    lazy private var bezierMaskLayer: CAShapeLayer  = self.initialBezierMaskLayer()
    private let bezierPath: UIBezierPath = UIBezierPath()
    
    lazy private var indicatorLayer: CAShapeLayer  = self.initialIndicatorLayer()
    lazy private var indicatoGradientLayer: CAGradientLayer  = self.initialIndicatorGradientLayer()
    
// MARK: - init
    override init(frame: CGRect) {
        self.selectedIndex = 0;
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroudLayer.frame = CGRect.init(x: 0, y: 0, width: self.origTabBar!.bounds.width, height: self.origTabBar!.bounds.height)
        self.indicatoGradientLayer.frame = self.indicatorLayer.bounds
    }

    /// 便利构造器
    /// - Parameters:
    ///   - frame: frame description
    ///   - nativeTabBar: nativeTabBar description
    convenience init(frame: CGRect, nativeTabBar: UITabBar){
        
        self.init(frame: frame)
        self.origTabBar = nativeTabBar
        self.itemCount = nativeTabBar.items!.count
        
        self.backgroudLayer.mask = self.bezierMaskLayer
        self.layer.addSublayer(backgroudLayer)
        
        self.indicatorLayer.addSublayer(indicatoGradientLayer)
        self.layer.addSublayer(indicatorLayer)
    }
    
// MARK: - Method
    private func setupBackgroudMaskLayerPathWithSelectedIndex(selectedIndex: NSInteger) {
        
        let offsetX = 30.0
        let cornerDeep = 49.0
        let itemW = kScreenWidth / CGFloat(self.itemCount)
        
        self.bezierPath.removeAllPoints()
        self.bezierPath.move(to: CGPoint.init(x: 0, y: 0))
        
        let p1X: CGFloat = itemW * CGFloat(selectedIndex) - offsetX
        self.bezierPath.addLine(to: CGPoint.init(x: p1X, y: 0))
        
        let p2X: CGFloat = itemW * (CGFloat(selectedIndex) + 0.5)
        let c1PX: CGFloat = itemW * CGFloat(selectedIndex) + 10
        let c2PX: CGFloat = itemW * CGFloat(selectedIndex) + 10
        self.bezierPath.addCurve(to: CGPoint.init(x: p2X, y: cornerDeep),
                                  controlPoint1: CGPoint.init(x: c1PX, y: 4),
                                  controlPoint2: CGPoint.init(x: c2PX, y: 46))
        
        let p3X: CGFloat = itemW * (CGFloat(selectedIndex) + 1) + offsetX
        let c3PX: CGFloat = itemW * (CGFloat(selectedIndex) + 1) - 10
        let c4PX: CGFloat = itemW * (CGFloat(selectedIndex) + 1) - 10
        self.bezierPath.addCurve(to: CGPoint.init(x: p3X, y: 0),
                                  controlPoint1: CGPoint.init(x: c3PX, y: 46),
                                  controlPoint2: CGPoint.init(x: c4PX, y: 4))
        
        self.bezierPath.addLine(to: CGPoint.init(x: kScreenWidth, y: 0))
        self.bezierPath.addLine(to: CGPoint.init(x: kScreenWidth, y: self.origTabBar!.bounds.height+safeAreaH))
        self.bezierPath.addLine(to: CGPoint.init(x: 0, y: self.origTabBar!.bounds.height+safeAreaH))
        self.bezierPath.close()
        self.bezierMaskLayer.path = self.bezierPath.cgPath
    }
    
    private func setIndicatorLayerAnimationWithSelectedIndex(selectedIndex: NSInteger) {
        
        let itemCenter = kScreenWidth / CGFloat(self.itemCount) / 2
        let startPoint = CGPoint.init(x: self.indicatorLayer.position.x, y: self.indicatorLayer.position.y)
        let endPoint = CGPoint.init(x: itemCenter * (CGFloat(selectedIndex) * 2 + 1), y: 0)
        
        // 创建关键帧动画并设置动画属性
        let keyFrameAnimation = CAKeyframeAnimation.init(keyPath: "position")
        keyFrameAnimation.delegate = self
        keyFrameAnimation.duration = 0.5
        keyFrameAnimation.isRemovedOnCompletion = false
        keyFrameAnimation.fillMode = .forwards
        keyFrameAnimation.calculationMode = CAAnimationCalculationMode.paced
        
        let mutablePath = CGMutablePath()
        mutablePath.move(to: startPoint)

        let cPX = abs(endPoint.x - startPoint.x) / 2.0 + (startPoint.x > endPoint.x ? endPoint.x : startPoint.x)
        mutablePath.addQuadCurve(to: endPoint, control: CGPoint.init(x: cPX, y: -80))
        
        mutablePath.addLine(to: endPoint)
        mutablePath.addLine(to: CGPoint.init(x: endPoint.x, y: 25))
        mutablePath.addLine(to: endPoint)
        keyFrameAnimation.path = mutablePath
        
        self.indicatorLayer.add(keyFrameAnimation, forKey: "myAnimation")
        _lastItemPointX = endPoint;
    }
    
    @objc private func itemTapAction(item: SNTabBarItem) {
        if item.isSelected {
            return
        } else {
            item.isSelected = true
            _lastClickItem?.isSelected = false
        }
        self.selectedIndex = item.tag - 10000
        _lastClickItem = item
        
        if delegate != nil {
            delegate?.sn_tabBarDidSelectItem(tabBar: self, tabBarItem: item)
        }
    }
    
// MARK: - CAAnimationDelegate
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if(self.indicatorLayer.animation(forKey: "myAnimation") == anim){
            self.indicatorLayer.position = _lastItemPointX
        }
    }
 
// MARK: - Initial
    private func initialBackgroudLayer() -> CAShapeLayer {
        let bgLayer = CAShapeLayer()
        bgLayer.backgroundColor = UIColor.white.cgColor
        return bgLayer
    }
    
    private func initialBezierMaskLayer() -> CAShapeLayer {
        let maskLayer = CAShapeLayer()
        return maskLayer
    }
    
    private func initialIndicatorLayer() -> CAShapeLayer {
        let indicatorBg = CAShapeLayer()
        indicatorBg.frame = CGRect.init(x: -indicatorR*2, y: 0, width: indicatorR*2, height: indicatorR*2)
        indicatorBg.backgroundColor = UIColor.red.cgColor
        
        let circlePath = UIBezierPath.init(arcCenter: CGPoint.init(x: indicatorR, y: indicatorR),
                                           radius: indicatorR, startAngle: 0, endAngle: Double.pi*2, clockwise: false)
        let maskLayer = CAShapeLayer()
        maskLayer.path = circlePath.cgPath
        indicatorBg.mask = maskLayer
        
        return indicatorBg
    }
    
    private func initialIndicatorGradientLayer() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 1.0)
        gradientLayer.endPoint = CGPoint.init(x: 0.8, y: 0)
        gradientLayer.colors = [UIColor.init(_colorLiteralRed: 0.58, green: 0.08, blue: 0.40, alpha: 1.0).cgColor,
                                UIColor.init(_colorLiteralRed: 0.92, green: 0.42, blue: 0.67, alpha: 1.0).cgColor]
        return gradientLayer;
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

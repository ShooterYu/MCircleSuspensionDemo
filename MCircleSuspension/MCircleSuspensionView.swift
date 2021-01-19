//
//  MCircleSuspensionView.swift
//  MCircleSuspensionDemo
//
//  Created by lixin.yu on 2021/1/17.
//

import UIKit
import Foundation

protocol MCircleSuspensionViewDelegate: NSObjectProtocol {
    func didClickCircle(model: CircleModel)
}

class MCircleSuspensionView: UIView {
    weak var delegate: MCircleSuspensionViewDelegate?
    var circleModels: [CircleModel]? {
        didSet {
            self.circleModels = self.circleModels?.map({ model -> CircleModel in
                if let text = model.text, text.count > 0, model.radius == defaultRadius {
                    let width = text.count / 2 * defaultFontSize
                    let defaultWidth = Int(defaultRadius) * 2 - defaultInset * 2
                    var tmpModel = model
                    if width > defaultWidth {
                        let inset = (width * defaultInset) / (Int(defaultRadius) * 2)
                        tmpModel.radius = CGFloat(width / 2 + inset)
                        return tmpModel
                    }
                }
                return model
            })
            self.drawCircles()
        }
    }
    
    private var drawsModel = [CircleModel]()
    
    //new
    private lazy var randomPointArray: [CGPoint] = {
        let width = self.bounds.width
        let height = self.bounds.height
        return [CGPoint(x: 0, y: 0),
                CGPoint(x: width, y: height),
                CGPoint(x: 0, y: height / 2),
                CGPoint(x: width, y: height/2),
                CGPoint(x: width / 2, y: 0),
                CGPoint(x: width / 2, y: height),
                CGPoint(x: 0, y: height),
                CGPoint(x: width, y: 0)]
    }()
    private var _nextJoinPointIndex: Int?
    private var nextJoinPointIndex: Int? {
        get {
            return _nextJoinPointIndex
        }
        set {
            if newValue == self.randomPointArray.count - 1 {
                _nextJoinPointIndex = 0
            } else {
                _nextJoinPointIndex = newValue
            }
        }
    }
    private var startIndex = -1
    
    private func drawCircles() {
        guard let tCircleModel = circleModels else {
            return
        }
        self.clearAll()
        self.drawsModel.removeAll()
        self.nextJoinPointIndex = 0
        self.startIndex = -1
        for model in tCircleModel {
            self.realyDrawCircel(model: model)
        }
    }
    
    private func clearAll() {
        self.subviews.forEach({ $0.removeFromSuperview()});
    }
    
    private func generateCircleBtn(model: CircleModel) -> UIButton {
        let btn = UIButton()
        let width = model.radius*2
        btn.bounds = CGRect(x: 0, y: 0, width: width, height: width)
        btn.center = model.centerPoint
        btn.setTitle(model.text, for: .normal)
        btn.titleLabel?.textAlignment = .center
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.titleLabel?.numberOfLines = 2
        let distance = (width * CGFloat(defaultInset)) / (defaultRadius * 2)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: distance, bottom: 0, right: distance)
        btn.backgroundColor = model.color
        btn.layer.cornerRadius = CGFloat(model.radius)
        btn.addTarget(self, action: #selector(btnTouched(sender:)), for: .touchDown)
        return btn
    }
    
    private func checkIfCanDrawCircle(model: CircleModel) -> Bool {
        let width = self.bounds.width
        let height = self.bounds.height
        for tmpModel in drawsModel {
            let limitExtentiion = tmpModel.radius * 2 / 4
            if tmpModel.centerPoint.x > width + limitExtentiion ||
                tmpModel.centerPoint.x < -limitExtentiion ||
                tmpModel.centerPoint.y > height + limitExtentiion || tmpModel.centerPoint.y < -limitExtentiion {
                return false
            }
            if self.sqrtNum(first: tmpModel.centerPoint, second: model.centerPoint) < tmpModel.radius + model.radius {
                return false
            }
        }
        self.drawsModel.append(model)
        return true
    }
    
    private func sqrtNum(first: CGPoint, second: CGPoint) -> CGFloat {
        return sqrt(pow(first.x - second.x, 2) + pow(first.y - second.y, 2))
    }
    
    private func generateRandomPoint() -> CGPoint {
        let index = Int(arc4random_uniform(UInt32(self.randomPointArray.count)))
        return self.randomPointArray[index]
    }
    
    private func findTwoShortDistancePoint(point: CGPoint) -> (CGPoint, CGPoint) {
        if self.drawsModel.count >= 2 {
            var firstPoint = self.drawsModel[0].centerPoint
            var secontPoint = self.drawsModel[1].centerPoint
            for model in self.drawsModel {
                if model.centerPoint != firstPoint && model.centerPoint != secontPoint {
                    let distance = self.sqrtNum(first: model.centerPoint, second: point)
                    if distance < self.sqrtNum(first: firstPoint, second: point) {
                        firstPoint = model.centerPoint
                    } else if distance < self.sqrtNum(first: secontPoint, second: point) {
                        secontPoint = model.centerPoint
                    }
                }
            }
            return (firstPoint, secontPoint)
        }
        return (.zero, .zero)
    }
    
    private func realyDrawCircel(model: CircleModel) {
        var tmpModel = model
        if self.drawsModel.isEmpty {
            tmpModel.centerPoint = self.center
            let btn = self.generateCircleBtn(model: tmpModel)
            self.addSubview(btn)
            self.drawsModel.append(tmpModel)
            return
        } else if self.drawsModel.count == 1 {
            self.clearAll()
            var firstModel = self.drawsModel.first!
            let width = self.bounds.width
            let height = self.bounds.height
            firstModel.centerPoint = CGPoint(x: width/2 - firstModel.radius, y: height/2 + firstModel.radius)
            let btn = self.generateCircleBtn(model: firstModel)
            self.addSubview(btn)

            tmpModel.centerPoint = CGPoint(x: width/2 + tmpModel.radius, y: height/2 - tmpModel.radius)
            let btn1 = self.generateCircleBtn(model: tmpModel)
            self.addSubview(btn1)
            self.drawsModel.append(tmpModel)
            return
        } else {
            guard let nextPointIndex = self.nextJoinPointIndex, self.startIndex != nextPointIndex else {
                return
            }
            let randomPoint = self.randomPointArray[nextPointIndex]
            let twoPoint = self.findTwoShortDistancePoint(point: randomPoint)
            let equleSideLength = model.radius + tmpModel.radius + 4
            let otherSideLength = self.sqrtNum(first: twoPoint.0, second: twoPoint.1)
            if let resultCenter = self.caculateThirdPoint(point:randomPoint, pointA: twoPoint.0, pointB: twoPoint.1, a: equleSideLength, b: equleSideLength, c: otherSideLength) {
                tmpModel.centerPoint = resultCenter
                if self .checkIfCanDrawCircle(model: tmpModel) {
                    let btn = self.generateCircleBtn(model: tmpModel)
                    self.addSubview(btn)
                    self.drawsModel.append(tmpModel)
                    self.startIndex = nextPointIndex
                    self.nextJoinPointIndex = nextPointIndex + 1
                } else {
                    self.nextJoinPointIndex = nextPointIndex + 1
                    self.realyDrawCircel(model: tmpModel)
                }
            } else {
                self.nextJoinPointIndex = nextPointIndex + 1
                self.realyDrawCircel(model: tmpModel)
            }
        }
    }
    
    private func caculateThirdPoint(point: CGPoint, pointA: CGPoint, pointB: CGPoint, a: CGFloat, b: CGFloat, c: CGFloat) -> CGPoint? {
        if (a <= 0 || b <= 0 || c <= 0) {
            return nil
        }
        let cosA = (b * b + c * c - a * a) / (2 * b * c)
        var angleA = acosf(Float(cosA))
        if point.x == self.bounds.width || (point.x == self.bounds.width / 2 && point.y == self.bounds.height) {
            angleA = -angleA
        }
        let vAC = atanf(Float((pointB.y - pointA.y) / (pointB.x - pointA.x))) - angleA
        let tmpX = pointA.x + b * CGFloat(cos(vAC))
        let tmpY = pointA.y + b * CGFloat(sin(vAC))
        if tmpX.isNaN || tmpY.isNaN {
            return nil
        }
        return CGPoint(x: tmpX, y: tmpY)
    }
    
    @objc func btnTouched(sender: UIButton) {
        guard let tCircleModels = self.circleModels else {
            return
        }
        for model in tCircleModels {
            if let text = model.text, let btnText = sender.title(for: .normal), text == btnText {
                self.delegate?.didClickCircle(model: model)
            }
        }
    }
}

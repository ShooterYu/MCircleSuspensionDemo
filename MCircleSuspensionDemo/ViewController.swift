//
//  ViewController.swift
//  MCircleSuspensionDemo
//
//  Created by lixin.yu on 2021/1/16.
//

import UIKit

class ViewController: UIViewController, MCircleSuspensionViewDelegate {
    let circleSusView = MCircleSuspensionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 300))
    
    lazy var modelArray: [CircleModel] = {
        var modelArray = [CircleModel]()
        for i in 0...4 {
            var model = CircleModel()
            model.text = "\(i)"
            modelArray.append(model)
        }
        return modelArray
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.addSubview(circleSusView)
        circleSusView.circleModels = modelArray
        circleSusView.delegate = self
        circleSusView.backgroundColor = .white
        
        let btn = UIButton(frame: CGRect(x: self.view.bounds.width / 2 - 25, y: self.view.bounds.height - 50, width: 50, height: 50))
        btn.setTitle("重绘", for:.normal)
        btn.backgroundColor = .black
        btn.addTarget(self, action: #selector(reDrawBtnTouched), for: .touchUpInside)
        self.view.addSubview(btn)
        
        self.view.backgroundColor = .blue
    }
    
    @objc func reDrawBtnTouched() {
        self.circleSusView.circleModels = self.modelArray
    }
    
    func didClickCircle(model: CircleModel) {
        print("点击了\(model.text ?? "")")
    }
}




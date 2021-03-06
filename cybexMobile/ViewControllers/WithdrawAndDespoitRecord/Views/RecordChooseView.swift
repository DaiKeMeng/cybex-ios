//
//  RecordChooseView.swift
//  cybexMobile
//
//  Created DKM on 2018/9/24.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

enum RecordChooseViewType: Int {
    case name = 0
    case type
}

@IBDesignable
class RecordChooseView: CybexBaseView {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var stateImage: UIImageView!

    @IBInspectable var name: String = "" {
        didSet {
            nameLabel.locali = name
        }
    }

    @IBInspectable var content: String = "" {
        didSet {
            contentLabel.locali = content
        }
    }

    @IBInspectable var subtype: Int = 0 {
        didSet {

        }
    }

    enum Event: String {
        case recordChooseViewDidClicked
        case recordContainerViewDidClicked
        case presentChooseVC
    }

    override func setup() {
        super.setup()

        setupUI()
        setupSubViewEvent()
    }

    func setupUI() {
        clearBgColor()
    }

    func setupSubViewEvent() {
        self.containerView.rx.tapGesture().when(UIGestureRecognizer.State.recognized).asObservable().subscribe(onNext: { [weak self](_) in
            guard let `self` = self else { return }
            self.contentLabel.textColor = UIColor.pastelOrange
            self.stateImage.image = R.image.ic()
            self.next?.sendEventWith(Event.recordContainerViewDidClicked.rawValue, userinfo: ["index": self.subtype, "self": self])
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }

    @objc override func didClicked() {
        self.next?.sendEventWith(Event.recordChooseViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
}

extension RecordChooseView {

}

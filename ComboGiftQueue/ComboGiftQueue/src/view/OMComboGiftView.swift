//
//  OMComboGiftView.swift
//  GifttingBannerDemo
//
//  Created by 黄凯文 on 2023/4/22.
//

import Foundation
import UIKit

/// 连击礼物横幅视图
class OMComboGiftView: UIView {

    /// 礼物名称标签
    private lazy var giftNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.red
        return label
    }()

    /// 礼物数量标签
    private lazy var giftCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.blue
        return label
    }()

    private(set) var model: OMComboGiftModel
    
    required init(gift: OMComboGiftModel) {
        self.model = gift
        super.init(frame: .zero)
        setupView()
        updateView(model: model)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        layer.cornerRadius = 26
        layer.masksToBounds = true
        backgroundColor = .lightGray
        addSubview(giftNameLabel)
        addSubview(giftCountLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        giftNameLabel.frame = CGRect(x: layer.cornerRadius, y: 0, width: bounds.width, height: bounds.height * 0.5)
        giftCountLabel.frame = CGRect(x: layer.cornerRadius, y: bounds.height * 0.5, width: bounds.width, height: bounds.height * 0.5)
    }

    func updateView(model: OMComboGiftModel?) {
        giftNameLabel.text = "\(model?.innerIndex ?? 0)"
        giftCountLabel.text = "x\(model?.totalValue ?? 0)"
    }

}

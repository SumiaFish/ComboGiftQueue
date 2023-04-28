//
//  ViewController.swift
//  ComboGiftQueue
//
//  Created by kevin on 2023/4/28.
//

import UIKit

class ViewController: UIViewController {
    /// 连击礼物队列播放器
    private lazy var player = OMComboGiftPlayer(config: .init())

    /// 定时器
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        let button = UIButton(type: .system)
        view.addSubview(button)
        button.setTitle("hhhhhh", for: .normal)
        button.frame = CGRect(x: 0, y: 64, width: 100, height: 30)

        view.addSubview(player)
        player.frame = CGRect(x: 20, y: 100, width: 300, height: 300)
        test()
    }

    var giftIds = Set<String>()
    /// 模拟连击礼物
    func test() {
//        for i in 0..<1000 {
//            let originalModel = OMOriginalModel(id: UUID().uuidString, senderName: "", value: Int.random(in: 1...100))
//            let comboInfoModel = OMComboInfoModel(id: originalModel.id, originalModel: originalModel)
//            giftIds.insert(comboInfoModel.id)
//            player.queue.update(comboInfoModel: comboInfoModel)
//        }

        /// 一个随机数
        var random = Int.random(in: 0...1000)
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            /// 如果随机数是奇数则添加
            if random % 2 == 1 {
                let originalModel = OMOriginalModel(id: UUID().uuidString, senderName: "", value: Int.random(in: 1...100))
                let comboInfoModel = OMComboInfoModel(id: originalModel.id, originalModel: originalModel)
                self.player.queue.update(comboInfoModel: comboInfoModel)
                self.giftIds.insert(comboInfoModel.id)
            } else {
                /// 如果随机数是偶数则更新

                for _ in 0..<random {
                    if let id = self.giftIds.first,
                        let _ = self.player.queue.giftsMap[id] {
                        let originalModel = OMOriginalModel(id: id, senderName: "", value: Int.random(in: 1...100))
                        let comboInfoModel = OMComboInfoModel(id: originalModel.id, originalModel: originalModel)
                        self.player.queue.update(comboInfoModel: comboInfoModel)
                    }
                }
            }
            /// 重新生成随机数
            random = Int.random(in: 0...100)
        }
    }

}


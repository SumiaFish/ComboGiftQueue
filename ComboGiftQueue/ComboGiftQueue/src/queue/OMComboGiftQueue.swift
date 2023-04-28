//
//  OMComboGift.swift
//  GifttingBannerDemo
//
//  Created by kevin on 2023/4/21.
//

import Foundation
import Combine

/// 连击礼物队列配置结构体
struct OMComboGiftQueueConfig {
    var maxLength: Int = 5
    var displayDuration: Double = 5.5
    var updateDurationTimeInterval = 0.2
    var sortStrategy: OMComboGiftSortStrategy = OMComboGiftSortStrategyIndex()
    var indexGenerator: OMComboGiftQueueIndexGenerator = OMComboGiftDefaultIndexGenerator()
}

/// 连击礼物队列
class OMComboGiftQueue {

    private var topGiftIds = [String]()
    private var soredGifts = [OMComboGiftModel]()
    private(set) var giftsMap: [String: OMComboGiftModel] = [:]
    private var timer = DispatchSource.makeTimerSource()

    private(set) var config: OMComboGiftQueueConfig

    var onChange: ([OMComboGiftModel]) -> Void = { _ in }
    var onUpdate: ([OMComboGiftModel]) -> Void = { _ in }

    deinit {
        timer.cancel()
    }

    required init(config: OMComboGiftQueueConfig) {
        self.config = config
        start()
    }

    private func start() {
        weak var weakSelf = self
        timer.schedule(deadline: .now(), repeating: config.updateDurationTimeInterval)
        timer.setEventHandler {
            DispatchQueue.main.async {
                weakSelf?.updateGiftDuration()
            }
        }
        timer.resume()
    }

    private func updateGiftDuration() {
        var map: [String: OMComboGiftModel] = [:]
        var timeoutGifts = [OMComboGiftModel]()
        for (_, gift) in giftsMap {
            var gift = gift
            gift.update(totalDuration: gift.totalDuration - config.updateDurationTimeInterval)
            if gift.totalDuration > 0 {
                map[gift.id] = gift
            } else {
                timeoutGifts.append(gift)
            }
        }
        giftsMap = map
        soredGifts = map.values.sorted(by: { config.sortStrategy.sort(g1: $0, g2: $1) })
        changeTopGifts(timeoutGifts: timeoutGifts)
    }

    func update(comboInfoModel: OMComboInfoModel) {
        var gift: OMComboGiftModel
        if let g = giftsMap[comboInfoModel.id] {
            gift = g
        } else {
            gift = OMComboGiftModel(id: comboInfoModel.id, innerIndex: config.indexGenerator.next())
        }
        gift.update(comboInfoModel: comboInfoModel)
        gift.update(totalDuration: config.displayDuration)
        giftsMap[gift.id] = gift
        updateTopGifts(gift: gift)
    }

    func updateTopGifts(gift: OMComboGiftModel) {
        if topGiftIds.contains(gift.id) {
            onUpdate([gift])
        }
    }

    func changeTopGifts(timeoutGifts: [OMComboGiftModel]) {
        var gifts = [OMComboGiftModel]()
        timeoutGifts.forEach { gift in
            if topGiftIds.contains(gift.id) {
                topGiftIds.removeAll(where: { $0 == gift.id })
                var gift = gift
                gift.update(status: .failRank)
                gifts.append(gift)
            }
            gifts += getNewTopGifts()
        }
        gifts += getNewTopGifts()
        if gifts.count > 0 {
            onChange(gifts)
        }
    }

    func getNewTopGifts() -> [OMComboGiftModel] {
        guard topGiftIds.count < config.maxLength else {
            return []
        }

        var addGifts = [OMComboGiftModel]()
        for i in 0..<soredGifts.count {
            if topGiftIds.count >= config.maxLength {
                break
            }

            var gift = soredGifts[i]
            if !topGiftIds.contains(gift.id) {
                gift.update(totalDuration: config.displayDuration)
                gift.update(status: .onRank)
                soredGifts[i] = gift
                giftsMap[gift.id] = gift
                topGiftIds.append(gift.id)
                addGifts.append(gift)
            }
        }
        return addGifts
    }

}

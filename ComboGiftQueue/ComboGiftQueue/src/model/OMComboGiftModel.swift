//
//  OMComboGiftModel.swift
//  GifttingBannerDemo
//
//  Created by kevin on 2023/4/21.
//

import Foundation

enum OMComboGiftStatus {
case enqueue
case onRank
case failRank
}

/// 连击礼物显示模型
struct OMComboGiftModel {
    /// id
    private(set) var id: String
    /// 礼物内部使用的序号，uint64
    private(set) var innerIndex: UInt64

    private(set) var totalDuration: Double = 0
    private(set) var totalValue = 0
    private(set) var senderName: String = ""
    private(set) var status: OMComboGiftStatus = .enqueue

    init(
        id: String,
        innerIndex: UInt64
    ) {
        self.id = id
        self.innerIndex = innerIndex
    }

    mutating func update(comboInfoModel: OMComboInfoModel) {
        guard comboInfoModel.id == id else { return }
        senderName = comboInfoModel.originalModel?.senderName ?? ""
        totalValue += (comboInfoModel.originalModel?.value ?? 0)
    }

    mutating func update(totalDuration: Double) {
        self.totalDuration = totalDuration
    }

    mutating func update(status: OMComboGiftStatus) {
        self.status = status
    }
}

/// 礼物连击数据模型
struct OMComboInfoModel {
    let id: String
    let originalModel: OMOriginalModel?
}

struct OMOriginalModel {
    let id: String
    let senderName: String
    let value: Int
}

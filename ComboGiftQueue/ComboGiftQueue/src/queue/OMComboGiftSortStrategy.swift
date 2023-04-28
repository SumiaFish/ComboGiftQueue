//
//  OMComboGiftSortStrategy.swift
//  GifttingBannerDemo
//
//  Created by kevin on 2023/4/21.
//

import Foundation

/// 连击礼物队列排序策略协议
protocol OMComboGiftSortStrategy {
    func sort(g1: OMComboGiftModel, g2: OMComboGiftModel) -> Bool
}

/// 连击礼物按照序号排序策略结构体
struct OMComboGiftSortStrategyIndex: OMComboGiftSortStrategy {
    func sort(g1: OMComboGiftModel, g2: OMComboGiftModel) -> Bool {
        g1.innerIndex < g2.innerIndex
    }
}

/// 连击礼物队列排序策略按照礼物价值从大到小排序结构体
struct OMComboGiftSortStrategyValue: OMComboGiftSortStrategy {
    func sort(g1: OMComboGiftModel, g2: OMComboGiftModel) -> Bool {
        g1.totalValue > g2.totalValue
    }
}

/// 连击礼物队列排序策略自定义排序结构体
struct OMComboGiftSortStrategyCustom: OMComboGiftSortStrategy {
    let sortor: (OMComboGiftModel, OMComboGiftModel) -> Bool
    func sort(g1: OMComboGiftModel, g2: OMComboGiftModel) -> Bool {
        sortor(g1, g2)
    }
}

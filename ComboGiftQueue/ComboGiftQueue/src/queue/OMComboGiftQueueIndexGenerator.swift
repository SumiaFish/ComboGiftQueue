//
//  OMComboGiftIndexGenerator.swift
//  GifttingBannerDemo
//
//  Created by kevin on 2023/4/21.
//

import Foundation

/// 连击礼物序号生成器协议
protocol OMComboGiftQueueIndexGenerator {
    var currentIndex: UInt64 { get }

    mutating func next() -> UInt64
}

/// 连击礼物序号生成器结构体
struct OMComboGiftDefaultIndexGenerator: OMComboGiftQueueIndexGenerator {
    private(set) var currentIndex: UInt64 = 0

    mutating func next() -> UInt64 {
        currentIndex += 1
        return currentIndex
    }
}

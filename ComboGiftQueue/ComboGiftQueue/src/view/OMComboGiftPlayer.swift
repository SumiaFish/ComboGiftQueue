//
//  OMComboGiftPlayer.swift
//  GifttingBannerDemo
//
//  Created by kevin on 2023/4/21.
//

import Foundation
import UIKit
import Combine

/// 连击礼物播放器类
class OMComboGiftPlayer: UIView {

    let bannerViewSpace = CGFloat(8)
    let animationDuration = 0.5
    var bannerViewH: CGFloat {
        (bounds.height - bannerViewSpace * CGFloat(queue.config.maxLength)) / CGFloat(queue.config.maxLength)
    }

    private var currentGifts = [OMComboGiftModel]()

    let queue: OMComboGiftQueue
    let displayQueue: OperationQueue

    init(config: OMComboGiftQueueConfig) {
        self.queue = .init(config: config)
        self.displayQueue = .init()
        displayQueue.maxConcurrentOperationCount = 1
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        clipsToBounds = true

        weak var weakSelf = self
        queue.onChange = { gifts in
            weakSelf?.change(gifts: gifts)
        }

        queue.onUpdate = { gifts in
            weakSelf?.update(gifts: gifts)
        }
    }

    private func change(gifts: [OMComboGiftModel]) {
        let op = OMComboGiftDisplayOperation { [weak self] in
            self?._change(gifts: gifts, op: $0)
        }
        displayQueue.addOperation(op)
    }

    private func _change(gifts: [OMComboGiftModel], op: OMComboGiftDisplayOperation) {

        var delay = 0.0
        gifts.forEach { gift in
            switch gift.status {
            case .enqueue:
                break

            case .onRank:
                currentGifts.append(gift)

                var t = 0.0
                weak var weakSelf = self
                t += _addBannerViews(gifts: [gift])
//                DispatchQueue.main.asyncAfter(deadline: .now() + t) {
//                    t += (weakSelf?._sortBannerViews() ?? 0)
//                }
                delay = max(t, delay)

            case .failRank:
                currentGifts.removeAll(where: { $0.id == gift.id })

                var t = 0.0
                weak var weakSelf = self
                t += _removeBannerViews(gifts: [gift])
//                DispatchQueue.main.asyncAfter(deadline: .now() + t) {
//                    t += (weakSelf?._sortBannerViews() ?? 0)
//                }
                delay = max(t, delay)

            }
        }

        weak var weakSelf = self
        DispatchQueue.main.asyncAfter(deadline: .now() + delay - 0.3) {
            delay += (weakSelf?._sortBannerViews() ?? 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                op.finish()
            }
        }
    }

    private func update(gifts: [OMComboGiftModel]) {
        var currentBannerViewsMap = [String: OMComboGiftView]()
        subviews.compactMap({ $0 as? OMComboGiftView })
            .forEach({ currentBannerViewsMap[$0.model.id] = $0 } )
        gifts.forEach { gift in
            currentBannerViewsMap[gift.id]?.updateView(model: gift)
        }
    }

    @discardableResult
    private func _addBannerViews(gifts: [OMComboGiftModel]) -> Double {
        gifts.forEach { gift in
            let bannerView = OMComboGiftView(gift: gift)
            let h = bannerViewH
            let y = subviews.isEmpty ? 0 : subviews.reduce(0, { max($0, $1.frame.maxY) }) + bannerViewSpace
            bannerView.frame = CGRect(x: 0, y: y, width: self.bounds.width, height: h)
            addSubview(bannerView)
        }
        return 0
    }

    @discardableResult
    private func _removeBannerViews(gifts: [OMComboGiftModel]) -> Double {
        let giftIds = gifts.map { $0.id }

        var removeBannerViews = [OMComboGiftView]()
        subviews
            .compactMap({ $0 as? OMComboGiftView })
            .filter({ giftIds.contains($0.model.id) })
            .forEach { bannerView in
                removeBannerViews.append(bannerView)
                self.animate(duration: self.animationDuration) {
                    bannerView.transform = .init(translationX: -bannerView.bounds.width, y: 0).scaledBy(x: 0.5, y: 0.5)
                    bannerView.alpha = 0
                } completion: { finish in
                    bannerView.removeFromSuperview()
                }
            }
        let removeBannerViewsTotalDuration = removeBannerViews.isEmpty ? 0.0 : animationDuration
        return removeBannerViewsTotalDuration
    }

    @discardableResult
    private func _sortBannerViews() -> Double {
        var currentBannerViewsMap = [String: OMComboGiftView]()
        subviews.compactMap({ $0 as? OMComboGiftView }).forEach({ currentBannerViewsMap[$0.model.id] = $0 } )

        currentGifts.reversed()
            .compactMap({ currentBannerViewsMap[$0.id] })
            .forEach({ bringSubviewToFront($0) })

        var sortBannerViews = [OMComboGiftView]()
        currentGifts.enumerated().forEach { index, gift in
            guard let bannerView = currentBannerViewsMap[gift.id] else { return }
            let h = bannerViewH
            let y = (h + bannerViewSpace) * CGFloat(index)
            let frame = CGRect(x: 0, y: y, width: bounds.width, height: h)
            let needUpdateFrame = bannerView.frame != frame
            if needUpdateFrame {
                sortBannerViews.append(bannerView)
            }
            let duration = needUpdateFrame ? animationDuration : 0
            animate(duration: duration) {
                bannerView.frame = frame
            }
        }
        let sortBannerViewsTotalDuration = sortBannerViews.isEmpty ? 0.0 : animationDuration
        return sortBannerViewsTotalDuration
    }

    private func animate(duration: Double, delay: Double = 0, animations: @escaping ()->Void, completion: ((_ finish: Bool)->Void)? = nil) {
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.95, initialSpringVelocity: 5, options: .curveEaseOut, animations: animations, completion: completion)
    }

}

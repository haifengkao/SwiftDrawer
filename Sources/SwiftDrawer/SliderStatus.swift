//
//  SliderStatus.swift
//  DrawerDemo
//
//  Created by Millman on 2019/6/26.
//  Copyright © 2019 Millman. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

public class SliderStatus: ObservableObject {
    public let objectDidChange = PassthroughSubject<SliderStatus, Never>()
    var parentSize = CGSize.zero
    var sliderWidth: CGFloat {
        switch maxWidth {
        case let .percent(rate):
            return parentSize.width * rate
        case let .width(value):
            return value
        }
    }

    var shadowRadius: CGFloat = 0
    var showRate: CGFloat = 0
    public var currentStatus: ShowStatus = .hide {
        didSet {
            switch currentStatus {
            case .hide:
                showRate = 0
            case .show:
                showRate = 1
            case let .moving(offset):
                let width = parentSize.width / 2
                if type.isLeft {
                    showRate = type.isRear ? 1 - (width - offset) / width : (width + offset) / width
                } else {
                    showRate = (width - offset) / width
                }
            }
            objectDidChange.send(self)
        }
    }

    public var type: SliderType {
        didSet {
            objectDidChange.send(self)
        }
    }

    var maxWidth: SliderWidth = .percent(rate: 0.5) {
        didSet {
            objectDidChange.send(self)
        }
    }

    func sliderOffset() -> CGFloat {
        if type == SliderType.none {
            return CGFloat(0)
        }
        let rearW = sliderWidth
        if type.isRear {
            switch currentStatus {
            case .hide:
                return CGFloat(0.0)
            case let .moving(offset):
                return offset
            case .show:
                return type.isLeft ? rearW : -1.0 * rearW
            }
        } else {
            switch currentStatus {
            case .hide:
                return type.isLeft ? -parentSize.width : parentSize.width
            case let .moving(offset):
                let offset = type.isLeft ? offset : parentSize.width - rearW + offset
                return offset
            case .show:
                return type.isLeft ? CGFloat(0.0) : parentSize.width - rearW
            }
        }
    }

    init(type: SliderType) {
        self.type = type
    }
}

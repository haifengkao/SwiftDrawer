//
//  MainContainer.swift
//  DrawerDemo
//
//  Created by Millman on 2019/6/27.
//  Copyright © 2019 Millman. All rights reserved.
//

import Combine
import SwiftUI
struct MainContainer<Content: View>: View {
    @ObservedObject private var drawerControl: DrawerControl
    @ObservedObject private var leftRear: SliderStatus
    @ObservedObject private var rightRear: SliderStatus

    @State private var gestureCurrent: CGFloat = 0

    let main: AnyView
    private var maxMaskAlpha: CGFloat
    private var maskEnable: Bool
    var anyCancel: AnyCancellable?
    var body: some View {
        GeometryReader { proxy in
            self.generateBody(proxy: proxy)
        } // .animation(.default) // L: why do we need animation here?
    }

    init(content: Content,
         maxMaskAlpha: CGFloat = 0.25,
         maskEnable: Bool = true,
         drawerControl: DrawerControl)
    {
        main = AnyView(content.environmentObject(drawerControl))
        self.maxMaskAlpha = maxMaskAlpha
        self.maskEnable = maskEnable
        self.drawerControl = drawerControl
        leftRear = drawerControl.status[.leftRear] ?? SliderStatus(type: .none)
        rightRear = drawerControl.status[.rightRear] ?? SliderStatus(type: .none)
    }

    func generateBody(proxy: GeometryProxy) -> some View {
        let haveRear: Bool = leftRear.type != SliderType.none || rightRear.type != SliderType.none
        // let maxRadius: CGFloat = haveRear ? max(leftRear.shadowRadius, rightRear.shadowRadius) : CGFloat(0.0)
        let parentSize: CGSize = proxy.size
        if haveRear {
            leftRear.parentSize = parentSize
            rightRear.parentSize = parentSize
        }

        return ZStack {
            self.main
            if maskEnable {
                Color.black.opacity(Double(drawerControl.maxShowRate * self.maxMaskAlpha))
                    .animation(.easeIn(duration: 0.15))
                    .onTapGesture {
                        self.drawerControl.hideAllSlider()
                    }.padding(EdgeInsets(top: -proxy.safeAreaInsets.top, leading: CGFloat(0.0), bottom: -proxy.safeAreaInsets.bottom, trailing: CGFloat(0.0)))
            }
        }
        .offset(x: offset, y: 0)
        // .shadow(radius: maxRadius) // enable shadow will make EpisodeContent unscrollable, dunno why. note: this shadow applies to all subviews, why is it needed?
        .gesture(DragGesture().onChanged { (value: DragGesture.Value) in
            let will: CGFloat = self.offset + CGFloat(value.translation.width - self.gestureCurrent)
            if self.leftRear.type != SliderType.none {
                let range: ClosedRange<CGFloat> = CGFloat(0) ... self.leftRear.sliderWidth
                if range.contains(will) {
                    self.leftRear.currentStatus = ShowStatus.moving(offset: will)
                    self.gestureCurrent = value.translation.width
                }
            }

            if self.rightRear.type != SliderType.none {
                let range: ClosedRange<CGFloat> = CGFloat(-1.0 * self.rightRear.sliderWidth) ... CGFloat(0)
                if range.contains(will) {
                    self.rightRear.currentStatus = ShowStatus.moving(offset: will)
                    self.gestureCurrent = value.translation.width
                }
            }
        }.onEnded { (value: DragGesture.Value) in
            let will: CGFloat = self.offset + (value.translation.width - self.gestureCurrent)
            if self.leftRear.type != SliderType.none {
                let range = 0 ... self.leftRear.sliderWidth
                self.leftRear.currentStatus = will - range.lowerBound > range.upperBound - will ? ShowStatus.show : ShowStatus.hide
            }
            if self.rightRear.type != SliderType.none {
                let range = (-self.rightRear.sliderWidth) ... 0
                self.rightRear.currentStatus = will - range.lowerBound < range.upperBound - will ? ShowStatus.show : ShowStatus.hide
            }
            self.gestureCurrent = 0
        })
    }

    var offset: CGFloat {
        switch (leftRear.currentStatus, rightRear.currentStatus) {
        case (.hide, .hide):
            return 0
        case (.show, .hide):
            return leftRear.sliderOffset()
        case (.hide, .show):
            return rightRear.sliderOffset()
        default:
            if leftRear.currentStatus.isMoving {
                return leftRear.sliderOffset()
            } else if rightRear.currentStatus.isMoving {
                return rightRear.sliderOffset()
            }
        }
        return 0
    }

    var maxShowRate: CGFloat {
        return max(leftRear.showRate, rightRear.showRate)
    }
}

#if DEBUG
    struct MainContainer_Previews: PreviewProvider {
        static var previews: some View {
            self.generate()
        }

        static func generate() -> some View {
            let view = DemoSlider(type: .leftRear)
            let c = DrawerControl()
            c.setSlider(view: view)
            return MainContainer(content: DemoMain(), drawerControl: c)
        }
    }
#endif

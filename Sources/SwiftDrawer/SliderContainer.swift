//
//  SliderContainer.swift
//  DrawerDemo
//
//  Created by Millman on 2019/6/26.
//  Copyright © 2019 Millman. All rights reserved.
//

import Combine
import SwiftUI

struct SliderContainer<Content: SliderViewProtocol>: View {
    @ObservedObject public var control: DrawerControl
    @ObservedObject private var status: SliderStatus

    let slider: AnyView
    let type: SliderType
    var body: some View {
        GeometryReader { proxy in
            self.generateBody(proxy: proxy)
        }
    }

    func generateBody(proxy: GeometryProxy) -> some View {
        let parentSize = proxy.size
        status.parentSize = parentSize
        switch status.type {
        case .leftFront, .rightFront:
            let view = ZStack {
                AnyView(Color.white).frame(maxWidth:
                    self.status.sliderWidth)
                    .padding(EdgeInsets(top: -proxy.safeAreaInsets.top, leading: 0, bottom: -proxy.safeAreaInsets.bottom, trailing: 0))
                self.slider
                    .frame(maxWidth:
                        self.status.sliderWidth)
            }
            .shadow(radius: status.showRate > 0 ? status.shadowRadius : 0)
            .offset(x: status.sliderOffset(), y: 0)
            .gesture(DragGesture().onChanged { value in
                if self.status.type.isLeft, value.translation.width < 0 {
                    self.status.currentStatus = .moving(offset: value.translation.width)
                } else if !self.status.type.isLeft, value.translation.width > 0 {
                    self.status.currentStatus = .moving(offset: value.translation.width)
                }
            }.onEnded { value in
                if self.status.type.isLeft {
                    let sliderW = self.status.sliderWidth / 2
                    self.status.currentStatus = value.location.x < sliderW ? .hide : .show
                } else {
                    let sliderW = parentSize.width - self.status.sliderWidth / 2
                    self.status.currentStatus = value.location.x > sliderW ? .hide : .show
                }
            })
            .animation(.default, value: status.sliderOffset())

            return AnyView(view)
        case .leftRear, .rightRear:
            let view = slider
                .offset(x: status.type.isLeft ? 0 : parentSize.width - status.sliderWidth, y: 0)
                .frame(maxWidth: status.sliderWidth)
            return AnyView(view)
        case .none:
            return AnyView(EmptyView())
        }
    }

    init(content: Content, drawerControl: DrawerControl) {
        slider = AnyView(content.environmentObject(drawerControl))
        type = content.type
        control = drawerControl
        status = drawerControl.status[content.type]!
    }
}

#if DEBUG
    struct SliderContainer_Previews: PreviewProvider {
        static var previews: some View {
            self.generate()
        }

        static func generate() -> some View {
            let view = DemoSlider(type: .leftRear)
            let c = DrawerControl()
            c.setSlider(view: view)
            return SliderContainer(content: view, drawerControl: c)
        }
    }
#endif

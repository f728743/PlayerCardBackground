//
//  GradientEffectView.swift
//  PlayerCardBackground
//
//  Created by Alexey Vorobyov on 24.03.2022.
//

import Combine
import SwiftUI

struct AnimatedGradient: View {
    struct Model {
        init(colors: [Color]) {
            firstGradientColors = colors
        }

        var colors: [Color] {
            get {
                isFirstGradientVisible ? firstGradientColors : secondGradientColors
            }
            set {
                if isFirstGradientVisible {
                    secondGradientColors = newValue
                } else {
                    firstGradientColors = newValue
                }
                isFirstGradientVisible.toggle()
            }
        }

        fileprivate var isFirstGradientVisible = true
        fileprivate var firstGradientColors: [Color]
        fileprivate var secondGradientColors: [Color] = []
    }

    @Binding private var model: Model

    init(_ model: Binding<Model>) {
        _model = model
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: model.firstGradientColors),
                startPoint: .top,
                endPoint: .bottom
            ).opacity(model.isFirstGradientVisible ? 1 : 0)
            LinearGradient(
                gradient: Gradient(colors: model.secondGradientColors),
                startPoint: .top,
                endPoint: .bottom
            ).opacity(model.isFirstGradientVisible ? 0 : 1)
        }
    }
}

struct VisualEffect: UIViewRepresentable {
    var effect: UIVisualEffect?
    let effectView = UIVisualEffectView(effect: nil)

    func makeUIView(context _: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        effectView.effect = effect
        return effectView
    }

    func updateUIView(_: UIVisualEffectView, context _: UIViewRepresentableContext<Self>) {}
}

struct GradientEffectView: View {
    private struct Blot: Identifiable {
        let id = UUID()
        let sizeModifier: CGSize
        let scale: CGFloat
        let rotation: Angle
        let offset: CGPoint
        let saturation: Double

        static var random: Blot {
            Blot(
                sizeModifier: CGSize(width: .random(in: -100 ... 300), height: .random(in: -100 ... 300)),
                scale: .random(in: 1 ... 2.5),
                rotation: .degrees(.random(in: 0 ... 360)),
                offset: CGPoint(x: .random(in: -300 ... 300), y: .random(in: -300 ... 300)),
                saturation: .random(in: 0.4 ... 1.4)
            )
        }
    }

    let timerUpdate = 5.0

    @State private var backgroundAngle: Angle = .zero
    @State private var blots: [Blot] = (0 ..< 3).map { _ in .random }
    @Binding private var model: AnimatedGradient.Model
    private let timer: Publishers.Autoconnect<Timer.TimerPublisher>

    init(_ model: Binding<AnimatedGradient.Model>) {
        _model = model
        timer = Timer.publish(every: timerUpdate, on: .main, in: .common).autoconnect()
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                background(geometry)
                blot(withParams: blots[0], geometry)
                blot(withParams: blots[1], geometry)
                blot(withParams: blots[2], geometry)
                VisualEffect(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                VisualEffect(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onAppear {
                update()
            }
            .onReceive(timer) { _ in
                update()
            }
            .onChange(of: model.isFirstGradientVisible) { _ in
                update()
            }
        }
        .edgesIgnoringSafeArea(.all)
    }

    private func update() {
        withAnimation(.easeInOut(duration: timerUpdate).speed(0.1)) {
            backgroundAngle = .degrees(.random(in: 0 ... 360))
            blots = (0 ..< blots.count).map { _ in .random }
        }
    }

    private func background(_ geometry: GeometryProxy) -> some View {
        let size = hypot(geometry.size.width, geometry.size.height)
        return AnimatedGradient($model)
            .rotationEffect(backgroundAngle, anchor: .center)
            .frame(width: size, height: size)
    }

    private func blot(withParams blot: Blot, _ geometry: GeometryProxy) -> some View {
        let size = min(geometry.size.width, geometry.size.height)
        return AnimatedGradient($model)
            .clipShape(Capsule())
            .frame(
                width: size + blot.sizeModifier.width,
                height: size + blot.sizeModifier.height
            )
            .scaleEffect(blot.scale)
            .opacity(0.5)
            .rotationEffect(blot.rotation, anchor: .center)
            .offset(x: blot.offset.x, y: blot.offset.y)
            .blendMode(.lighten)
            .saturation(blot.saturation)
            .contrast(2)
    }
}

struct GradientEffectView_Previews: PreviewProvider {
    static var previews: some View {
        GradientEffectView(
            .constant(
                AnimatedGradient.Model(
                    colors: [.red, .yellow, .green, .blue, .magenta]
                        .map { Color(uiColor: $0) }
                )
            )
        )
    }
}

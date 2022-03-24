//
//  GradientEffectView.swift
//  PlayerCardBackground
//
//  Created by Alexey Vorobyov on 24.03.2022.
//

import SwiftUI

extension UIImage {
    func convertToRGBColorspace() -> UIImage? {
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext.init(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: UInt32(bitmapInfo.rawValue)
        )
        guard let context = context, let cgImage = cgImage else { return nil }
        context.draw(cgImage, in: CGRect(origin: CGPoint.zero, size: size))
        guard let convertedImage = context.makeImage() else { return nil }
        return UIImage(cgImage: convertedImage)
    }
    
    
    static func gradientImageWithBounds(size: CGSize, colors: [UIColor]) -> UIImage {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: .zero, size: size)
        gradientLayer.colors = colors.map { $0.cgColor }
        
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

struct GradientEffectView: View {
    
    @State var animation = false
    
    
    let colors: [UIColor]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                firstImage(geometry)
                image(geometry)
                image(geometry)
                image(geometry)
//                VisualEffect(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
                VisualEffect(effect: UIBlurEffect(style: .systemUltraThinMaterial))
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            withAnimation(Animation.linear(duration: 100).repeatForever()) {
                animation.toggle()
            }
        }
    }
    
    var gradient: UIImage {
        return UIImage.gradientImageWithBounds(
            size: CGSize(width: 400, height: 400),
            colors: colors.count == 1 ? [colors[0], colors[0]] : colors
        )
    }
    
    func image(_ geometry: GeometryProxy) -> some View {
        Image(uiImage: gradient)
            .resizable()
            .frame(
                width: randomFrame(geometry.size.width),
                height: randomFrame(geometry.size.width)
            )
            .scaleEffect(randomCGFloat(in: 1...2.5))
            .opacity(0.5)
            .rotationEffect(.degrees(randomDouble(in: -360...360)), anchor: .center)
            .offset(x: randomCGFloat(in: -300...300), y: randomCGFloat(in: -300...300))
            .blendMode(.lighten)
            .saturation(randomDouble(in: 0.4...1.4))
            .contrast(2)
    }
    
    func firstImage(_ geometry: GeometryProxy) -> some View {
        Image(uiImage: gradient)
            .resizable()
//            .brightness(-0.5)
            .rotationEffect(.degrees(randomDouble(in: -360...360)), anchor: .center)
            .frame(width: geometry.size.height*2, height: geometry.size.height*2)
    }
    
    func randomFrame(_ base: CGFloat) -> CGFloat {
        let randomNumber = animation ? CGFloat.random(in: -100...300) : CGFloat.random(in: -100...300)
        let frame = base + randomNumber
        return frame
    }
    
    func randomCGFloat(in range: ClosedRange<CGFloat>) -> CGFloat {
        let randomNumber = animation ? CGFloat.random(in: range) : CGFloat.random(in: range)
        return randomNumber
    }
    
    func randomDouble(in range: ClosedRange<Double>) -> Double {
        let randomNumber = animation ? Double.random(in: range) : Double.random(in: range)
        return randomNumber
    }
}

struct GradientEffectView_Previews: PreviewProvider {
    static var previews: some View {
        GradientEffectView(
            colors: [
                .green,
                UIColor(red: 1, green: 0, blue: 0, alpha: 1),
                UIColor(red: 0, green: 1, blue: 0, alpha: 1)
            ]
        )
    }
}

struct VisualEffect: UIViewRepresentable {
    var effect: UIVisualEffect?
    let effectView = UIVisualEffectView(effect: nil)

    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        effectView.effect = effect
        return effectView
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { }
}

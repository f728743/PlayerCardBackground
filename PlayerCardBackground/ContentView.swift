//
//  ContentView.swift
//  PlayerCardBackground
//
//  Created by Alexey Vorobyov on 24.03.2022.
//

import SwiftUI
import ColorKit

struct ContentView: View {
    
    let images = [
        "radio_01_class_rock", "radio_02_pop", "radio_03_hiphop_new",
        "radio_04_punk", "radio_05_talk_01", "radio_06_country",
        "radio_07_dance_01", "radio_08_mexican", "radio_09_hiphop_old",
        "radio_11_talk_02", "radio_12_reggae", "radio_13_jazz",
        "radio_14_dance_02", "radio_15_motown", "radio_16_silverlake",
        "radio_17_funk", "radio_18_90s_rock"
    ]
    
    @State var imageIndex = 0
    
    @State var colors: [(id: Int, color: UIColor, frequency: CGFloat)] = []
    
    private var columns = Array(
        repeating: GridItem(.flexible(), spacing: Constants.padding),
        count: 5
    )
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: Constants.coverArtSize, height: Constants.coverArtSize)
                
                .background(
                    Color(uiColor: .systemGray4)
                )
                .cornerRadius(Constants.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .stroke(Color(UIColor.systemGray3), lineWidth: 1)
                )
                .padding(.top, 40)
            
            
            changeImageButtons.padding()
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: Constants.padding) {
                    ForEach(colors, id: \.id) { color in
                        ZStack {
                            Color(uiColor: color.color)
                                .frame(width: Constants.colorSize, height: Constants.colorSize)
                                .cornerRadius(Constants.colorCornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Constants.colorCornerRadius)
                                        .stroke(Color(UIColor.systemGray3), lineWidth: 1)
                                )
                            Text("\(color.frequency)")
                                .font(.system(size: 8))
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .padding()
        }
        .ignoresSafeArea()
        .background(
            GradientEffectView(colors: colors.prefix(5).map { $0.color })
        )
        .onAppear(perform: updateColors)
        
    }
    
    var changeImageButtons: some View {
        HStack {
            Button(action: backward) { Image(systemName: "backward.fill") }
            Button(action: forward) { Image(systemName: "forward.fill") }
        }
        .foregroundColor(.primary)
        .font(.largeTitle)
    }
        
}

private extension ContentView {
    
    var image: UIImage {
         UIImage(named: images[imageIndex])?.convertToRGBColorspace() ??  UIImage()
    }
    
    func backward() {
        guard !images.isEmpty else { return }
        imageIndex -= 1
        if imageIndex < images.startIndex {
            imageIndex = images.endIndex - 1
        }
        updateColors()
    }
    
    func forward() {
        guard !images.isEmpty else { return }
        imageIndex += 1
        if imageIndex >= images.endIndex {
            imageIndex = images.startIndex
        }
        updateColors()
    }
    
    func updateColors() {
        guard let dominantColors = try? image.dominantColorFrequencies(with: .fair) else { return }
        colors = dominantColors
            .enumerated()
            .map { ($0.offset, $0.element.color, $0.element.frequency) }
    }
    
    enum Constants {
        static let coverArtSize: CGFloat = 200
        static let cornerRadius: CGFloat = 6
        static let padding: CGFloat = 14
        static let colorSize: CGFloat = 44
        static let colorCornerRadius: CGFloat = 3
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

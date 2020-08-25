//
//  ContentView.swift
//  SwiftUIVideoPlayerCoreImage
//
//  Created by Anupam Chugh on 25/08/20.
//

import SwiftUI
import AVKit
import CoreImage
import CoreImage.CIFilterBuiltins


struct ContentView: View {

    
    
    @State private var currentFilter = 0
    var filters : [CIFilter?] = [nil, CIFilter.sepiaTone(), CIFilter.pixellate(), CIFilter.comicEffect()]
    //URL(string: "http://0.s3.envato.com/h264-video-previews/80fad324-9db4-11e3-bf3d-0050569255a8/490527.mp4")!
    let player = AVPlayer(url: Bundle.main.url(forResource: "trump", withExtension: "mp4")!)

    var body: some View {
        
        VStack{
        
            Text("Add Cool Effects In A Live Video Stream With SwiftUI VideoPlayer in iOS 14")
                .multilineTextAlignment(.center)
                .font(.system(.title, design: .rounded))
                .padding()
                .foregroundColor(.yellow)
                
                
            VideoPlayer(player: player)
                .onAppear{
                    player.currentItem!.videoComposition = AVVideoComposition(asset: player.currentItem!.asset,  applyingCIFiltersWithHandler: { request in

                        if let filter = self.filters[currentFilter]{
                        
                        let source = request.sourceImage.clampedToExtent()
                        filter.setValue(source, forKey: kCIInputImageKey)

                        if filter.inputKeys.contains(kCIInputScaleKey){
                            filter.setValue(30, forKey: kCIInputScaleKey)
                        }

                        let output = filter.outputImage!.cropped(to: request.sourceImage.extent)
                            
                        request.finish(with: output, context: nil)
                        }
                        else{
                            request.finish(with: request.sourceImage, context: nil)
                        }
                    })
                }

            Picker(selection: $currentFilter, label: Text("Select Filter")) {
                ForEach(0..<filters.count) { index in
                    Text(self.filters[index]?.name ?? "None").tag(index)
                }
            }.pickerStyle(SegmentedPickerStyle())
            
            Text("Value: \(self.filters[currentFilter]?.name ?? "None")")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

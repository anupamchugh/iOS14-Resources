//
//  ContentView.swift
//  SwiftUICoreImageFilter
//
//  Created by Anupam Chugh on 02/08/20.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

var input1 = "credit_card"
var input2 = "credit_card_no_number"


struct ContentView: View {
    
    @State var image : UIImage?
    
    var body: some View {

        ScrollView{
            VStack{
                Image(input1)
                    .aspectRatio(contentMode: .fit)
                
                Text("-")
                    .font(.title)
                
                Image(input2)
                    .aspectRatio(contentMode: .fit)
                
                Text("=")
                    .font(.title)

                if let image = image{
                    Image(uiImage: image)
                        .aspectRatio(contentMode: .fit)
                }
                else{
                    Button(action: {computeImageDifference()}, label: {
                        Text("Compute Image Difference")
                    })
                }
            }
        }
    }
    
    func computeImageDifference(){
        guard let inputImage = UIImage(named: input1)
        else { return }
        
        guard let inputImage2 = UIImage(named: input2)
        else { return }
        
        let beginImage = CIImage(image: inputImage)
        let beginImage2 = CIImage(image: inputImage2)
        let context = CIContext()
        let currentFilter = CIFilter.colorAbsoluteDifference()
        currentFilter.inputImage = beginImage
        currentFilter.inputImage2 = beginImage2
        
        guard let outputImage = currentFilter.outputImage
        else {return }
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            self.image = uiImage
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension UIImage {
    var noir: UIImage? {
        let context = CIContext(options: nil)
        guard let currentFilter = CIFilter(name: "CIPhotoEffectNoir") else { return nil }
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        if let output = currentFilter.outputImage,
            let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        }
        return nil
    }
}

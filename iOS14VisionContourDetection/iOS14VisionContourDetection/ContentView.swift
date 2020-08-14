//
//  ContentView.swift
//  iOS14VisionContourDetection
//
//  Created by Anupam Chugh on 26/06/20.
//

import SwiftUI
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins



struct ContentView: View {
    
    @State var points : String = ""
    @State var preProcessImage: UIImage?
    @State var contouredImage: UIImage?
    
    var body: some View {
        
        VStack{
            
            Text("Contours: \(points)")

            Image("coins")
            .resizable()
            .scaledToFit()
                
            if let image = preProcessImage{
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
                
                
            if let image = contouredImage{
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }

            Button("Detect Contours", action: {
                detectVisionContours()
            })
        }
    }
    
    
    
    
    
    
    
    public func drawContours(contoursObservation: VNContoursObservation, sourceImage: CGImage) -> UIImage {
        let size = CGSize(width: sourceImage.width, height: sourceImage.height)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let renderedImage = renderer.image { (context) in
        let renderingContext = context.cgContext

        let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height)
        renderingContext.concatenate(flipVertical)

            
            
        renderingContext.draw(sourceImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        renderingContext.scaleBy(x: size.width, y: size.height)
        renderingContext.setLineWidth(5.0 / CGFloat(size.width))
        let redUIColor = UIColor.red
        renderingContext.setStrokeColor(redUIColor.cgColor)
        renderingContext.addPath(contoursObservation.normalizedPath)
        renderingContext.strokePath()
        }
        
        return renderedImage
    }
    
    
    func detectVisionContours(){
        
        let context = CIContext()
        if let sourceImage = UIImage.init(named: "coins")
        {
            var inputImage = CIImage.init(cgImage: sourceImage.cgImage!)
            
            let contourRequest = VNDetectContoursRequest.init()
            contourRequest.revision = VNDetectContourRequestRevision1
            contourRequest.contrastAdjustment = 1.0
            contourRequest.detectDarkOnLight = true
            
            contourRequest.maximumImageDimension = 512
            
            do {
                    let noiseReductionFilter = CIFilter.gaussianBlur()
                    noiseReductionFilter.radius = 0.5
                    noiseReductionFilter.inputImage = inputImage

                    let blackAndWhite = CustomFilter()
                    blackAndWhite.inputImage = noiseReductionFilter.outputImage!
                    let filteredImage = blackAndWhite.outputImage!
//                    let monochromeFilter = CIFilter.colorControls()
//                    monochromeFilter.inputImage = noiseReductionFilter.outputImage!
//                    monochromeFilter.contrast = 20.0
//                    monochromeFilter.brightness = 4
//                    monochromeFilter.saturation = 50
//                    let filteredImage = monochromeFilter.outputImage!


                    inputImage = filteredImage
                    if let cgimg = context.createCGImage(filteredImage, from: filteredImage.extent) {
                        self.preProcessImage = UIImage(cgImage: cgimg)
                    }
                }

            let requestHandler = VNImageRequestHandler.init(ciImage: inputImage, options: [:])

            try! requestHandler.perform([contourRequest])
            let contoursObservation = contourRequest.results?.first as! VNContoursObservation
            
            self.points  = String(contoursObservation.contourCount)
            self.contouredImage = drawContours(contoursObservation: contoursObservation, sourceImage: sourceImage.cgImage!)

        } else {
            self.points = "Could not load image"
        }
    }
}


class CustomFilter: CIFilter {
    var inputImage: CIImage?
    
    override public var outputImage: CIImage! {
        get {
            if let inputImage = self.inputImage {
                let args = [inputImage as AnyObject]
                
                let callback: CIKernelROICallback = {
                (index, rect) in
                    return rect.insetBy(dx: -1, dy: -1)
                }
                
                return createCustomKernel().apply(extent: inputImage.extent, roiCallback: callback, arguments: args)
            } else {
                return nil
            }
        }
    }

    
    func createCustomKernel() -> CIKernel {
            return CIColorKernel(source:
                "kernel vec4 replaceWithBlackOrWhite(__sample s) {" +
                    "if (s.r > 0.25 && s.g > 0.25 && s.b > 0.25) {" +
                    "    return vec4(0.0,0.0,0.0,1.0);" +
                    "} else {" +
                    "    return vec4(1.0,1.0,1.0,1.0);" +
                    "}" +
                "}"
                )!
           
        }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

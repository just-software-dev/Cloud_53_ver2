//
//  QRcode.swift
//  Cloud 53
//
//  Created by Андрей on 15.07.2020.
//  Copyright © 2020 oak. All rights reserved.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRcode: View {
    
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()
    
    @State var string: String
    
    var body: some View {
        Image(uiImage: generateQR())
            .interpolation(.none)
            .resizable()
    }
    
    func generateQR() -> UIImage {
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

struct QRcode_Previews: PreviewProvider {
    static var previews: some View {
        QRcode(string: "www.example.com")
    }
}

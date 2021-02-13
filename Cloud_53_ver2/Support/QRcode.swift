//
//  QRcode.swift
//  Cloud 53
//
//  Created by Андрей on 15.07.2020.
//  Copyright © 2020 oak. All rights reserved.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

class QRcode {
    
    static let shared = QRcode()
    
    func generateQR(_ s: String) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        let data = Data(s.utf8)
        filter.setValue(data, forKey: "inputMessage")

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    private init() {}
}

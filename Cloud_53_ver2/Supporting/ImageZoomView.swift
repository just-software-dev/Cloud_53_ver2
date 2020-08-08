//
//  ImageZoomView.swift
//  Cloud 53
//
//  Created by Андрей on 16.07.2020.
//  Copyright © 2020 oak. All rights reserved.
//

import SwiftUI

struct ImageZoomView: View {
    
    var image: UIImage
    @State private var rect: CGRect = .zero
    
    var body: some View {
        UIImageZoomViewRepresent(image: self.image, rect: self.$rect)
            .frame(width: self.rect.width, height: self.rect.height)
    }
}

private struct UIImageZoomViewRepresent: UIViewRepresentable {
    
    var image: UIImage
    @Binding var rect: CGRect
    
    func makeUIView(context: UIViewRepresentableContext<UIImageZoomViewRepresent>) -> UIImageZoomView {
        let uiView = UIImageZoomView()
        let frame = getFrame()
        uiView.frame = frame
        DispatchQueue.main.async {
            self.rect = frame
        }
        uiView.set(image: image)
        return uiView
    }

    func updateUIView(_ uiView: UIImageZoomView, context: UIViewRepresentableContext<UIImageZoomViewRepresent>) {
    }
    
    func getFrame() -> CGRect {
        var scale: CGFloat = 0
        let envSize = UIScreen.main.bounds
        let size = image.size
        if size.height / size.width > envSize.height / envSize.width {
            scale = envSize.height / size.height
        } else {
            scale = envSize.width / size.width
        }
        return CGRect(x: 0, y: 0, width: size.width * scale, height: size.height * scale)
    }
}

private class UIImageZoomView: UIScrollView, UIScrollViewDelegate {

    private var imageZoomView: UIImageView!
    
    lazy var zoomingTap: UITapGestureRecognizer = {
        let zoomingTap = UITapGestureRecognizer(target: self, action: #selector(handleZoomingTap))
        zoomingTap.numberOfTapsRequired = 2
        return zoomingTap
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.delegate = self
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.decelerationRate = UIScrollView.DecelerationRate.fast
        self.bouncesZoom = false
        self.bounces = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(image: UIImage) {
        
        imageZoomView?.removeFromSuperview()
        imageZoomView = nil
        imageZoomView = UIImageView(image: image)
        self.addSubview(imageZoomView)
        
        configurateFor(imageSize: image.size)
    }
    
    func configurateFor(imageSize: CGSize) {
        self.contentSize = imageSize
        
        setCurrentMaxandMinZoomScale()
        self.zoomScale = self.minimumZoomScale
        
        self.imageZoomView.addGestureRecognizer(self.zoomingTap)
        self.imageZoomView.isUserInteractionEnabled = true

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.centerImage()
    }
    
    func setCurrentMaxandMinZoomScale() {
        let boundsSize = self.bounds.size
        let imageSize = imageZoomView.bounds.size
        
        let xScale = boundsSize.width / imageSize.width
        let yScale = boundsSize.height / imageSize.height
        let minScale = min(xScale, yScale)
        
        self.minimumZoomScale = minScale
        self.maximumZoomScale = minScale * 5.5
    }
    
    func centerImage() {
        let boundsSize = self.bounds.size
        var frameToCenter = imageZoomView.frame
        
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }
        
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }
        
        imageZoomView.frame = frameToCenter
    }
    
    // gesture
    @objc func handleZoomingTap(sender: UITapGestureRecognizer) {
        let location = sender.location(in: sender.view)
        self.zoom(point: location, animated: true)
    }
    
    func zoom(point: CGPoint, animated: Bool) {
        let currectScale = self.zoomScale
        let minScale = self.minimumZoomScale
        let maxScale = self.maximumZoomScale
        
        if (minScale == maxScale && minScale > 1) {
            return
        }
        
        let toScale = maxScale
        let finalScale = (currectScale == minScale) ? toScale : minScale
        let zoomRect = self.zoomRect(scale: finalScale, center: point)
        self.zoom(to: zoomRect, animated: animated)
    }
    
    func zoomRect(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        let bounds = self.bounds
        
        zoomRect.size.width = bounds.size.width / scale
        zoomRect.size.height = bounds.size.height / scale
        
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2)
        return zoomRect
    }
    
    // MARK: - UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageZoomView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.centerImage()
    }
    
}

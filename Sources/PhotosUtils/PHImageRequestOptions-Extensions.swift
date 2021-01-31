//
//  PHImageRequestOptions-Extensions.swift
//  
//
//  Created by Valerii Lider on 12/26/20.
//

import Photos

public extension PHImageRequestOptions {

    convenience init(
        deliveryMode: PHImageRequestOptionsDeliveryMode = .fastFormat,
        isNetworkAccessAllowed: Bool = true,
        isSynchronous: Bool = false,
        resizeMode: PHImageRequestOptionsResizeMode = .fast,
        version: PHImageRequestOptionsVersion = .current,
        normalizedCropRect: CGRect? = .none,
        progressHandler: PHAssetImageProgressHandler? = .none
    ) {
        self.init()
        self.deliveryMode = deliveryMode
        self.isNetworkAccessAllowed = isNetworkAccessAllowed
        self.isSynchronous = isSynchronous
        if let rect = normalizedCropRect {
            self.normalizedCropRect = rect
            self.resizeMode = .exact
        } else {
            self.resizeMode = resizeMode
        }
        self.progressHandler = progressHandler
        self.version = version
    }

    static func fast() -> PHImageRequestOptions {
        .init(deliveryMode: .fastFormat)
    }

    static func original() -> PHImageRequestOptions {
        .init(deliveryMode: .highQualityFormat)
    }
}

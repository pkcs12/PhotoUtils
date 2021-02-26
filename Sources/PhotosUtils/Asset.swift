//
//  Asset.swift
//  
//
//  Created by Valerii Lider on 12/26/20.
//

import UIKit
import Photos

public struct Asset {
    public let id: String
    public var image: UIImage?
    public var isInCloud: Bool? { info?[PHImageResultIsInCloudKey] as? Bool }
    public var isDegraded: Bool? { info?[PHImageResultIsDegradedKey] as? Bool }
    public var creationDate: Date? { asset?.creationDate }
    public var location: CLLocation? { asset?.location }

    public var isPhoto: Bool {
        asset.map { $0.mediaType == .image } ?? false
    }

    public var isHDR: Bool {
        isPhoto && (asset.map { $0.mediaSubtypes.contains(.photoHDR) } ?? false)
    }

    public var isPortrait: Bool {
        isPhoto && (asset.map { $0.mediaSubtypes.contains(.photoDepthEffect) } ?? false )
    }

    public var isLive: Bool {
        isPhoto && (asset.map { $0.mediaSubtypes.contains(.photoLive) } ?? false )
    }

    public var isPanorama: Bool {
        isPhoto && (asset.map { $0.mediaSubtypes.contains(.photoPanorama) } ?? false )
    }

    public var isScreenshot: Bool {
        isPhoto && (asset.map { $0.mediaSubtypes.contains(.photoScreenshot) } ?? false )
    }

    public init?(id: String, image: UIImage?, info: [AnyHashable: Any]?) {
        self.asset = nil
        self.id = id
        self.image = image
        self.info = info
    }

    /* copies identity without image and info dict
     */
    public func copyIdentity() -> Asset? {
        asset.map {
            Asset(
                asset: $0,
                id: $0.localIdentifier,
                image: nil,
                info: nil
            )
        }
    }

    /* info keys:
     let PHImageResultIsInCloudKey: String
        A key whose value indicates whether photo asset data is stored on the local device or must be downloaded from iCloud.
     let PHImageResultIsDegradedKey: String
        A key whose value indicates whether the result image is a low-quality substitute for the requested image.
     let PHImageResultRequestIDKey: String
        A key whose value is a unique identifier for the image request.
     let PHImageCancelledKey: String
        A key whose value indicates whether the image request was canceled.
     let PHImageErrorKey: String
        A key whose value is an error that occurred when Photos attempted to load the image.
     */
    internal let info: [AnyHashable: Any]?
    internal let asset: PHAsset?

    internal init(asset: PHAsset, id: String, image: UIImage?, info: [AnyHashable: Any]?) {
        self.asset = asset
        self.id = id
        self.image = image
        self.info = info
    }
}

extension Asset: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

}

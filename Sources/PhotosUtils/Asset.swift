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

    public init?(id: String, image: UIImage?, info: [AnyHashable: Any]?) {
        self.asset = nil
        self.id = id
        self.image = image
        self.info = info
    }

    public func copyIdentity(_ asset: Asset) -> Asset? {
        asset.asset.map {
            Asset(
                asset: $0,
                id: asset.id,
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

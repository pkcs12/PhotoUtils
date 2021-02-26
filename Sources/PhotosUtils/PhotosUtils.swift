
import Photos
import UIKit
import Combine

/**
    Authorize for using Photos

    - Parameter accessLevel: choose between "read and write", and "add"
    - Returns: subject of type PHAuthorizationStatus. It will publish status once it's resolved
 */
@available(iOS 14, *)
public func authorize(
    for accessLevel: PHAccessLevel
) -> AnyPublisher<PHAuthorizationStatus, Never> {

    Future<PHAuthorizationStatus, Never> { promise in
        let status = PHPhotoLibrary.authorizationStatus(for: accessLevel)
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: accessLevel) { status in
                promise(.success(status))
            }
        case .authorized, .limited, .denied, .restricted:
            promise(.success(status))

        @unknown default:
            assertionFailure("unknown authorization status")
        }
    }
    .drop(while: { $0 == .notDetermined })
    .removeDuplicates()
    .eraseToAnyPublisher()
}

/**
    Authorize for using Photos

    - Returns: subject of type PHAuthorizationStatus. It will publish status once it's resolved
 */
@available(iOS 13, *)
public func authorize() -> AnyPublisher<PHAuthorizationStatus, Never> {

    Future<PHAuthorizationStatus, Never> { promise in
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                promise(.success(status))
            }
        case .authorized, .limited, .denied, .restricted:
            promise(.success(status))

        @unknown default:
            assertionFailure("unknown authorization status")
        }
    }
    .drop(while: { $0 == .notDetermined })
    .removeDuplicates()
    .eraseToAnyPublisher()
}

/**
    Fetch assets of specified types from selected sources

    - Parameter sourceTypes: set of sources from which assets should be fetched
    - Parameter subtypes: for filtering by specific type. Leave empty if you want to fetch all
    Default value is .userInitiated. Specify .background when performing action during background fetch request
    - Parameter sortDescriptors: sort rules
    - Returns: subject of type [Asset].
 */
public func fetchAssets(
    sourceTypes: PHAssetSourceType = [.typeUserLibrary, .typeCloudShared, .typeiTunesSynced],
    subtypes: PHAssetMediaSubtype = [],
    sortDescriptors: [NSSortDescriptor] = [.init(keyPath: \PHAsset.creationDate, ascending: false)]
) -> AnyPublisher<[Asset], Never> {

    Future<[Asset], Never> { promise in
        let options = PHFetchOptions()
        options.sortDescriptors = sortDescriptors
        options.includeAssetSourceTypes = sourceTypes

        if !subtypes.isEmpty {
            options.predicate = NSPredicate(format: "(mediaSubtypes & %d) != 0", subtypes.rawValue)
        }

        let result = PHAsset.fetchAssets(with: options)
        var assets = [Asset]()
        assets.reserveCapacity(result.count)
        result.enumerateObjects { (asset, index, stop) in
            assets.append(
                Asset(asset: asset, id: asset.localIdentifier, image: nil, info: nil)
            )
        }

        promise(.success(assets))
    }
    .eraseToAnyPublisher()
}

/**
    Featch specific asset

    - Parameter asset: instance of Asset type
    - Parameter targetSize: resulted image size
    - Parameter contentMode: content mode for the image
    - Parameter options: fetch options
    - Returns: subject of type Asset
 */
public func fetchAsset(
    _ asset: Asset,
    targetSize: CGSize = .init(width: 160, height: 160),
    contentMode: PHImageContentMode = .default,
    options: PHImageRequestOptions = .fast()
) -> AnyPublisher<Asset, Never> {

    Future<Asset, Never> { promise in
        guard let primitive = asset.asset else {
            promise(.success(asset))
            return
        }

        PHImageManager.default()
            .requestImage(
                for: primitive,
                targetSize: targetSize,
                contentMode: contentMode,
                options: options
            ) { image, info in

                promise(
                    .success(
                        Asset(
                            asset: primitive,
                            id: primitive.localIdentifier,
                            image: image,
                            info: info
                        )
                    )
                )
            }
    }
    .eraseToAnyPublisher()
}


import Photos
import UIKit

#if canImport(Combine)
import Combine
#endif

/**
    Authorize for using Photos

    - Parameter accessLevel: choose between "read and write", and "add"
    - Returns: subject of type PHAuthorizationStatus. It will publish status once it's resolved
 */
@available(iOS 14, *)
public func authorize(
    for accessLevel: PHAccessLevel
) -> AnyPublisher<PHAuthorizationStatus, Never> {

    let subject = PassthroughSubject<PHAuthorizationStatus, Never>()

    // return subject before process status
    DispatchQueue.global(qos: .userInteractive).async {
        let status = PHPhotoLibrary.authorizationStatus(for: accessLevel)
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: accessLevel) { status in
                subject.send(status)
            }
        case .authorized, .limited, .denied, .restricted:
            subject.send(status)

        @unknown default:
            assertionFailure("unknown authorization status")
        }
    }

    return subject
        .removeDuplicates()
        .drop(while: { $0 == .notDetermined })
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
}

/**
    Authorize for using Photos

    - Returns: subject of type PHAuthorizationStatus. It will publish status once it's resolved
 */
@available(iOS 13, *)
public func authorize() -> AnyPublisher<PHAuthorizationStatus, Never> {

    let subject = PassthroughSubject<PHAuthorizationStatus, Never>()

    // return subject before process status
    DispatchQueue.global(qos: .userInteractive).async {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                subject.send(status)
            }
        case .authorized, .limited, .denied, .restricted:
            subject.send(status)

        @unknown default:
            assertionFailure("unknown authorization status")
        }
    }

    return subject
        .removeDuplicates()
        .drop(while: { $0 == .notDetermined })
        .receive(on: DispatchQueue.main)
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
    let subject = PassthroughSubject<[PHAsset], Never>()

    DispatchQueue.global(qos: .background).async {
        let options = PHFetchOptions()
        options.sortDescriptors = sortDescriptors
        options.includeAssetSourceTypes = sourceTypes

        if !subtypes.isEmpty {
            options.predicate = NSPredicate(format: "(mediaSubtypes & %d) != 0", subtypes.rawValue)
        }

        let result = PHAsset.fetchAssets(with: options)
        var assets = [PHAsset]()
        assets.reserveCapacity(result.count)
        result.enumerateObjects { (asset, index, stop) in
            assets.append(asset)
        }

        subject.send(assets)
    }

    return subject
        .map { $0.compactMap { Asset(asset: $0, id: $0.localIdentifier, image: nil, info: nil) } }
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
    let subject = PassthroughSubject<Asset, Never>()

    DispatchQueue.global(qos: .background).async {
        guard let primitive = asset.asset else {
            subject.send(asset)
            return
        }

        fetchAsset(
            primitive,
            targetSize: targetSize,
            contentMode: contentMode,
            options: options,
            subject: subject
        )
    }

    return subject
        .eraseToAnyPublisher()
}

internal func fetchAsset<Subject>(
    _ asset: PHAsset,
    targetSize: CGSize,
    contentMode: PHImageContentMode,
    options: PHImageRequestOptions,
    subject: Subject
) where Subject: Combine.Subject,
        Subject.Output == Asset,
        Subject.Failure == Never
{
    PHImageManager.default()
        .requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: contentMode,
            options: options
        ) { image, info in

            subject.send(
                Asset(
                    asset: asset,
                    id: asset.localIdentifier,
                    image: image,
                    info: info
                )
            )
        }
}

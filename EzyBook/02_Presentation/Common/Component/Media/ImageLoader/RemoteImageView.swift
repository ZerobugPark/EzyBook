//
//  RemoteImageView.swift
//  EzyBook
//
//  Created by youngkyun park on 7/31/25.
//

import SwiftUI

struct RemoteImageView: View {
    
    let path: String
    @EnvironmentObject private var container: AppDIContainer
    @Environment(\.displayScale) private var scale
    

    var body: some View {
        RemoteImageViewImpl(path: path, container: container, scale: scale)
            
    }
}

fileprivate struct RemoteImageViewImpl: View {
    
    
    @StateObject private var viewModel: RemoteImageViewModel

    init(path: String, container: AppDIContainer, scale: CGFloat) {
        _viewModel = StateObject(
            wrappedValue: RemoteImageViewModel(
                imageLoadUseCases: container.commonDICotainer.makeImageLoadUseCase(),
                scale: scale,
                path: path
            )
        )
    }

    
    var body: some View {
        Group {
            if let uiImage = viewModel.output.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                ProgressView()
            }
        }
    }
}



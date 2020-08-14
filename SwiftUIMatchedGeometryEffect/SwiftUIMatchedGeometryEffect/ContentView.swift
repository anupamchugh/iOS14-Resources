//
//  ContentView.swift
//  SwiftUIMatchedGeometryEffect
//
//  Created by Anupam Chugh on 15/07/20.
//

import SwiftUI


struct ContentView: View {
    @Namespace private var namespace
    @State private var selectedAlbumIDs: Set<Album.ID> = []

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                albumGrid.padding(.horizontal)
            }

            Divider().zIndex(-1)

            selectedAlbumRow
                .frame(height: AlbumCell.albumSize)
                .padding(.top, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var albumGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: AlbumCell.albumSize))], spacing: 8) {
           ForEach(unselectedAlbums) { album in
              Button(action: { select(album) }) {
                 AlbumCell(album)
              }
              .matchedGeometryEffect(id: album.id, in: namespace)
           }
        }
    }

    private var selectedAlbumRow: some View {
        HStack {
            ForEach(selectedAlbums) { album in
                AlbumCell(album)
                .matchedGeometryEffect(id: album.id, in: namespace)
            }
        }
    }

    private var unselectedAlbums: [Album] {
        Album.allAlbums.filter { !selectedAlbumIDs.contains($0.id) }
    }
    private var selectedAlbums: [Album] {
        Album.allAlbums.filter { selectedAlbumIDs.contains($0.id) }
    }

    private func select(_ album: Album) {
        withAnimation(.spring(response: 0.5)) {
            _ = selectedAlbumIDs.insert(album.id)
        }
    }
}

struct AlbumCell: View {
    static let albumSize: CGFloat = 100

    var album: Album

    init(_ album: Album) {
        self.album = album
    }

    var body: some View {
        album.image
            .frame(width: AlbumCell.albumSize, height: AlbumCell.albumSize)
            .background(Color.pink)
            .cornerRadius(6.0)
    }
}

struct Album: Identifiable {
    static let allAlbums: [Album] = [
        .init(name: "Sample", image: Image(systemName: "music.note")),
        .init(name: "Sample 2", image: Image(systemName: "music.note.list")),
        .init(name: "Sample 3", image: Image(systemName: "music.quarternote.3")),
        .init(name: "Sample 4", image: Image(systemName: "music.mic")),
        .init(name: "Sample 5", image: Image(systemName: "music.note.house")),
        .init(name: "Sample 6", image: Image(systemName: "tv.music.note"))
    ]

    var name: String
    var image: Image

    var id: String { name }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

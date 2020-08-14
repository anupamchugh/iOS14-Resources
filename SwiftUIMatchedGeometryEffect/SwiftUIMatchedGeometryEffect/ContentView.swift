//
//  ContentView.swift
//  SwiftUIMatchedGeometryEffect
//
//  Created by Anupam Chugh on 15/07/20.
//

import SwiftUI


struct ContentView: View {
    
    @State var myData = Array(1...10).map{"Item \($0)"}
    @Namespace var namespace
    
    @State private var selectedItemIDs: Set<String> = []
    var columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
    
    var body: some View {
        VStack {
            ScrollView{
                LazyVGrid(columns: columns, alignment: .center, spacing: 20){
                    ForEach(unselectedItems, id: \.self) { album in
                       Button(action: { select(album) }) {
                          ItemCell(album, 100).background(Color.green)
                            .cornerRadius(6.0)
                       }
                       .matchedGeometryEffect(id: album, in: namespace)
                    }
                }.padding()
            }
            ScrollView(.horizontal){
                HStack {
                    ForEach(selectedItems, id: \.self) { item in
                        Button(action: { deselect(item) }) {
                           ItemCell(item, 50).background(Color.orange)
                        }
                        .matchedGeometryEffect(id: item, in: namespace)
                    }
                }
            }.frame(height: 100)
        }
    }
    
    private var selectedItems: [String] { myData.filter { selectedItemIDs.contains($0) } }
    
    private var unselectedItems: [String] {myData.filter { !selectedItemIDs.contains($0) } }
    
    private func select(_ item: String) {
        withAnimation(.spring(response: 0.5)) {
            _ = selectedItemIDs.insert(item)
        }
    }
    
    private func deselect(_ item: String) {
        withAnimation(.spring(response: 0.5)) {
            _ = selectedItemIDs.remove(item)
        }
    }
}

struct ItemCell: View {
    var itemSize: CGFloat

    var item: String

    init(_ item: String, _ itemSize: CGFloat) {
        self.item = item
        self.itemSize = itemSize
    }

    var body: some View {
            Text(item)
            .foregroundColor(.white)
            .frame(width: itemSize, height: itemSize)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

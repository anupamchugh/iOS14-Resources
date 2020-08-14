//
//  ContentView.swift
//  iOS14WidgetKitStaticConfiguration
//
//  Created by Anupam Chugh on 01/07/20.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    var body: some View {
        VStack{
        Text("Hello, world!").padding()
        Button(action: {WidgetCenter.shared.reloadAllTimelines()},
               label: {
            Text("Reload All Timelines")
        })
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

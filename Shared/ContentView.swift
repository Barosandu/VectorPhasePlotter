//
//  ContentView.swift
//  Shared
//
//  Created by Alexandru Ariton on 17.06.2021.
//

import SwiftUI
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

struct VectorElement: Codable {
    var xexpr: String
    var yexpr: String
    var zexpr: String
    var elem: String
}

#if os(iOS)
struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

struct BlurView: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VisualEffectView(effect: UIBlurEffect(style: self.colorScheme == .dark ? .dark : .extraLight))
    }
}

#endif

extension Dictionary where Key == String, Value == Double {
    mutating func set(value: Double, justFor ind: String, arr: [String]) {
        
        print(arr)
        for index in arr {
            self[index] = 0
        }
        for index in arr {
            if index == ind {
                print(ind)
                self[ind] = 3
            }
        }
    }
}

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }
    
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

struct ContentView: View {
    @State var lorentzIndex = 1.0
    @State var rosslerIndex = 1.0
    @State var newIndex = 1.0
    
    @State var indexDictionary: [String: Double] = ["Lorentz": 3, "Rössler": 0, "New": 0]
    @AppStorage("array") var array: [String] = ["Lorentz", "Rössler", "New"]
    @AppStorage("gameViewArray") var gameViewArray: [VectorElement] = [
        VectorElement(xexpr: "10 * ( y - x )", yexpr: "28 * x - y - x * z", zexpr: "x * y - 8 / 3 * z", elem: "Lorentz"),
        VectorElement(xexpr: "0 - y - z", yexpr: "x + 0.2 * y", zexpr: "0.2 + z * (x - 14)", elem: "Rössler"),
        VectorElement(xexpr: "0", yexpr: "0", zexpr: "0", elem: "New")
    ]
    @State var isLandscape = false
    @State var isLeftLandscape = false
    @AppStorage("View Title") var viewTitle = "Lorentz"
    @AppStorage("Pause On Change") var pauseOnChange = true
    
    
    
    var body: some View {
        #if os(macOS)
        NavigationView {
            VStack {
                ScrollView {
        
                
                    VStack {
                        ForEach(array, id: \.self) { elem in
                            NavButton(action: {
                                self.indexDictionary.set(value: 3, justFor: elem, arr: array)
                                self.viewTitle = elem
                                print(self.indexDictionary)
                            }) {
                                HStack {
                                    Text(elem)
                                    Spacer()
                                }
                                
                                .padding(10)
                                .background(self.indexDictionary[elem] ?? 1 == 3 ? Color.blue : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    List {
                        
                    }
                }
            }
            HStack {
                
                
                    ZStack {
                        ForEach(self.gameViewArray, id: \.elem) { gameElement in
                            GameViewUI(xexpr: gameElement.xexpr, yexpr: gameElement.yexpr, zexpr: gameElement.zexpr)
                                .zIndex(self.indexDictionary[gameElement.elem] ?? 1)
                                .navigationTitle("\(self.viewTitle)")
                        }
                    }
                
                //.navigationSubtitle(Text("\(self.array.filter({ str in self.indexDictionary[str] != 0}).first!)"))
            }
        }
        .frame(minWidth: 800, minHeight: 500)
        #endif
        
        #if os(iOS)
        Group {
                VStack {
                    HStack {
                        if self.isLandscape && self.isLeftLandscape {
                            VStack {
                                ScrollView(.vertical, showsIndicators: false) {
                                    
                                    Spacer(minLength: 50)
                                    VStack {
                                        ForEach(array, id: \.self) { elem in
                                            NavButton(action: {
                                                self.indexDictionary.set(value: 3, justFor: elem, arr: array)
                                                self.viewTitle = elem
                                                print(self.indexDictionary)
                                            }) {
                                                HStack {
                                                    Text(elem)
                                                    Spacer()
                                                }
                                                
                                                .padding(10)
                                                .background("\(self.array.filter({ str in self.indexDictionary[str] != 0}).first!)" == elem ? Color.blue : Color.clear)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            
                                        }
                                    }
                                    Spacer(minLength: 50)
                                }
                            }.frame(maxWidth: 140)
                        }
                        HStack {
                            
                            ZStack {
                                ForEach(self.gameViewArray, id: \.elem) { gameElement in
                                    GameViewUI(xexpr: gameElement.xexpr, yexpr: gameElement.yexpr, zexpr: gameElement.zexpr)
                                        .zIndex(self.indexDictionary[gameElement.elem] ?? 1)
                                }
                            }
                            .clipShape(SelectiveRoundedRectangle(cornerRadius: 20, rounding:self.isLandscape ? (self.isLeftLandscape ? [.topLeft, .bottomLeft] : [.topRight , .bottomRight]) : [.bottomLeft, .bottomRight]))
                            
                        }
                        if self.isLandscape && !self.isLeftLandscape {
                            VStack {
                                ScrollView(.vertical, showsIndicators: false) {
                                    
                                    Spacer(minLength: 50)
                                    VStack {
                                        ForEach(array, id: \.self) { elem in
                                            NavButton(action: {
                                                self.indexDictionary.set(value: 3, justFor: elem, arr: array)
                                                self.viewTitle = elem
                                                print(self.indexDictionary)
                                            }) {
                                                HStack {
                                                    Text(elem)
                                                    Spacer()
                                                }
                                                
                                                .padding(10)
                                                .background("\(self.array.filter({ str in self.indexDictionary[str] != 0}).first!)" == elem ? Color.blue : Color.clear)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    Spacer(minLength: 50)
                                }
                            }.frame(maxWidth: 140)
                        }
                    }
                    if !self.isLandscape {
                        HStack {
                            ScrollView(.horizontal, showsIndicators: false) {
                                
                                
                                HStack {
                                    ForEach(array, id: \.self) { elem in
                                        Spacer(minLength: 20)
                                        NavButton(action: {
                                            self.indexDictionary.set(value: 3, justFor: elem, arr: array)
                                            self.viewTitle = elem
                                            print(self.indexDictionary)
                                        }) {
                                            HStack {
                                                Text(elem)
                                                
                                            }
                                            
                                            .padding(10)
                                            .background("\(self.array.filter({ str in self.indexDictionary[str] != 0}).first!)" == elem ? Color.blue : Color.clear)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                    }
                }
                .edgesIgnoringSafeArea(self.isLandscape ? [.top, .leading, .trailing, .bottom] : [.top, .leading, .trailing])
            }
        
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            guard let scene = UIApplication.shared.windows.first?.windowScene else { return }
            self.isLandscape = scene.interfaceOrientation.isLandscape
            if !self.isLandscape {
                self.isLeftLandscape = false
            }
            if scene.interfaceOrientation == .landscapeLeft {
                self.isLeftLandscape = true
            } else {
                self.isLeftLandscape = false
            }
        }
        .colorScheme(.dark)
        #endif
    }
}


struct GameViewUI: View {
    var xexpr = "0"
    var yexpr = "0"
    var zexpr = "0"
    init(xexpr: String, yexpr: String, zexpr: String) {
        self.xexpr = xexpr
        self.yexpr = yexpr
        self.zexpr = zexpr
        if self.xexpr == "" {
            self.xexpr = "0"
        }
        
        if self.yexpr == "" {
            self.yexpr = "0"
        }
        
        if self.zexpr == "" {
            self.zexpr = "0"
        }
    }
    var body: some View {
        _GameViewUI(xexpr: xexpr, yexpr: yexpr, zexpr: zexpr)
    }
}
#if os(macOS)
struct _GameViewUI: NSViewControllerRepresentable {
    var xexpr = "0"
    var yexpr = "0"
    var zexpr = "0"
    init(xexpr: String, yexpr: String, zexpr: String) {
        self.xexpr = xexpr
        self.yexpr = yexpr
        self.zexpr = zexpr
    }
    
    func makeNSViewController(context: Context) -> GameViewController {
        return GameViewController(xexpr: self.xexpr, yexpr: self.yexpr, zexpr: self.zexpr)
    }
    
    func updateNSViewController(_ nsViewController: GameViewController, context: Context) {
        
    }
    
    typealias NSViewControllerType = GameViewController
    
    
}
#endif

#if os(iOS)
struct _GameViewUI: UIViewControllerRepresentable {
    typealias UIViewControllerType = GameViewController
    
    var xexpr = "0"
    var yexpr = "0"
    var zexpr = "0"
    init(xexpr: String, yexpr: String, zexpr: String) {
        self.xexpr = xexpr
        self.yexpr = yexpr
        self.zexpr = zexpr
    }
    
    func makeUIViewController(context: Context) -> GameViewController {
        return GameViewController(xexpr: self.xexpr, yexpr: self.yexpr, zexpr: self.zexpr)
    }
    
    func updateUIViewController(_ nsViewController: GameViewController, context: Context) {
        
    }
    
    
    
    
}
#endif
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

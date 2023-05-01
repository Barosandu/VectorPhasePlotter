//
//  PutNode.swift
//  Vector Phase Plotter
//
//  Created by Alexandru Ariton on 17.06.2021.
//

import Foundation
import SwiftUI
import SceneKit
#if os(macOS)
struct BlurMacVisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    public init(
        material: NSVisualEffectView.Material = .contentBackground,
        blendingMode: NSVisualEffectView.BlendingMode = .withinWindow
    ) {
        self.material = material
        self.blendingMode = blendingMode
    }
    
    public func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = NSVisualEffectView.State.active
        return visualEffectView
    }
    
    public func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}
#endif

struct MainButton<Content: View>: View {
    var width: CGFloat = 100
    var action: () -> Void
    var content: () -> Content
    init (width: CGFloat = 100, action: @escaping () -> Void, label: @escaping () -> Content) {
        self.width = width
        self.action = action
        self.content = label
    }
    init (_ str: String, action: @escaping () -> Void) {
        self.action = action
        self.content = {
            Text("\(str)") as! Content
        }
    }
    @State var isHovered = false
    var body: some View {
        Button(action: action, label: {
            #if os(macOS)
            content()
                .foregroundColor(self.isHovered ? .white : .blue)
                .frame(height: 30, alignment: .center)
                .padding(5)
                .background(Color(self.isHovered ? .systemBlue : .textBackgroundColor).opacity(self.isHovered ? 1 : 0.5).clipShape(RoundedRectangle(cornerRadius: 10)))
            #elseif os(iOS)
            content()
                .foregroundColor(self.isHovered ? .white : .blue)
                .frame(height: 30, alignment: .center)
                .padding(5)
                .background(Color(self.isHovered ? .systemBlue : .textBackgroundColor).opacity(self.isHovered ? 1 : 0.5).clipShape(RoundedRectangle(cornerRadius: 10)))
            #endif
                
        })
            .buttonStyle(PlainButtonStyle())
        .onHover { hov in
            
                self.isHovered = hov
            
        }
    }
}

#if os(iOS)
extension UIColor {
    static var textBackgroundColor = UIColor.systemGray6
}
#endif

struct NavButton<Content: View>: View {
    var action: () -> Void
    var content: () -> Content
    init (action: @escaping () -> Void, label: @escaping () -> Content) {
        self.action = action
        self.content = label
    }
    init (_ str: String, action: @escaping () -> Void) {
        self.action = action
        self.content = {
            Text("\(str)") as! Content
        }
    }
    @State var isHovered = false
    var body: some View {
        Button(action: action, label: {
            #if os(macOS)
            content()
                
                .background(Color(self.isHovered ? .systemBlue : .clear).opacity(self.isHovered ? 0.2 : 0.5).clipShape(RoundedRectangle(cornerRadius: 10)))
                .padding(.horizontal)
            #elseif os(iOS)
                content()
                    
                    .background(Color(self.isHovered ? .systemBlue : .clear).opacity(self.isHovered ? 0.2 : 0.5).clipShape(RoundedRectangle(cornerRadius: 10)))
                    .padding(.horizontal, 5)
            #endif
            
        })
        .buttonStyle(PlainButtonStyle())
        .onHover { hov in
                self.isHovered = hov
            
        }
    }
}

#if os(iOS)
extension SCNVector3 {
    init(_ x: CGFloat, _ y: CGFloat, _ z: CGFloat) {
        self.init(Float(x), Float(y), Float(z))
    }
    
    init(x: CGFloat, y: CGFloat, z: CGFloat) {
        self.init(Float(x), Float(y), Float(z))
    }
}
#endif

struct PutNode: View {
    @State var scene: SCNScene
    @State var saved: Bool = false
    @State var xexpr = ""
    @State var yexpr = ""
    @State var zexpr = ""
    @State var stuffOnStage = false
    @State var paused = false
    func addNode(position pz: SCNVector3, color cl: Color = .yellow, wait: TimeInterval = 0.02, stopWhen closure: @escaping (SCNVector3) -> Bool = { _ in false }) {
        let geo = SCNSphere(radius: 0.2)
        let secWaitValue: Double = UserDefaults.standard.value(forKey: "waitValue") as? Double ?? 20.0
        let secIsWaitOn: Bool = UserDefaults.standard.value(forKey: "isWaitOn") as? Bool ?? false
        #if os(macOS)
        geo.materials[0].diffuse.contents = NSColor.red
        #elseif os(iOS)
        geo.materials[0].diffuse.contents = UIColor.red
        #endif
        let sphere = SCNNode(geometry: geo)
        sphere.position = pz
        sphere.name = "Sphere"
        scene.rootNode.addChildNode(sphere)
        sphere.runAction(
            
            SCNAction.repeatForever(
                SCNAction.sequence([
                    SCNAction.run { _ in
                        if !paused {
                            let poz = sphere.position
                            let np = sphere.presentation.position.newPosition(dt: 0.05, expressions: (xexpr, yexpr, zexpr))
                            let trail = axa(vertices: [
                                SCNVector3(poz.x-0.05, poz.y-0.05, poz.z-0.05),
                                SCNVector3(np.x+0.05, np.y+0.05, np.z+0.05),
                                SCNVector3(poz.x+0.05, poz.y+0.05, poz.z+0.05),
                                SCNVector3(np.x-0.05, np.y-0.05, np.z-0.05)
                            ], indices: [0, 1, 2, 1, 2, 3], color: cl)
                            
                            let trail2 = axa(vertices: [
                                SCNVector3(poz.x+0.05, poz.y-0.05, poz.z-0.05),
                                SCNVector3(np.x-0.05, np.y+0.05, np.z+0.05),
                                SCNVector3(poz.x-0.05, poz.y+0.05, poz.z+0.05),
                                SCNVector3(np.x+0.05, np.y-0.05, np.z-0.05)
                            ], indices: [0, 1, 2, 1, 2, 3], color: cl)
                            trail.name = "Trail"
                            trail2.name = "Trail2"
                        
                            scene.rootNode.addChildNode(trail)
                            scene.rootNode.addChildNode(trail2)
                            if secIsWaitOn {
                                trail.runAction(SCNAction.sequence([
                                    .wait(duration: secWaitValue),
                                    .run { _ in
                                        if !paused {
                                            trail.removeFromParentNode()
                                            trail.removeAllActions()
                                        }
                                    }
                                ]))
                                trail2.runAction(SCNAction.sequence([
                                    .wait(duration: secWaitValue),
                                    .run { _ in
                                        if !paused {
                                            trail2.removeFromParentNode()
                                            trail2.removeAllActions()
                                        }
                                    }
                                ]))
                            }
                            sphere.position = sphere.presentation.position.newPosition(dt: 0.05, expressions: (xexpr, yexpr, zexpr))
                        }
                        if self.paused {
                            print("\n\n\nPAUSED\n\n\n")
                           // UserDefaults.standard.setValue(sphere.position.x, forKey: "Sphere Position X")
                           // UserDefaults.standard.setValue(sphere.position.y, forKey: "Sphere Position Y")
                           // UserDefaults.standard.setValue(sphere.position.z, forKey: "Sphere Position Z")
                        }
                        
                    },
                    SCNAction.wait(duration: !closure(SCNVector3(sphere.position.x, sphere.position.y, sphere.position.z)) ? wait : 1)
                ])
            )
        )
    }
    
    func addVectors() {
        stuffOnStage = true
        for xx in stride(from: -50, to: 50, by: 10) {
            for yy in stride(from: -50, to: 50, by: 10) {
                for zz in stride(from: -50, to: 50, by: 10) {
                    var x = CGFloat(xx) / diva
                    var y = CGFloat(yy) / diva
                    var z = CGFloat(zz) / diva
                    var ddx: CGFloat = dx(CGFloat(x), y: CGFloat(y), z: CGFloat(z), expression: xexpr)
                    var ddy: CGFloat = dy(CGFloat(y), x: CGFloat(x), z: CGFloat(z), expression: yexpr)
                    var ddz: CGFloat = dz(CGFloat(z), x: CGFloat(x), y: CGFloat(y), expression: zexpr)
                    if ddy == 0 {
                        ddy = 0.000000000000000001
                    }
                    
                    
                    var tg = ddx / ddy
                    var ztg = ddz / ddy
                    var newY: CGFloat = sqrt(2/(1+tg*tg+ztg*ztg)) * ddy / (abs(ddy))
                    var element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
                    let vertices: [SCNVector3] = [
                        SCNVector3(x*diva+0.1, y*diva+0.1, z*diva+0.1),
                        SCNVector3(x: (CGFloat(x) + newY*tg)*diva, y: (CGFloat(y) + newY)*diva, z: (CGFloat(z) + newY*ztg)*diva),
                        SCNVector3(x*diva-0.1, y*diva-0.1, z*diva-0.1)
                    ]
                    var source = SCNGeometrySource(vertices: vertices)
                    
                    let geometry = SCNGeometry(sources: [source], elements: [element])
                    geometry.materials[0].diffuse.contents = Color.blue
                    geometry.materials[0].isDoubleSided = true
                    
                    var ballShape = SCNSphere(radius: 0.2)
                    var ballShape2 = SCNSphere(radius: 0.2)
                    ballShape2.materials[0].diffuse.contents = Color.blue
                    
                    var yourline = SCNNode(geometry: geometry)
                    
                    ballShape.materials[0].diffuse.contents = Color.red
                    ballShape.materials[0].isDoubleSided = true
                    var ball = SCNNode(geometry: ballShape)
                    ball.position = SCNVector3(x: (CGFloat(x) + newY*tg)*diva, y: (CGFloat(y) + newY)*diva, z: (CGFloat(z) + newY*ztg)*diva)
                    var ball2 = SCNNode(geometry: ballShape2)
                    ball2.position = SCNVector3(x,y,z)
                    yourline.name = "Line"
                    scene.rootNode.addChildNode(yourline)
                    
                    //scene.rootNode.addChildNode(ball)
                    //scene.rootNode.addChildNode(ball2)
                }
            }
        }
    }
    
    func clearAll() {
        stuffOnStage = false
        for child in self.scene.rootNode.childNodes {
            if child.name == "Sphere" || child.name == "Trail" || child.name == "Trail2" {
                child.removeAllActions()
                child.removeFromParentNode()
            }
        }
        stuffOnStage = true
        //self.xexpr = ""
        //self.yexpr = ""
        //self.zexpr = ""
    }
    
    func clearAllAll() {
        stuffOnStage = false
        for child in self.scene.rootNode.childNodes {
            if child.name == "Sphere" || child.name == "Trail" || child.name == "Trail2" || child.name == "Line" {
                child.removeAllActions()
                child.removeFromParentNode()
            }
            
        }
        
        //self.xexpr = ""
        //self.yexpr = ""
        //self.zexpr = ""
    }
    @State var showPopup = false
    @State var nodex = "1"
    @State var nodey = "1"
    @State var nodez = "1"
    
    let colArray: [Color] = [.blue, .yellow, .orange, .green, .pink]
    
    @AppStorage("array") var array: [String] = ["Lorentz", "Rössler", "New"]
    @AppStorage("gameViewArray") var gameViewArray: [VectorElement] = [
        VectorElement(xexpr: "10 * ( y - x )", yexpr: "28 * x - y - x * z", zexpr: "x * y - 8 / 3 * z", elem: "Lorentz"),
        VectorElement(xexpr: "0 - y - z", yexpr: "x + 0.2 * y", zexpr: "0.2 + z * (x - 14)", elem: "Rössler"),
        VectorElement(xexpr: "0", yexpr: "0", zexpr: "0", elem: "New")
    ]
    
    @State var selectedColor = Color.yellow
    @State var somethingWrongEquation = false
    @State var xerror = "No error"
    @State var yerror = "No error"
    @State var zerror = "No error"
    var popupView: some View {
        #if os(macOS)
        
            
            List {
                Section(header: Text("Position")) {
                    HStack {
                        Text("X: ")
                        TextField("X", text: self.$nodex).textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack {
                        Text("Y: ")
                        TextField("Y", text: self.$nodey).textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack {
                        Text("Z: ")
                        TextField("Z", text: self.$nodez).textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                Section(header:
                            HStack {
                                self.selectedColor
                                    .frame(width: 10, height: 10, alignment: .center)
                                    .clipShape(Circle())
                                Text("Color")
                            }
                ) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 20, maximum: 40))]){
                        ForEach(colArray, id: \.self) { nsColor in
                            nsColor
                                .frame(width: 20, height: 20, alignment: .center)
                                .clipShape(Circle())
                                .onTapGesture {
                                    self.selectedColor = nsColor
                                }
                        }
                    }
                }
            }
            
            
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        let numberFormatter = NumberFormatter()
                        let x = numberFormatter.number(from: self.nodex)?.floatValue ?? 0.00
                        let y = numberFormatter.number(from: self.nodey)?.floatValue ?? 0.00
                        let z = numberFormatter.number(from: self.nodez)?.floatValue ?? 0.00
                        self.addNode(position: SCNVector3(x, y, z), color: self.selectedColor, wait: 0.01)
                        self.showPopup = false
                        
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        self.showPopup = false
                    }
                }
            }
        .colorScheme(.dark).frame(width: 300, height: 300, alignment: .center)
        #elseif os(iOS)
        NavigationView {
        
            List {
                Section(header: Text("Position")) {
                    HStack {
                        Text("X: ")
                        TextField("X", text: self.$nodex)
                    }
                    
                    HStack {
                        Text("Y: ")
                        TextField("Y", text: self.$nodey)
                    }
                    
                    HStack {
                        Text("Z: ")
                        TextField("Z", text: self.$nodez)
                    }
                }
                Section(header:
                            HStack {
                                self.selectedColor
                                    .frame(width: 10, height: 10, alignment: .center)
                                    .clipShape(Circle())
                                Text("Color")
                            }
                ) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 20, maximum: 40))]){
                        ForEach(colArray, id: \.self) { nsColor in
                            nsColor
                                .frame(width: 20, height: 20, alignment: .center)
                                .clipShape(Circle())
                                .onTapGesture {
                                    self.selectedColor = nsColor
                                }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        
        .toolbar {
            ToolbarItem {
                Button("Done") {
                    let numberFormatter = NumberFormatter()
                    let x = numberFormatter.number(from: self.nodex)?.floatValue ?? 0.00
                    let y = numberFormatter.number(from: self.nodey)?.floatValue ?? 0.00
                    let z = numberFormatter.number(from: self.nodez)?.floatValue ?? 0.00
                    self.addNode(position: SCNVector3(x, y, z), color: self.selectedColor, wait: 0.01)
                    self.showPopup = false
                    
                }
            }
            
            ToolbarItem(placement: .navigation) {
                Button("Cancel") {
                    self.showPopup = false
                }
            }
        }
            .navigationTitle(Text("Add node"))
        }.colorScheme(.dark)
        
        #endif
    }
    
    var expressionView: some View {
        #if os(macOS)
        return
            List {
                Section(header: Text("Choose the equations"), footer: Text("These equations determine how a node moves in the given vector space")) {
                    HStack {
                        Text("dx: ")
                        TextField("dx", text: self.$xexpr)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    HStack {
                        Text("dy: ")
                        TextField("dy", text: self.$yexpr)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack {
                        Text("dz: ")
                        TextField("dz", text: self.$zexpr)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
            }
            .alert(isPresented: self.$somethingWrongEquation, content: {
                Alert(title: Text("Something's wrong!"), message: Text("We found something wrong with your equations. please check the typing\n Example:\n xz + 3 -> Wrong\n x*z+3 -> Right!\nError:\n\(self.xerror)\n\(self.yerror)\n\(self.zerror)"), dismissButton: Alert.Button.default(Text("OK"), action: {
                    self.somethingWrongEquation = false
                }))
            })
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        let expressionWithErrorX = NSExpressionWithErrorHandler(format: self.xexpr)
                        
                        let expressionWithErrorY = NSExpressionWithErrorHandler(format: self.yexpr)
                        
                        let expressionWithErrorZ = NSExpressionWithErrorHandler(format: self.zexpr)
                        
                        if expressionWithErrorX?.getError() == "No error" && expressionWithErrorY?.getError() == "No error" && expressionWithErrorZ?.getError() == "No error" {
                            self.addVectors()
                            print("Add Vecs")
                            self.showExprPopup = false
                        } else {
                            self.xerror = expressionWithErrorX?.getError() ?? "Unknown"
                            self.yerror = expressionWithErrorY?.getError() ?? "Unknown"
                            self.zerror = expressionWithErrorZ?.getError() ?? "Unknown"
                            self.somethingWrongEquation = true
                        }
                        
                        
                    }.disabled(self.xexpr == "0" || self.yexpr == "0" || self.zexpr == "0" || self.xexpr.contains(where: { char in
                        !["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", ".", "+", "/", "^", "(", ")", "x", "y", "z", "*", " "].contains("\(char)")
                    }) || self.yexpr.contains(where: { char in
                        !["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", ".", "+", "/", "^", "(", ")", "x", "y", "z", "*", " "].contains("\(char)")
                    }) || self.zexpr.contains(where: { char in
                        !["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", ".", "+", "/", "^", "(", ")", "x", "y", "z", "*", " "].contains("\(char)")
                    }) )
                    
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        self.showExprPopup = false
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
                }
            }
            
            
        .colorScheme(.dark)
        .frame(width: 300, height: 300, alignment: .center)
        #endif
        
        #if os(iOS)
        return NavigationView {
            List {
                Section(header: Text("Choose the equations"), footer: Text("These equations determine how a node moves in the given vector space")) {
                    HStack {
                        Text("dx: ")
                        TextField("dx", text: self.$xexpr)
                    }
                    HStack {
                        Text("dy: ")
                        TextField("dy", text: self.$yexpr)
                    }
                    
                    HStack {
                        Text("dz: ")
                        TextField("dz", text: self.$zexpr)
                    }
                }
                
            }
            .alert(isPresented: self.$somethingWrongEquation, content: {
                Alert(title: Text("Something's wrong!"), message: Text("We found something wrong with your equations. please check the typing\n Example:\n xz + 3 -> Wrong\n x*z+3 -> Right!\nError:\n\(self.xerror)\n\(self.yerror)\n\(self.zerror)"), dismissButton: Alert.Button.default(Text("OK"), action: {
                    self.somethingWrongEquation = false
                }))
            })
            .toolbar {
                ToolbarItem {
                    Button("Done") {
                        let expressionWithErrorX = NSExpressionWithErrorHandler(format: self.xexpr)
                    
                        let expressionWithErrorY = NSExpressionWithErrorHandler(format: self.yexpr)
                        
                        let expressionWithErrorZ = NSExpressionWithErrorHandler(format: self.zexpr)
                        
                        if expressionWithErrorX?.getError() == "No error" && expressionWithErrorY?.getError() == "No error" && expressionWithErrorZ?.getError() == "No error" {
                            self.addVectors()
                            print("Add Vecs")
                            self.showExprPopup = false
                        } else {
                            self.xerror = expressionWithErrorX?.getError() ?? "Unknown"
                            self.yerror = expressionWithErrorY?.getError() ?? "Unknown"
                            self.zerror = expressionWithErrorZ?.getError() ?? "Unknown"
                            self.somethingWrongEquation = true
                        }
                            
                        
                    }.disabled(self.xexpr == "0" || self.yexpr == "0" || self.zexpr == "0" || self.xexpr.contains(where: { char in
                        !["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", ".", "+", "/", "^", "(", ")", "x", "y", "z", "*", " "].contains("\(char)")
                    }) || self.yexpr.contains(where: { char in
                        !["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", ".", "+", "/", "^", "(", ")", "x", "y", "z", "*", " "].contains("\(char)")
                    }) || self.zexpr.contains(where: { char in
                        !["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", ".", "+", "/", "^", "(", ")", "x", "y", "z", "*", " "].contains("\(char)")
                    }) )
                    
                }
                
                ToolbarItem(placement: .navigation) {
                    Button("Cancel") {
                        self.showExprPopup = false
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
                }
            }
            .navigationTitle("Equations")
            .listStyle(InsetGroupedListStyle())
        }.colorScheme(.dark)
        #endif
    }
    @State var showExprPopup = false
    @State var showAlert = false
    @State var isLandscape = false
    @State var showsEquations = true
    @State var showSettings = false
    @State var stateWaitValue = UserDefaults.standard.value(forKey: "waitValue") as? Double ?? 20.0
    @State var stateIsWaitOn = UserDefaults.standard.value(forKey: "isWaitOn") as? Bool ?? false
    @AppStorage("View Title") var viewTitle = "Lorentz"
    @AppStorage("Pause On Change") var pauseOnChange = true
    @State var saveName = ""
    var savePopup: some View {
        #if os(iOS)
        NavigationView {
            List {
                Section(header: Text("Name")) {
                    TextField("Name", text: self.$saveName)
                }
                
                Section(header: Text("Equations")) {
                    Text("dx: \(self.xexpr)")
                    Text("dy: \(self.yexpr)")
                    Text("dz: \(self.zexpr)")
                }
            }.listStyle(InsetGroupedListStyle())
            .toolbar {
                ToolbarItem {
                    Button("Save") {
                        self.array.insert(saveName, at: self.array.count - 1)
                        self.gameViewArray.insert(VectorElement(xexpr: self.xexpr, yexpr: self.yexpr, zexpr: self.zexpr, elem: self.saveName), at: self.gameViewArray.count - 1)
                        self.showSavePopup = false
                    }
                }
                ToolbarItem(placement: .navigation) {
                    Button("Cancel") {
                        self.showSavePopup = false
                    }
                }
            }
            .navigationTitle(Text("Save"))
        }.colorScheme(.dark)
        #elseif os(macOS)
        
            List {
                Section(header: Text("Name")) {
                    TextField("Name", text: self.$saveName)
                }
                
                Section(header: Text("Equations")) {
                    Text("dx: \(self.xexpr)")
                    Text("dy: \(self.yexpr)")
                    Text("dz: \(self.zexpr)")
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        self.array.insert(saveName, at: self.array.count - 1)
                        self.gameViewArray.insert(VectorElement(xexpr: self.xexpr, yexpr: self.yexpr, zexpr: self.zexpr, elem: self.saveName), at: self.gameViewArray.count - 1)
                        self.showSettings = false
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        self.showSavePopup = false
                    }
                }
            }
            
        .colorScheme(.dark)
        .frame(width: 300, height: 300, alignment: .center)
        #endif
    }
    
    var settingsView: some View {
        #if os(macOS)
        
            List {
                Section(header: Text("Remove trail"), footer: Text("Turning this on may improve performance. When a trail appears, it will dissapear after the given amount in seconds.\n") + Text("App must be restarted for the changes to take effect.").bold()) {
                    Toggle(isOn: self.$stateIsWaitOn) {
                        Text("Remove trail")
                    }
                    if self.stateIsWaitOn {
                        Slider(value: self.$stateWaitValue, in: 5.0...40.0, minimumValueLabel: Text("5"), maximumValueLabel: Text("40")) {
                            Text("Seconds")
                        }
                    }
                }
                
                Section(header: Text("Pause on change"), footer: Text("This settings makes all the views except the active one pause")) {
                    Toggle(isOn: self.$pauseOnChange) {
                        Text("Pause on change")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        UserDefaults.standard.setValue(self.stateWaitValue, forKey: "waitValue")
                        UserDefaults.standard.setValue(self.stateIsWaitOn, forKey: "isWaitOn")
                        self.showSettings = false
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        self.showSettings = false
                    }
                }
            }
            .navigationTitle(Text("Settings"))
            .frame(width: 300, height: 300, alignment: .center)
            .colorScheme(.dark)
        #elseif os(iOS)
        NavigationView {
            List {
                Section(header: Text("Remove trail"), footer: Text("Turning this on may improve performance. When a trail appears, it will dissapear after the given amount in seconds.\n") + Text("App must be restarted for the changes to take effect.").bold()) {
                    Toggle(isOn: self.$stateIsWaitOn) {
                        Text("Remove trail")
                    }
                    if self.stateIsWaitOn {
                        Slider(value: self.$stateWaitValue, in: 5.0...40.0, minimumValueLabel: Text("5"), maximumValueLabel: Text("40")) {
                            Text("Seconds")
                        }
                    }
                }
                
                Section(header: Text("Pause on change"), footer: Text("This settings makes all the views except the active one pause")) {
                    Toggle(isOn: self.$pauseOnChange) {
                        Text("Pause on change")
                    }
                }
            }.listStyle(InsetGroupedListStyle())
            .toolbar {
                ToolbarItem {
                    Button("Save") {
                        UserDefaults.standard.setValue(self.stateWaitValue, forKey: "waitValue")
                        UserDefaults.standard.setValue(self.stateIsWaitOn, forKey: "isWaitOn")
                        self.showSettings = false
                    }
                }
                ToolbarItem(placement: .navigation) {
                    Button("Cancel") {
                        self.showSettings = false
                    }
                }
            }
            .navigationTitle(Text("Settings"))
        }.colorScheme(.dark)
        #endif
    }
    @State var showPausePopup = true
    @State var showSavePopup = false
    @State var showHelpPopup = false
    
    var body: some View {
        #if os(macOS)
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                HStack {
                    if stuffOnStage {
                        MainButton {
                            self.showAlert = true
                        } label: {
                            Text("Clear").frame(width: 40)
                        }.alert(isPresented: self.$showAlert) {
                            Alert(title: Text("Erase Equations?"), message: Text("Do you want to reset the equations too?"),
                                  primaryButton:
                                    Alert.Button.default(Text("Don't erase"), action: {
                                        self.clearAll()
                                    }),
                                  secondaryButton:
                                    Alert.Button.default(Text("Erase"), action: {
                                        self.clearAllAll()
                                        self.xexpr = "0"
                                        self.yexpr = "0"
                                        self.zexpr = "0"
                                        
                                    })
                            )
                        }.colorScheme(.dark)
                    } else {
                        MainButton {
                            if self.zexpr == "0" && self.xexpr == "0" && self.yexpr == "0" {
                                self.showExprPopup.toggle()
                            } else {
                                self.addVectors()
                            }
                            
                        } label: {
                            Text ("Plot").frame(width: 40)
                        }.sheet(isPresented: self.$showExprPopup, onDismiss: {
                            if self.xexpr == "" {
                                self.xexpr = "0"
                            }
                            
                            if self.yexpr == "" {
                                self.yexpr = "0"
                            }
                            
                            if self.zexpr == "" {
                                self.zexpr = "0"
                            }
                        }, content: {
                            self.expressionView
                        })
                    }
                    MainButton(action: {
                        //self.addNode(position: SCNVector3(x: 25, y: 25, z: 0))
                        self.showPopup.toggle()
                    }) {
                        Image(systemName: "plus").frame(width: 30, height: 30, alignment: .center)
                    }.sheet(isPresented: self.$showPopup, content: {
                        self.popupView
                    })
                    
                    MainButton {
                        self.paused.toggle()
                    } label: {
                        Image(systemName: self.paused ? "play.fill" : "pause.fill")
                            .frame(width: 30, height: 30, alignment: .center)
                    }
                    HStack {
                        MainButton(width: self.viewTitle == "New" ? 30 : 100) {
                            self.showSettings.toggle()
                        } label: {
                            Image(systemName: "gear").frame(width: 30, height: 30, alignment: .center)
                            //.padding(5)
                        }.sheet(isPresented: self.$showSettings) {
                            self.settingsView
                        }
                        if self.viewTitle == "New" {
                            MainButton(width: 30) {
                                self.showSavePopup.toggle()
                            } label: {
                                Image(systemName: "square.and.arrow.down").frame(width: 30, height: 30, alignment: .center)
                            }.sheet(isPresented: self.$showSavePopup) {
                                self.savePopup
                            }
                        }
                    }
                    
                }
                .padding()
                .background(BlurMacVisualEffectView(material: .sidebar).clipShape(RoundedRectangle(cornerRadius: 20)))
                
                if self.paused && self.pauseOnChange && self.showPausePopup {
                    
                    VStack(alignment: .leading) {
                        Text("Paused on change is turned on. That means that whenever you switch tabs all the views pause, to improve performance")
                        
                        Button(action: {
                            self.showSettings = true
                        }) {
                            Text("You can turn it of in") + Text(" Settings").foregroundColor(.blue)
                        }.buttonStyle(PlainButtonStyle())
                        
                        HStack {
                            Spacer()
                            Button("OK") {
                                self.showPausePopup = false
                            }
                            Spacer()
                        }
                    }.padding()
                    .font(.system(size: 12))
                    .background(
                        ZStack {
                            BlurMacVisualEffectView(material: .sidebar).clipShape(RoundedRectangle(cornerRadius: 20))
                        }.clipShape(RoundedRectangle(cornerRadius: 10))
                    )
                    .frame(width: 200)
                    
                }
                Spacer()
            }
            HStack {
                Text(self.xexpr)
                Divider().frame(height: 40)
                Text(self.yexpr)
                Divider().frame(height: 40)
                Text(self.zexpr)
                
            }
            .padding()
            .background(BlurMacVisualEffectView(material: .sidebar).clipShape(RoundedRectangle(cornerRadius: 20)))
            .onChange(of: self.viewTitle) { val in
                if self.pauseOnChange {
                    self.paused = true
                }
            }
        }
        #endif
        #if os(iOS)
        ZStack {
            
            VStack {
                HStack {
                    
                    VStack(alignment: self.isLandscape ? .leading : .center) {
                        HStack {
                            if stuffOnStage {
                                MainButton<Text>("Clear") {
                                    
                                    self.showAlert = true
                                }.alert(isPresented: self.$showAlert) {
                                    if self.viewTitle == "New" {
                                        return Alert(title: Text("Erase Equations?"), message: Text("Do you want to reset the equations too?"),
                                              primaryButton:
                                                Alert.Button.default(Text("Don't erase"), action: {
                                                    self.clearAll()
                                                }),
                                              secondaryButton:
                                                Alert.Button.default(Text("Erase"), action: {
                                                    self.clearAllAll()
                                                    self.xexpr = "0"
                                                    self.yexpr = "0"
                                                    self.zexpr = "0"
                                                })
                                        )
                                    } else {
                                        return Alert(title: Text("Are you sure you want to clear?"), message: Text("All the nodes will be deleted."), primaryButton: Alert.Button.default(Text("Cancel")) {
                                            self.showAlert = false
                                        }, secondaryButton: Alert.Button.default(Text("Clear")) {
                                            self.clearAll()
                                        })
                                    }
                                    
                                }.colorScheme(.dark)
                            } else {
                                MainButton<Text> ("Plot") {
                                    if self.zexpr == "0" && self.xexpr == "0" && self.yexpr == "0" {
                                        self.showExprPopup.toggle()
                                    } else {
                                        self.addVectors()
                                    }
                                    
                                }.sheet(isPresented: self.$showExprPopup, onDismiss: {
                                    if self.xexpr == "" {
                                        self.xexpr = "0"
                                    }
                                    
                                    if self.yexpr == "" {
                                        self.yexpr = "0"
                                    }
                                    
                                    if self.zexpr == "" {
                                        self.zexpr = "0"
                                    }
                                }, content: {
                                    self.expressionView
                                })
                            }
                            MainButton {
                                //self.addNode(position: SCNVector3(x: 25, y: 25, z: 0))
                                self.showPopup.toggle()
                            } label: {
                                Image(systemName: "plus")
                                    .frame(width: 30, height: 30, alignment: .center)
                            }.sheet(isPresented: self.$showPopup, content: {
                                self.popupView
                            })
                            MainButton {
                                self.paused.toggle()
                                self.showPausePopup = true
                            } label: {
                                Image(systemName: self.paused ? "play.fill" : "pause.fill")
                                    .frame(width: 30, height: 30, alignment: .center)
                                    //.padding(5)
                            }
                            
                           
                            if self.viewTitle == "New" {
                                MainButton {
                                    self.showSavePopup.toggle()
                                } label: {
                                    Image(systemName: "square.and.arrow.down")
                                        .frame(width: 30, height: 30, alignment: .center)
                                }.sheet(isPresented: self.$showSavePopup) {
                                    self.savePopup
                                }
                            }
                            MainButton {
                                self.showSettings.toggle()
                            } label: {
                                Image(systemName: "gear")
                                    .frame(width: 30, height: 30, alignment: .center)
                                //.padding(5)
                            }.sheet(isPresented: self.$showSettings) {
                                self.settingsView
                            }

                        }
                        .padding()
                        .background(
                            ZStack {
                                BlurView()
                                Color.black.opacity(0.5)
                            }.clipShape(RoundedRectangle(cornerRadius: 10))
                        )
                        
                        if self.paused && self.pauseOnChange && self.showPausePopup {
                            
                            VStack(alignment: .leading) {
                                    Text("Paused on change is turned on. That means that whenever you switch tabs all the views pause, to improve performance")
                                        
                                    Button(action: {
                                        self.showSettings = true
                                    }) {
                                        Text("You can turn it of in") + Text(" Settings").foregroundColor(.blue)
                                    }.buttonStyle(PlainButtonStyle())
                                        
                                HStack {
                                    Spacer()
                                    Button("OK") {
                                        self.showPausePopup = false
                                    }
                                    Spacer()
                                }
                                }.padding()
                                .font(.system(size: 12))
                                .background(
                                    ZStack {
                                        BlurView()
                                        Color.black.opacity(0.5)
                                    }.clipShape(RoundedRectangle(cornerRadius: 10))
                                )
                                .frame(width: 200)
                            
                        }
                        
                    }
                    if self.isLandscape {
                        Spacer()
                    }
                }
                .padding(self.isLandscape ? 10 : 0)
                .onChange(of: self.viewTitle) { val in
                    if self.pauseOnChange {
                        self.paused = true
                    }
                }
                Spacer()
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        
                        Button {
                            self.showHelpPopup.toggle()
                        } label: {
                            Image(systemName: "questionmark")
                                .frame(width: 30, height: 30, alignment: .center)
                                .padding()
                        }.sheet(isPresented: self.$showHelpPopup, content: {
                            NavigationView {
                            HelpView()
                                
                                .toolbar {
                                    Button("Done") {
                                        self.showHelpPopup = false
                                    }
                                }
                            }
                        })
                        .background(
                            ZStack {
                                BlurView()
                                Color.black.opacity(0.5)
                            }.clipShape(RoundedRectangle(cornerRadius: 10))
                        )

                        HStack {
                            if self.showsEquations {
                                HStack {
                                    Text(self.xexpr)
                                    Divider().frame(height: 30)
                                    Text(self.yexpr)
                                    Divider().frame(height: 30)
                                    Text(self.zexpr)
                                    // Text(self.isLandscape ? "LS" : "PS")
                                    
                                }.font(.system(size: self.isLandscape ? 15 : 10))
                                
                            }
                            Button(action: {
                                withAnimation(.spring()) {
                                    self.showsEquations.toggle()
                                }
                            }) {
                                Image(systemName: self.showsEquations ? "xmark" : "function")
                                    .frame(width: 30, height: 30, alignment: .center)
                            }
                        }.padding()
                        .background(
                            ZStack {
                                BlurView()
                                Color.black.opacity(0.5)
                            }.clipShape(RoundedRectangle(cornerRadius: 10))
                        )
                    }
                }
                .padding()
            }.background(Color.clear)
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                guard let scene = UIApplication.shared.windows.first?.windowScene else { return }
                self.isLandscape = scene.interfaceOrientation.isLandscape
            }.colorScheme(.dark)
            
            
        }
        #endif
    }
}

struct HelpView: View {
    var body: some View {
        #if os(iOS)
            List {
                Text("At the bottom you have 2 templates, and an empty one which you can edit.")
                Text("Click the ") + Text("Plot").foregroundColor(Color(.systemBlue)) + Text(" button to plot the phase space. If you click it and you are in a template, it will directly plot the phase space. In you are in the ") + Text("New").foregroundColor(Color(.systemBlue)) + Text(" tab, it will prompt you to introduce the equations.")
                Text("Example equation: 2*x-3*y*z ( good ), 2x-3yx ( bad )")
                Text("To add a node click the ") + Text(Image(systemName: "plus")).foregroundColor(Color(.systemBlue)) + Text(" button.")
                Text("To save a new template click the ") + Text(Image(systemName: "square.and.arrow.down")).foregroundColor(Color(.systemBlue)) + Text(" button")
                Text("For play/pause click the ") + Text(Image(systemName: "play.fill")).foregroundColor(Color(.systemBlue)) + Text("/") + Text(Image(systemName: "pause.fill")).foregroundColor(Color(.systemBlue)) + Text(" button.")
                Text("You can move freely using gestures in the phase space.")
                
            }.listStyle(InsetGroupedListStyle())
            .navigationTitle("Help")
        #elseif os(macOS)
        List {
            Text("At the bottom you have 2 templates, and an empty one which you can edit.")
            Text("Click the ") + Text("Plot").foregroundColor(Color(.systemBlue)) + Text(" button to plot the phase space. If you click it and you are in a template, it will directly plot the phase space. In you are in the ") + Text("New").foregroundColor(Color(.systemBlue)) + Text(" tab, it will prompt you to introduce the equations.")
            Text("Example equation: 2*x-3*y*z ( good ), 2x-3yx ( bad )")
            Text("To add a node click the ") + Text(Image(systemName: "plus")).foregroundColor(Color(.systemBlue)) + Text(" button.")
            Text("To save a new template click the ") + Text(Image(systemName: "square.and.arrow.down")).foregroundColor(Color(.systemBlue)) + Text(" button")
            Text("For play/pause click the ") + Text(Image(systemName: "play.fill")).foregroundColor(Color(.systemBlue)) + Text("/") + Text(Image(systemName: "pause.fill")).foregroundColor(Color(.systemBlue)) + Text(" button.")
            Text("You can move freely using gestures in the phase space.")
            
        }
        #endif
        
    }
}


//
//  MainViewController.swift
//  Vector Phase Plotter
//
//  Created by Alexandru Ariton on 17.06.2021.
//

import Foundation
import SceneKit
import QuartzCore
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif
import SwiftUI
func dx(_ x: CGFloat, y: CGFloat, z: CGFloat, expression: String) -> CGFloat {
    //return -y-z
    let replacedExpr = expression.replacingOccurrences(of: "x", with: "\(x)").replacingOccurrences(of: "y", with: "\(y)").replacingOccurrences(of: "z", with: "\(z)")
    let exc = NSExpressionWithErrorHandler(format: replacedExpr)
    if exc?.errorOfFormat == "No error" {
        let nsExpression = NSExpression(format: replacedExpr)
        
        let value = nsExpression.expressionValue(with: nil, context: nil) as? NSNumber ?? 0
        
        return CGFloat(truncating: value)
    } else {
        return 0.0
    }
}

func dy(_ y: CGFloat, x: CGFloat, z: CGFloat, expression: String) -> CGFloat {
    //return x+0.2*y
    let replacedExpr = expression.replacingOccurrences(of: "x", with: "\(x)").replacingOccurrences(of: "y", with: "\(y)").replacingOccurrences(of: "z", with: "\(z)")
    let exc = NSExpressionWithErrorHandler(format: replacedExpr)
    if exc?.errorOfFormat == "No error" {
        let nsExpression = NSExpression(format: replacedExpr)
        let value = nsExpression.expressionValue(with: nil, context: nil) as? NSNumber ?? 0
        return CGFloat(truncating: value)
    } else {
        
        return 0.0
    }
}

func dz(_ z: CGFloat, x: CGFloat, y: CGFloat, expression: String) -> CGFloat {
    //return 0.2+x*z - 5.7*z
    let replacedExpr = expression.replacingOccurrences(of: "x", with: "\(x)").replacingOccurrences(of: "y", with: "\(y)").replacingOccurrences(of: "z", with: "\(z)")
    let exc = NSExpressionWithErrorHandler(format: replacedExpr)
    if exc?.errorOfFormat == "No error" {
        let nsExpression = NSExpression(format: replacedExpr)
        let value = nsExpression.expressionValue(with: nil, context: nil) as? NSNumber ?? 0
        return CGFloat(truncating: value)
    } else {
        
        return 0.0
    }
}
var diva: CGFloat = 0.4

/*
 [SCNVector3(x*diva, y*diva, z*diva),
 SCNVector3(x: (CGFloat(x) + newY*tg)*diva, y: (CGFloat(y) + newY)*diva, z: (CGFloat(z) + newY*ztg)*diva)]
 */
extension SCNVector3 {
    #if os(macOS)
    func newPosition(dt: CGFloat, expressions: (x: String, y: String, z: String)) -> SCNVector3 {
        let x = CGFloat(self.x) / diva
        let y = CGFloat(self.y) / diva
        let z = CGFloat(self.z) / diva
        var ddx: CGFloat = dx(CGFloat(x), y: CGFloat(y), z: CGFloat(z), expression: expressions.x)
        var ddy: CGFloat = dy(CGFloat(y), x: CGFloat(x), z: CGFloat(z), expression: expressions.y)
        var ddz: CGFloat = dz(CGFloat(z), x: CGFloat(x), y: CGFloat(y), expression: expressions.z)
        var sw = false
        if ddy == 0 {
            sw = true
            ddy = 0.00000000000001
        }
        var tg = ddx / ddy
        var ztg = ddz / ddy
        var newY: CGFloat = sqrt(0.2/(1+tg*tg+ztg*ztg)) * ddy / (abs(ddy))
        var ytg: CGFloat = sw == true ? 0.0 : 1.0
        let pxx = SCNVector3(x: ((CGFloat(x) + newY*tg)*diva), y: ((CGFloat(y) + newY*ytg)*diva), z: ((CGFloat(z)+newY*ztg)*diva))
        print(pxx)
        return SCNVector3(x: ((CGFloat(x) + newY*tg)*diva), y: ((CGFloat(y) + newY*ytg)*diva), z: ((CGFloat(z)+newY*ztg)*diva))
    }
    #elseif os(iOS)
    func newPosition(dt: CGFloat, expressions: (x: String, y: String, z: String)) -> SCNVector3 {
        let x = CGFloat(self.x) / diva
        let y = CGFloat(self.y) / diva
        let z = CGFloat(self.z) / diva
        var ddx: CGFloat = dx(CGFloat(x), y: CGFloat(y), z: CGFloat(z), expression: expressions.x)
        var ddy: CGFloat = dy(CGFloat(y), x: CGFloat(x), z: CGFloat(z), expression: expressions.y)
        var ddz: CGFloat = dz(CGFloat(z), x: CGFloat(x), y: CGFloat(y), expression: expressions.z)
        var sw = false
        if ddy == 0 {
            sw = true
            ddy = 0.000000000001
            //return SCNVector3(0,0,0)
        }
            var tg = ddx / ddy
            var ztg = ddz / ddy
            var newY: CGFloat = sqrt(0.2/(1+tg*tg+ztg*ztg)) * ddy / (abs(ddy))
            var ytg: CGFloat = sw == true ? 0.0 : 1.0
            let pxx = SCNVector3(x: Float((CGFloat(x) + newY*tg)*diva), y: Float((CGFloat(y) + newY*ytg)*diva), z: Float((CGFloat(z)+newY*ztg)*diva))
            print(pxx)
                
            return SCNVector3(x: Float((CGFloat(x) + newY*tg)*diva), y: Float((CGFloat(y) + newY*ytg)*diva), z: Float((CGFloat(z)+newY*ztg)*diva))
        
    }
    #endif
}


let indices: [UInt16] = [
    0, 1, 2
]
#if os(macOS)
var colorDict: [Color: NSColor] = [.blue: .blue, .yellow: .yellow, .orange: .orange, .green: .green, .pink: .systemPink]
#endif

#if os(iOS)
var colorDict: [Color: UIColor] = [.blue: .blue, .yellow: .yellow, .orange: .orange, .green: .green, .pink: .systemPink]
#endif


func axa(vertices vertic: [SCNVector3], indices ind: [UInt16] = [0,1,2], color: Color = .white) -> SCNNode {
    var source = SCNGeometrySource(vertices: vertic)
    var element = SCNGeometryElement(indices: ind, primitiveType: .triangles)
    let geometry = SCNGeometry(sources: [source], elements: [element])
    geometry.materials[0].diffuse.contents = colorDict[color] ?? .white
    geometry.materials[0].isDoubleSided = true
    
    let axe = SCNNode(geometry: geometry)
    return axe
}
#if os(macOS)
class GameViewController: NSViewController {
    override func loadView() {
        self.view = SCNView()
    }
    var xexpr = ""
    var yexpr = ""
    var zexpr = ""
    init(xexpr: String, yexpr: String, zexpr: String) {
        super.init(nibName: nil, bundle: nil)
        self.xexpr = xexpr
        self.yexpr = yexpr
        self.zexpr = zexpr
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // create a new scene
        let scene = SCNScene()
        let putView = NSHostingView(rootView: PutNode(scene: scene, xexpr: self.xexpr, yexpr: self.yexpr, zexpr: self.zexpr))
        self.view.addSubview(putView)
        
        putView.translatesAutoresizingMaskIntoConstraints = false
        putView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20).isActive = true
        putView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // create and add a light to the scene
        //        let lightNode = SCNNode()
        //        lightNode.light = SCNLight()
        //        lightNode.light!.type = .omni
        //        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        //        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        //        let ambientLightNode = SCNNode()
        //        ambientLightNode.light = SCNLight()
        //        ambientLightNode.light!.type = .ambient
        //        ambientLightNode.light!.color = NSColor.darkGray
        //        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the ship node
        let verticx: [SCNVector3] = [
            SCNVector3(-50+0.1, 0+0.1, 0+0.1),
            SCNVector3(50, 0, 0),
            SCNVector3(-50-0.1, 0-0.1, 0-0.1)
        ]
        
        let axe = axa(vertices: verticx)
        axe.name = "Axe"
        scene.rootNode.addChildNode(axe)
        axe.name = "Axe"
        let verticy: [SCNVector3] = [
            SCNVector3(0+0.1, -50+0.1, 0+0.1),
            SCNVector3(0, 50, 0),
            SCNVector3(0-0.1, 50-0.1, 0-0.1)
        ]
        
        let yaxe = axa(vertices: verticy)
        yaxe.name = "Axe"
        scene.rootNode.addChildNode(yaxe)
        yaxe.name = "Axe"
        
        let verticz: [SCNVector3] = [
            SCNVector3(0+0.1, 0+0.1, 50+0.1),
            SCNVector3(0, 0, -50),
            SCNVector3(0-0.1, 0-0.1, 50-0.1)
        ]
        
        let zaxe = axa(vertices: verticz)
        zaxe.name = "Axe"
        scene.rootNode.addChildNode(zaxe)
        zaxe.name = "Axe"
        
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = false
        
        // configure the view
        scnView.backgroundColor = NSColor.textBackgroundColor
        
        // Add a click gesture recognizer
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        var gestureRecognizers = scnView.gestureRecognizers
        
    }
    
    @objc
    func handleClick(_ gestureRecognizer: NSGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are clicked
        let p = gestureRecognizer.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = NSColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = NSColor.red
            
            SCNTransaction.commit()
        }
    }
}
#elseif os(iOS)
class GameViewController: UIViewController {
    override func loadView() {
        self.view = SCNView()
    }
    var xexpr = ""
    var yexpr = ""
    var zexpr = ""
    init(xexpr: String, yexpr: String, zexpr: String) {
        super.init(nibName: nil, bundle: nil)
        self.xexpr = xexpr
        self.yexpr = yexpr
        self.zexpr = zexpr
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene()
        #if os(macOS)
        let putView = NSHostingView(rootView: PutNode(scene: scene, xexpr: self.xexpr, yexpr: self.yexpr, zexpr: self.zexpr).colorScheme(.dark))
        #elseif os(iOS)
        let putView = UIHostingController(rootView: PutNode(scene: scene, xexpr: self.xexpr, yexpr: self.yexpr, zexpr: self.zexpr).colorScheme(.dark))
        #endif
        
        #if os(macOS)
        self.view.addSubview(putView)
        putView.translatesAutoresizingMaskIntoConstraints = false
        putView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20).isActive = true
        putView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
        #elseif os(iOS)
        putView.view.backgroundColor = UIColor.clear
        self.view.addSubview(putView.view)
        putView.view.translatesAutoresizingMaskIntoConstraints = false
        putView.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        putView.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        putView.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        putView.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        putView.view.layer.backgroundColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0)
        #endif
        
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(0, 0, 15)
        
        // create and add a light to the scene
        //        let lightNode = SCNNode()
        //        lightNode.light = SCNLight()
        //        lightNode.light!.type = .omni
        //        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        //        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        //        let ambientLightNode = SCNNode()
        //        ambientLightNode.light = SCNLight()
        //        ambientLightNode.light!.type = .ambient
        //        ambientLightNode.light!.color = NSColor.darkGray
        //        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the ship node
        let verticx: [SCNVector3] = [
            SCNVector3(-50+0.1, 0+0.1, 0+0.1),
            SCNVector3(50, 0, 0),
            SCNVector3(-50-0.1, 0-0.1, 0-0.1)
        ]
        
        let axe = axa(vertices: verticx)
        scene.rootNode.addChildNode(axe)
        
        let verticy: [SCNVector3] = [
            SCNVector3(0+0.1, -50+0.1, 0+0.1),
            SCNVector3(0, 50, 0),
            SCNVector3(0-0.1, 50-0.1, 0-0.1)
        ]
        
        let yaxe = axa(vertices: verticy)
        scene.rootNode.addChildNode(yaxe)
        
        
        let verticz: [SCNVector3] = [
            SCNVector3(0+0.1, 0+0.1, 50+0.1),
            SCNVector3(0, 0, -50),
            SCNVector3(0-0.1, 0-0.1, 50-0.1)
        ]
        
        let zaxe = axa(vertices: verticz)
        scene.rootNode.addChildNode(zaxe)
        
        
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = false
        
        // configure the view
        #if os(macOS)
        scnView.backgroundColor = NSColor.textBackgroundColor
        #endif
        
        #if os(iOS)
        scnView.backgroundColor = UIColor.textBackgroundColor
        #endif
        // Add a click gesture recognizer
        
        var gestureRecognizers = scnView.gestureRecognizers
        
    }
    
}
#endif
#if os(iOS)
struct SelectiveRoundedRectangle: Shape {
    var cornerRadius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    init(cornerRadius: CGFloat, rounding corners: UIRectCorner) {
        self.cornerRadius = cornerRadius
        self.corners = corners
    }
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        return Path(path.cgPath)
    }
}
#endif

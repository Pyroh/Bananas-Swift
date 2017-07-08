//
//  AAPLSceneView.swift
//  Bananas
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/22.
//
//
/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:

  The view displaying the game scene. Handles keyboard (OS X) and touch (iOS) input for controlling the game, and forwards other click/touch events to the SpriteKit overlay UI.

 */

import SceneKit

let AAPLLeftKey = "AAPLLeftKey"
let AAPLRightKey = "AAPLRightKey"
let AAPLJumpKey = "AAPLJumpKey"
let AAPLRunKey = "AAPLRunKey"

@objc(AAPLSceneView)
class AAPLSceneView: SCNView {
    
    var keysPressed: Set<String> = []
    
    // Keyspressed is our set of current inputs
    private func updateKey(_ key: String, isPressed: Bool) {
        if isPressed {
            self.keysPressed.insert(key)
        } else {
            self.keysPressed.remove(key)
        }
    }
    
    #if os(iOS)
    
    init() {
        super.init(frame: CGRect(), options: nil)
        self.setupGestureRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupGestureRecognizer()
    }
    private func setupGestureRecognizer() {
        let gesture = AAPLVirtualDPadGestureRecognizer(target: self, action: #selector(AAPLSceneView.handleVirtualDPadAction(_:)))
        gesture.delegate = self
        self.addGestureRecognizer(gesture)
    }
    
    @objc func handleVirtualDPadAction(_ gesture: AAPLVirtualDPadGestureRecognizer) {
        self.updateKey(AAPLLeftKey, isPressed: gesture.leftPressed)
        self.updateKey(AAPLRightKey, isPressed: gesture.rightPressed)
        self.updateKey(AAPLRunKey, isPressed: gesture.running)
        self.updateKey(AAPLJumpKey, isPressed: gesture.buttonAPressed)
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.scene != nil {
            return AAPLGameSimulation.sim.gameState == .inGame
        }
        return false
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let skScene = self.overlaySKScene as! AAPLInGameScene
        let touch = touches.first!
        let p = touch.location(in: skScene)
        skScene.touchUpAtPoint(p)
        super.touchesEnded(touches, with: event)
    }
    
    #else
    
    override func keyDown(with theEvent: NSEvent) {
        
        let keyHit = theEvent.characters?.utf16.first ?? 0
        
        
        if theEvent.modifierFlags.contains(.shift) {
            self.updateKey(AAPLRunKey, isPressed: true)
        }
        
        switch keyHit {
        case UInt16(NSRightArrowFunctionKey):
            self.updateKey(AAPLRightKey, isPressed: true)
        case UInt16(NSLeftArrowFunctionKey):
            self.updateKey(AAPLLeftKey, isPressed: true)
        case "r":
            self.updateKey(AAPLRunKey, isPressed: true)
        case " ":
            self.updateKey(AAPLJumpKey, isPressed: true)
        default:
            break
        }
        
        super.keyDown(with: theEvent)
    }
    
    override func keyUp(with theEvent: NSEvent) {
        
        let keyReleased = theEvent.characters?.utf16.first ?? 0
        
        switch keyReleased {
        case UInt16(NSRightArrowFunctionKey):
            self.updateKey(AAPLRightKey, isPressed: false)
        case UInt16(NSLeftArrowFunctionKey):
            self.updateKey(AAPLLeftKey, isPressed: false)
        case "r":
            self.updateKey(AAPLRunKey, isPressed: false)
        case " ":
            self.updateKey(AAPLJumpKey, isPressed: false)
        default:
            break
        }
        
        if theEvent.modifierFlags.contains(.shift) {
            self.updateKey(AAPLRunKey, isPressed: false)
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        let skScene = self.overlaySKScene as! AAPLInGameScene
        let p = skScene.convertPoint(fromView: event.locationInWindow)
        skScene.touchUpAtPoint(p)
        
        super.mouseUp(with: event)
    }
    
    #endif
    
}
#if os(iOS)
    extension AAPLSceneView: UIGestureRecognizerDelegate {}
#endif

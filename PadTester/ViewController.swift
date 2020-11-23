//
//  ViewController.swift
//  PadTester
//
//  Created by Christophe on 22/11/2020.
//

import Cocoa;
import GameController;

class ViewController: NSViewController {
    
    @IBOutlet private var controllerCount : NSTextField?;
    @IBOutlet private var controllerList : NSPopUpButton?;
    @IBOutlet private var controllerDetails : NSTextField?;
    
    private var currentController : GCController?;

    override func viewDidLoad() {
        super.viewDidLoad();

        let center = NotificationCenter.default;
        let mainQueue = OperationQueue.main;
        center.addObserver(forName: .GCControllerDidConnect, object: nil, queue: mainQueue) { (notif) in
            self.updateControllers();
        }
        center.addObserver(forName: .GCControllerDidDisconnect, object: nil, queue: mainQueue) { (notif) in
            self.updateControllers();
        }
        
        center.addObserver(forName: NSPopUpButton.willPopUpNotification, object: controllerList!, queue: mainQueue) { (notif) in
            self.updateControllerDetails(newController: GCController.controllers()[self.controllerList!.indexOfSelectedItem]);
        };
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    override func viewDidAppear() {
        updateControllers();
    }
    
    private func updateControllers() {
        controllerCount?.stringValue = "Controllers: \(GCController.controllers().count)";
        
        if GCController.controllers().count == 0 {
            controllerList?.isEnabled = false;
            controllerList?.removeAllItems();
            updateControllerDetails(newController: nil);
        }
        else {
            controllerList?.isEnabled = true;
            for (index, controller) in GCController.controllers().enumerated() {
                controllerList?.addItem(withTitle: "\(index + 1): \(controller.vendorName!)");
            }
            updateControllerDetails(newController: GCController.controllers()[0]);
        }
    }
    
    private func updateControllerDetails(newController: GCController?) {
        guard newController != currentController else {
            return;
        }
        
        if currentController != nil {
            if currentController!.extendedGamepad != nil {
                currentController!.extendedGamepad!.valueChangedHandler = nil;
            }
            else {
                currentController!.microGamepad!.valueChangedHandler = nil;
            }
        }
        
        currentController = newController;
        
        if currentController != nil {
            if currentController!.extendedGamepad != nil {
                currentController!.extendedGamepad!.valueChangedHandler = { (pad, element) -> Void in
                    self.updateCurrentControllerDetails();
                };
            }
            else {
                currentController!.microGamepad!.valueChangedHandler = { (pad, element) -> Void in
                    self.updateCurrentControllerDetails();
                };
            }
        }
        
        updateCurrentControllerDetails()
    }
    
    private func updateCurrentControllerDetails() {
        guard let controller = currentController else {
            controllerDetails?.stringValue = "Select a controller to display details"
            return;
        }
        
        var details = "Vendor Name: \(controller.vendorName!)";
        
        let type = controller.extendedGamepad != nil ? "extended" : "micro";
        details += "\nType: \(type)";
        
        details += "\n\n";
        if (controller.extendedGamepad != nil) {
            details += updateCurrentExtendedGamepadDetails(extendedGamepad: controller.extendedGamepad);
        }
        else {
            details += updateCurrentMicroGamepadDetails(microGamepad: controller.microGamepad);
        }
        
        controllerDetails?.stringValue = details;
    }
    
    private func updateCurrentExtendedGamepadDetails(extendedGamepad: GCExtendedGamepad?) -> String {
        guard let pad = extendedGamepad else {
            return "";
        }
        
        var detailList : [String] = [];
        
        detailList.append("Dpad:");
        detailList.append("    Up: \(pad.dpad.up.isPressed) (\(pad.dpad.up.value))");
        detailList.append("    Down: \(pad.dpad.down.isPressed) (\(pad.dpad.down.value))");
        detailList.append("    Left: \(pad.dpad.left.isPressed) (\(pad.dpad.left.value))");
        detailList.append("    Right: \(pad.dpad.right.isPressed) (\(pad.dpad.right.value))");
        detailList.append("");
        detailList.append("A button: \(pad.buttonA.isPressed) (\(pad.buttonA.value))");
        detailList.append("B button: \(pad.buttonB.isPressed) (\(pad.buttonB.value))");
        detailList.append("X button: \(pad.buttonX.isPressed) (\(pad.buttonX.value))");
        detailList.append("Y button: \(pad.buttonY.isPressed) (\(pad.buttonY.value))");
        detailList.append("");
        detailList.append("Left shoulder: \(pad.leftShoulder.isPressed) (\(pad.leftShoulder.value))");
        detailList.append("Left trigger: \(pad.leftTrigger.isPressed) (\(pad.leftTrigger.value))");
        detailList.append("");
        detailList.append("Right shoulder: \(pad.rightShoulder.isPressed) (\(pad.rightShoulder.value))");
        detailList.append("Right trigger: \(pad.rightTrigger.isPressed) (\(pad.rightTrigger.value))");
        detailList.append("");
        detailList.append("Left stick:");
        detailList.append("    x: \(pad.leftThumbstick.xAxis.value)");
        detailList.append("    y: \(pad.leftThumbstick.yAxis.value)");
        if let button = pad.leftThumbstickButton {
            detailList.append("Left stick button: \(button.isPressed) (\(button.value))");
        }
        else {
            detailList.append("Left stick button: Not available");
        }
        detailList.append("Right stick:");
        detailList.append("    x: \(pad.rightThumbstick.xAxis.value)");
        detailList.append("    y: \(pad.rightThumbstick.yAxis.value)");
        if let button = pad.rightThumbstickButton {
            detailList.append("Right stick button: \(button.isPressed) (\(button.value))");
        }
        else {
            detailList.append("Right stick button: Not available");
        }
        detailList.append("");
        detailList.append("Menu button: \(pad.buttonMenu.isPressed)");
        if let button = pad.buttonOptions {
            detailList.append("Options button: \(button.isPressed)");
        }
        else {
            detailList.append("Options button: Not available");
        }
        
        return detailList.joined(separator: "\n");
    }
    
    private func updateCurrentMicroGamepadDetails(microGamepad: GCMicroGamepad?) -> String {
        guard let pad = microGamepad else {
            return "";
        }
        
        var detailList : [String] = [];
        
        detailList.append("Dpad:");
        detailList.append("    Up: \(pad.dpad.up.isPressed) (\(pad.dpad.up.value))");
        detailList.append("    Down: \(pad.dpad.down.isPressed) (\(pad.dpad.down.value))");
        detailList.append("    Left: \(pad.dpad.left.isPressed) (\(pad.dpad.left.value))");
        detailList.append("    Right: \(pad.dpad.right.isPressed) (\(pad.dpad.right.value))");
        detailList.append("");
        detailList.append("A button: \(pad.buttonA.isPressed) (\(pad.buttonA.value))");
        detailList.append("X button: \(pad.buttonX.isPressed) (\(pad.buttonX.value))");
        detailList.append("");
        detailList.append("Menu button: \(pad.buttonMenu.isPressed)");
        
        return detailList.joined(separator: "\n");
    }
    
}

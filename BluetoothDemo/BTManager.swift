//
//  BTManager.swift
//  BluetoothDemo
//
//  Created by Devansh Vyas on 25/02/23.
//

import Combine
import CoreBluetooth

final class BluetoothManager: NSObject {
    
    static let shared: BluetoothManager = .init()
    private var centralManager: CBCentralManager!
    
    var stateSubject: PassthroughSubject<CBManagerState, Never> = .init()
    var peripheralSubject: PassthroughSubject<CBPeripheral, Never> = .init()
    var connectedPeripheralSubject: PassthroughSubject<CBPeripheral, Never> = .init()
    
    var isScanning: Bool {
        centralManager.isScanning
    }
    
    override init() {
        super.init()
        centralManager = .init(delegate: self, queue: .main)
    }
    
    func start() {
        centralManager.scanForPeripherals(withServices: nil)
    }
    
    func stop() {
        centralManager.stopScan()
    }
    
    func connect(_ peripheral: CBPeripheral) {
        peripheral.delegate = self
        print("connection: ",peripheral.state.rawValue)
        centralManager.connect(peripheral)
    }
}

extension BluetoothManager: CBPeripheralDelegate, CBCentralManagerDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("peripheral", peripheral)
    }
    
    func centralManager( _ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        peripheralSubject.send(peripheral)
        print("Discovered \(peripheral.name ?? "")")
    }
    
    func centralManagerDidUpdateState( _ central: CBCentralManager) {
        if !central.isScanning {
            central.scanForPeripherals(withServices: nil)
        }
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
        @unknown default:
            fatalError()
        }
        stateSubject.send(central.state)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to " + peripheral.name!)
        connectedPeripheralSubject.send(peripheral)
    }
    
    func centralManager( _ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error!)
    }
}

//
//  BTViewModel.swift
//  BluetoothDemo
//
//  Created by Devansh Vyas on 25/02/23.
//

import SwiftUI
import Combine
import CoreBluetooth

final class BTViewModel: ObservableObject {
    @Published var state: CBManagerState = .unknown
    @Published var peripherals: [CBPeripheral] = []
    
    private lazy var manager: BluetoothManager = .shared
    private lazy var cancellables: Set<AnyCancellable> = .init()
    
    var toggleText: String {
        (manager.isScanning ? "Stop" : "Start") + " scanning"
    }
    
    deinit {
        cancellables.cancel()
    }
    
    func start() {
        manager.stateSubject
            .sink { [weak self] state in
                self?.state = state
            }
            .store(in: &cancellables)
        manager.peripheralSubject
            .filter { [weak self] in self?.peripherals.contains($0) == false }
            .sink { [weak self] in self?.peripherals.append($0) }
            .store(in: &cancellables)
        manager.connectedPeripheralSubject
            .filter { [weak self] in self?.peripherals.contains($0) ?? false }
            .sink { [weak self] peripheral in
                self?.peripherals.removeAll(where: { $0 == peripheral})
                self?.peripherals.insert(peripheral, at: 0)
            }
            .store(in: &cancellables)
        manager.start()
    }
    
    func toggleAction() {
        if manager.isScanning {
            manager.stop()
            peripherals = []
        } else {
            start()
        }
    }
    
    func connect(peripheral: CBPeripheral) {
        manager.connect(peripheral)
    }
}

extension Set where Element: Cancellable {
    func cancel() {
        forEach { $0.cancel() }
    }
}

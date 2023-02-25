//
//  BTHomeView.swift
//  BluetoothDemo
//
//  Created by Devansh Vyas on 25/02/23.
//

import SwiftUI
import CoreBluetooth

struct BTHomeView: View {
    
    @StateObject private var viewModel: BTViewModel = .init()
    @State private var isRotating = 0.0
    
    private var peripherals: [CBPeripheral] {
        viewModel.peripherals.sorted { left, right in
            guard let leftName = left.name else {
                return false
            }
            guard let rightName = right.name else {
                return true
            }
            return leftName < rightName
        }
    }
    
    var body: some View {
        VStack {
            topStaticView
            devicesListView
            Button {
                viewModel.toggleAction()
            } label: {
                Text(viewModel.toggleText)
                    .bold()
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
            .frame(height: 30)
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .preferredColorScheme(.dark)
        .onAppear {
            viewModel.start()
        }
    }
    
    @ViewBuilder
    private var topStaticView: some View {
        VStack {
            ZStack {
                ringView()
                ringView(isOuter: true)
                    .frame(width: 100, height: 100)
                Image("bluetooth")
                    .scaledToFit()
                    .padding()
                    .background(Color.blue)
                    .clipShape(Capsule())
                    .frame(width: 75, height: 75)
            }
            .frame(width: 125, height: 125)
            .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
            Text("SEARCHING")
                .bold()
                .font(.system(size: 25))
            Text("Remember to keep your scooter on and within 6 feet.")
                .padding(EdgeInsets(top: 20, leading: 10, bottom: 35, trailing: 10))
        }
    }
    
    @ViewBuilder
    private var bottomListView: some View {
        VStack {
            HStack {
                Text("Scooter found:")
                    .bold()
                Spacer()
            }
            .padding(.horizontal)
            if viewModel.state == .poweredOn {
                if peripherals.isEmpty {
                    Text("No nearby BLE devices available")
                } else {
                    devicesListView
                }
            } else {
                Text("Please enable bluetooth to search devices")
            }
        }
    }
    
    @ViewBuilder
    private var devicesListView: some View {
        List(peripherals, id: \.identifier) { peripheral in
            HStack {
                Image("bluetooth")
                    .resizable()
                    .foregroundColor(Color.blue)
                    .frame(width: 20, height: 20)
                if let peripheralName = peripheral.name {
                    Text(peripheralName)
                } else {
                    Text("Unknown")
                        .opacity(0.2)
                }
                if peripheral.state == .connected {
                    Text("Connected")
                        .font(.system(size: 18))
                        .opacity(0.2)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .resizable()
                    .foregroundColor(Color.blue)
                    .frame(width: 8, height: 15)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.connect(peripheral: peripheral)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.black)
        .frame(maxHeight: UIScreen.main.bounds.height/2.5)
    }
    
    func ringView(isOuter: Bool = false) -> some View {
        return Circle()
            .trim(from: 0.3, to: 1)
            .stroke(
                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0)]), startPoint: .topTrailing, endPoint: .bottomLeading)
                , style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, miterLimit: .infinity, dash: [20, 0], dashPhase: 0))
            .rotationEffect(.degrees(isRotating + (isOuter ? 0 : 180)))
            .onAppear {
                withAnimation(.linear(duration: 0.5)
                    .speed(0.1).repeatForever(autoreverses: false)) {
                        isRotating = 360.0
                    }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BTHomeView()
    }
}

// swift-tools-version: 5.9
import PackageDescription
import AppleProductTypes
let package = Package(name: "HamsiKasse", platforms: [.iOS("17.0")], products: [.iOSApplication(name: "HamsiKasse", targets: ["AppModule"], bundleIdentifier: "org.ditibwoerth.hamsikasse", teamIdentifier: "", displayVersion: "1.0", bundleVersion: "1", appIcon: .placeholder(icon: .star), accentColor: .presetColor(.green), supportedDeviceFamilies: [.pad], supportedInterfaceOrientations: [.landscapeLeft, .landscapeRight, .portrait, .portraitUpsideDown], capabilities: [.bluetoothAlways(purposeString: "Bluetooth-Verbindung zum S1 Bondrucker")])], targets: [.executableTarget(name: "AppModule", path: ".", exclude: ["LICENSE.txt"], resources: [.copy("Kasse.html")])])

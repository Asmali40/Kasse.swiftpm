import SwiftUI
import WebKit
import CoreBluetooth
@main struct HamsiApp: App { var body: some Scene { WindowGroup { KasseScreen() } } }
@MainActor struct KasseScreen: View {
 @StateObject var printer = BluetoothPrinter()
 var body: some View { VStack(spacing: 0) {
 HStack { Button("Drucker suchen") { printer.startDiscovery() }.disabled(printer.busy)
 Menu(printer.selectedDevice?.name ?? "S1 auswählen") { ForEach(printer.devices, id: \.identifier) { d in Button(d.name ?? "S1") { printer.select(d) } } }.disabled(printer.busy)
 Spacer(); Text(printer.message).font(.caption)
 }.padding().background(Color(uiColor: .secondarySystemBackground))
 KasseWeb(printer: printer)
 }.task { printer.startDiscovery() } }
}
@MainActor struct KasseWeb: UIViewRepresentable {
 let printer: BluetoothPrinter
 func makeCoordinator() -> Coordinator { Coordinator(printer) }
 func makeUIView(context: Context) -> WKWebView {
 let config = WKWebViewConfiguration(); config.websiteDataStore = .default()
 config.userContentController.addScriptMessageHandler(context.coordinator, contentWorld: .page, name: "printBon")
 let view = WKWebView(frame: .zero, configuration: config)
 if let url = Bundle.module.url(forResource: "Kasse", withExtension: "html") { view.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent()) }
 return view
 }
 func updateUIView(_ uiView: WKWebView, context: Context) {}
 @MainActor final class Coordinator: NSObject, WKScriptMessageHandlerWithReply {
 let printer: BluetoothPrinter
 init(_ printer: BluetoothPrinter) { self.printer = printer }
 func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage, replyHandler: @escaping (Any?, String?) -> Void) {
 guard let text = message.body as? String, let device = printer.selectedDevice else { replyHandler(nil,"Bitte zuerst S1-Drucker auswählen."); return }
 Task { @MainActor in
 do { let job = try Receipt.build(text); try await printer.printJob(job, to: device); replyHandler(true,nil) }
 catch { replyHandler(nil,error.localizedDescription) }
 }
 }
 }
}

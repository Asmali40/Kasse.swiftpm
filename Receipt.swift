import Foundation
import UIKit
struct PrintFailure: LocalizedError { let message: String; init(_ message: String) { self.message = message }; var errorDescription: String? { message } }
struct PrintOptions: Codable { var density = 1 }
struct PrintJob { let chunks: [Data] }
enum NativeCore { static func ready(_ raw: UInt8) throws { guard raw & 0x5F == 0 else { throw PrintFailure("Drucker nicht bereit (Status \(raw))") } } }
@MainActor enum Receipt {
 static func build(_ text: String) throws -> PrintJob {
 let lines = text.split(separator: "\n").map(String.init)
 guard lines.count >= 7, lines.count <= 20 else { throw PrintFailure("Ungültiger Bon") }
 let width = 384
 let rows = lines.map { line -> (String, UIFont, CGFloat, Bool) in
 let rule = line.hasPrefix("---")
 let bold = line == "Ditib Wörth" || line.hasPrefix("Toplam:")
 var size: CGFloat = line == "Ditib Wörth" ? 43 : line.hasPrefix("Toplam:") ? 35 : (line == "Hamsi Festivali" || line == "Bahnhofstraße 40" || line == "76744 Wörth am Rhein" ? 25 : 30)
 var font = UIFont.systemFont(ofSize: size, weight: bold ? .bold : .regular)
 while (line as NSString).size(withAttributes: [.font:font]).width > 360 && size > 12 { size -= 0.5; font = UIFont.systemFont(ofSize:size, weight:bold ? .bold : .regular) }
 return (line,font,rule ? 10 : ceil(font.lineHeight)+1,rule)
 }
 let height = Int(rows.reduce(CGFloat(16)) { $0 + $1.2 })
 let format = UIGraphicsImageRendererFormat(); format.scale = 1; format.opaque = true
 let image = UIGraphicsImageRenderer(size: CGSize(width:width,height:height),format:format).image { ctx in
 UIColor.white.setFill(); ctx.fill(CGRect(x:0,y:0,width:width,height:height)); var y: CGFloat = 8
 for (line,font,h,rule) in rows { if rule { UIColor.black.setFill(); ctx.fill(CGRect(x:12,y:y+4,width:360,height:2)) } else { let attrs: [NSAttributedString.Key:Any] = [.font:font,.foregroundColor:UIColor.black]; let w = (line as NSString).size(withAttributes:attrs).width; (line as NSString).draw(at:CGPoint(x:(384-w)/2,y:y),withAttributes:attrs) }; y += h }
 }
 guard let cg = image.cgImage else { throw PrintFailure("Bonbild fehlt") }
 var gray = [UInt8](repeating:255,count:width*height)
 try gray.withUnsafeMutableBytes { ptr in
 guard let ctx = CGContext(data:ptr.baseAddress,width:width,height:height,bitsPerComponent:8,bytesPerRow:width,space:CGColorSpaceCreateDeviceGray(),bitmapInfo:CGImageAlphaInfo.none.rawValue) else { throw PrintFailure("Bonbild fehlgeschlagen") }; ctx.draw(cg,in:CGRect(x:0,y:0,width:width,height:height))
 }
 var raster = Data([0x1D,0x76,0x30,0,48,0,UInt8(height & 255),UInt8(height >> 8)])
 for i in stride(from:0,to:gray.count,by:8) { var b: UInt8 = 0; for j in 0..<8 { if gray[i+j] < 128 { b |= UInt8(128 >> j) } }; raster.append(b) }
 return PrintJob(chunks:[Data([0x10,0xFF,0x10,0,1]),Data(count:12),Data([0x10,0xFF,0xF1,3]),raster,Data([0x1B,0x4A,64]),Data([0x10,0xFF,0xF1,0x45])])
 }
}

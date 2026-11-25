# Kassentool – Hamsi Festivali

Ein plattformübergreifendes Point-of-Sale-System (POS) für den Verkauf von Speisen bei Veranstaltungen der DITIB Wörth.

Die Anwendung ermöglicht die Erfassung von Bestellungen, die automatische Berechnung des Gesamtbetrags, die lokale Verwaltung von Verkaufsstatistiken sowie den direkten Druck von Abholbons über einen S1-Bluetooth-Thermodrucker.

## Features

- Responsive und touchoptimierte Benutzeroberfläche
- Unterstützung für Windows und iPadOS
- Produktverwaltung mit vordefinierten Preisen
- Warenkorb mit dynamischer Mengenanpassung
- Automatische Gesamtpreisberechnung
- Direktdruck ohne zusätzlichen Druckdialog
- Erneuter Ausdruck abgeschlossener Bestellungen
- Fortlaufende Bestellnummern
- Interne Kunden- und Umsatzstatistik
- Persistente lokale Datenspeicherung
- Türkischsprachiges Bonlayout
- Offline-Betrieb ohne externen Server

## Tech Stack

| Technologie | Verwendungszweck |
|---|---|
| HTML5 | Benutzeroberfläche |
| CSS3 | Layout und responsives Design |
| JavaScript | Anwendungslogik und Verkaufsverwaltung |
| PowerShell | Windows-Druckschnittstelle |
| Swift | Native iPadOS-Anwendung |
| SwiftUI | Native Anwendungsstruktur |
| WebKit / WKWebView | Integration der bestehenden Weboberfläche unter iPadOS |
| CoreBluetooth | Bluetooth-Kommunikation unter iPadOS |
| S1Print | Grundlage der Druckerkommunikation |

## Architecture

Die Anwendung verwendet eine gemeinsame Weboberfläche mit plattformspezifischen Druckschnittstellen.

```text
                  Kassentool
                      |
            HTML / CSS / JavaScript
                      |
              Application Logic
                      |
          +-----------+-----------+
          |                       |
       Windows                  iPadOS
          |                       |
      PowerShell             Swift / WebKit
          |                       |
   System Print API          CoreBluetooth
          |                       |
          +-----------+-----------+
                      |
              S1 Thermal Printer
```

Unter Windows erfolgt die Druckausgabe über einen lokalen PowerShell-Dienst und den installierten Systemdrucker.

Unter iPadOS wird die Weboberfläche innerhalb einer nativen Swift-Anwendung mittels WKWebView ausgeführt. Die Kommunikation zwischen JavaScript und Swift erfolgt über einen Script Message Handler. Die Druckdaten werden anschließend über Bluetooth Low Energy (BLE) an den Thermodrucker übertragen.

## Product Catalog

| Product | Portion | Price |
|---|---|---:|
| Hamsi | 1 Portion | 8,00 EUR |
| Ekmek Arası Uskumru | 1 Portion | 6,00 EUR |
| Patates Kızartması | 1 Portion | 2,00 EUR |
| Baklava | 2 adet | 1,00 EUR |
| Şekerpare | 2 adet | 1,00 EUR |
| Revani | 1 adet | 1,00 EUR |

## Hardware

| Specification | Value |
|---|---|
| Printer | Mini Pocket Printer S1 |
| Manufacturer | Xiamen Lujiang Technology |
| FCC ID | 2A74AS1PRO |
| Communication | Bluetooth Low Energy |
| Printing technology | Thermal printing |
| Target platforms | Windows, iPadOS |

## Installation

### Windows

Requirements:

- Windows
- PowerShell
- S1Print
- Configured S1 system printer
- Bluetooth-enabled computer

Start the application:

```powershell
.\Start-Kasse.bat
```

Select the S1 printer from the available system printers.

The application starts a local HTTP service at:

```text
http://127.0.0.1:18765/
```

The service must remain active while the application is in use.

### iPadOS

Requirements:

- iPad with Bluetooth support
- iPadOS 16 or later as the configured deployment target
- Swift Playgrounds
- S1 Bluetooth printer

Installation:

1. Extract the iPad application archive.
2. Open `HamsiKasse-XL.swiftpm` in Swift Playgrounds.
3. Build and run the application.
4. Grant Bluetooth permissions.
5. Start printer discovery.
6. Select the S1 printer.

The HTML resource is loaded from the application bundle using:

```swift
Bundle.main.url(
    forResource: "Kasse",
    withExtension: "html"
)
```

The application does not require a running Windows computer or an external server during operation.

## Bluetooth Communication

The iPadOS implementation uses CoreBluetooth to discover and communicate with nearby Bluetooth Low Energy devices.

The application establishes its own connection to the printer. Manual pairing through the iPadOS Bluetooth settings is not required for the intended implementation.

The receipt is rendered into a raster image and converted into the printer-specific data format before transmission.

## Receipt Format

Receipts use a compact, centered layout optimized for thermal printing.

```text
         Ditib Wörth
        Hamsi Festivali
----------------------------
          2 x Hamsi
    1 x Patates Kızartması
     1 x Baklava (2 adet)
----------------------------
       Toplam: 19,00 EUR

       Bahnhofstraße 40
     76744 Wörth am Rhein
```

The receipt is generated dynamically based on the selected products and quantities.

Internal sales statistics are excluded from printed receipts.

## Sales Statistics

The application maintains internal sales statistics containing:

- Number of completed orders
- Total revenue
- Sequential order numbers

Statistics are stored locally on the respective device and are accessible through the internal statistics menu.

Reprinting an existing receipt does not create an additional sale.

## Data Storage

All application data is processed locally.

The application does not require:

- Cloud infrastructure
- External databases
- User accounts
- Remote APIs
- Internet connectivity during normal operation

Sales statistics are stored separately on each device. Cross-device synchronization is not implemented.

## Troubleshooting

### Port already in use

If the Windows application reports a conflict on port `18765`, terminate any previously running instances of the local print service before restarting the application.

### Bundle.module build error

If Swift Playgrounds reports:

```text
Type 'Bundle' has no member 'module'
```

Replace `Bundle.module` with `Bundle.main` when loading the HTML resource.

### Printer not detected

Verify that Bluetooth is enabled, the printer is powered on and no other application or device is maintaining an active connection to the printer.

### Incomplete receipts

Verify the receipt dimensions, available print area and Bluetooth transmission. The compact receipt layout reduces paper consumption and the amount of transmitted print data.

## Known Limitations

- Sales statistics are stored separately on each device.
- The internal statistics menu is not password-protected.
- No centralized database or inventory management.
- No integrated electronic payment processing.
- No fiscal cash register certification.
- Printer compatibility is limited to the implemented S1 printing interfaces.
- Full hardware and platform compatibility requires practical testing.

## Project Status

The project is developed for event-based food sales.

The Windows printing workflow and the iPadOS user interface have been tested in the target environment. Reliable Bluetooth printing under iPadOS should be verified before production use.

## Credits

The printer communication implementation is based on the S1Print project by Marvin Quevedo.

Upstream repository:

```text
https://github.com/MarvinQuevedo/s1print
```

## License

Third-party source code remains subject to its respective upstream license.

A separate license for the Kassentool application has not yet been specified.

## Organization

DITIB Wörth  
Türkisch Islamische Gemeinde zu Wörth e.V.  
Bahnhofstraße 40  
76744 Wörth am Rhein  
Germany
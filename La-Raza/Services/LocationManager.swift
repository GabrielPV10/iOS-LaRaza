import CoreLocation
import SwiftUI

@MainActor
class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    @Published var latitud: Double? = nil
    @Published var longitud: Double? = nil
    @Published var cargando = false

    override init() {
        super.init()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
    }

    func solicitarUbicacion() {
        cargando = true
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let loc = locations.first else { return }
        Task { @MainActor in
            self.latitud  = loc.coordinate.latitude
            self.longitud = loc.coordinate.longitude
            self.cargando = false
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        Task { @MainActor in
            self.cargando = false
        }
    }
}

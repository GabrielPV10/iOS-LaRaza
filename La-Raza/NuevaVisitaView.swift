//
//  NuevaVisitaView.swift
//  La-Raza
//
//  Created by Alumno on 22/04/26.
//

import SwiftUI
import CoreLocation

// MARK: - Modelo de Visita
struct Visita: Identifiable {
    let id = UUID()
    var nombreProductor: String
    var ranchoEjido: String
    var cultivo: String
    var latitud: Double?
    var longitud: Double?
    var productosRecomendados: [String]
    var notas: String
    var fecha: Date = Date()
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var latitud: Double? = nil
    @Published var longitud: Double? = nil
    @Published var estado: String = "Sin ubicación"
    @Published var cargando: Bool = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func solicitarUbicacion() {
        cargando = true
        estado = "Obteniendo ubicación..."
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.first {
            latitud  = loc.coordinate.latitude
            longitud = loc.coordinate.longitude
            estado   = String(format: "%.5f, %.5f", loc.coordinate.latitude, loc.coordinate.longitude)
            cargando = false
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        estado   = "Error al obtener ubicación"
        cargando = false
    }
}

// MARK: - NuevaVisitaView
struct NuevaVisitaView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var locationManager = LocationManager()

    // Campos del formulario
    @State private var nombreProductor: String = ""
    @State private var ranchoEjido: String = ""
    @State private var cultivoSeleccionado: String = ""
    @State private var notas: String = ""
    @State private var productosSeleccionados: Set<String> = []
    @State private var mostrarAlertaGuardado: Bool = false

    let cultivos = [
        "Maíz", "Sorgo", "Soya", "Frijol", "Caña de azúcar",
        "Chile", "Tomate", "Papaya", "Mango", "Plátano"
    ]

    let productosDisponibles = [
        "Urea 46%", "Glifosato 480 SL", "Maíz Híbrido H-438",
        "Clorpirifos 480 EC", "DAP 18-46-0", "Soya Cristalina",
        "Mancozeb 80 WP", "Sulfato de Potasio"
    ]

    var formularioValido: Bool {
        !nombreProductor.isEmpty && !ranchoEjido.isEmpty && !cultivoSeleccionado.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {

            // ── HEADER ───────────────────────────────────────────
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "3CB504"), Color(hex: "1E7A00")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea(edges: .top)

                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .semibold))
                    }
                    Spacer()
                    Text("Nueva Visita")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.left").opacity(0)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .padding(.top, 8)
            }
            .fixedSize(horizontal: false, vertical: true)

            // ── FORMULARIO ───────────────────────────────────────
            ScrollView {
                VStack(spacing: 16) {

                    // SECCIÓN 1 — Datos del Productor
                    SeccionCard(icono: "person.2", titulo: "Datos del Productor") {
                        CampoTexto(
                            icono: "person",
                            placeholder: "Nombre del productor",
                            texto: $nombreProductor
                        )

                        CampoTexto(
                            icono: "mappin",
                            placeholder: "Rancho / Ejido",
                            texto: $ranchoEjido
                        )
                    }

                    // SECCIÓN 2 — Cultivo
                    SeccionCard(icono: "leaf", titulo: "Cultivo") {
                        Menu {
                            ForEach(cultivos, id: \.self) { cultivo in
                                Button(cultivo) {
                                    cultivoSeleccionado = cultivo
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "leaf")
                                    .foregroundColor(Color(hex: "3CB504"))
                                    .frame(width: 20)
                                Text(cultivoSeleccionado.isEmpty ? "Selecciona el cultivo" : cultivoSeleccionado)
                                    .foregroundColor(
                                        cultivoSeleccionado.isEmpty
                                        ? Color(hex: "AAAAAA")
                                        : Color(hex: "1A1A1A")
                                    )
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(Color(hex: "3CB504"))
                                    .font(.system(size: 13))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 14)
                            .background(Color(hex: "F0FAF0"))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(hex: "3CB504").opacity(0.4), lineWidth: 1)
                            )
                        }
                    }

                    // SECCIÓN 3 — Ubicación GPS
                    SeccionCard(icono: "location.circle", titulo: "Ubicación GPS") {
                        // Botón obtener ubicación
                        Button(action: {
                            locationManager.solicitarUbicacion()
                        }) {
                            HStack(spacing: 8) {
                                if locationManager.cargando {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "3CB504")))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "location.circle")
                                        .foregroundColor(Color(hex: "3CB504"))
                                }
                                Text(locationManager.cargando ? "Obteniendo..." : "Obtener ubicación actual")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "3CB504"))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(hex: "3CB504"), lineWidth: 1.5)
                            )
                        }

                        // Resultado GPS
                        if locationManager.latitud != nil {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(hex: "3CB504"))
                                Text(locationManager.estado)
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "555555"))
                            }
                            .padding(10)
                            .background(Color(hex: "D6F5D6"))
                            .cornerRadius(8)
                        }
                    }

                    // SECCIÓN 4 — Productos Recomendados
                    SeccionCard(icono: "shippingbox", titulo: "Productos Recomendados") {
                        // Chips seleccionables
                        FlowLayout(spacing: 8) {
                            ForEach(productosDisponibles, id: \.self) { producto in
                                let seleccionado = productosSeleccionados.contains(producto)
                                Button(action: {
                                    if seleccionado {
                                        productosSeleccionados.remove(producto)
                                    } else {
                                        productosSeleccionados.insert(producto)
                                    }
                                }) {
                                    Text(producto)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(seleccionado ? .white : Color(hex: "555555"))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 7)
                                        .background(
                                            seleccionado
                                            ? Color(hex: "3CB504")
                                            : Color.white
                                        )
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(
                                                    seleccionado ? Color.clear : Color(hex: "CCCCCC"),
                                                    lineWidth: 1
                                                )
                                        )
                                }
                            }
                        }
                    }

                    // SECCIÓN 5 — Notas y Observaciones
                    SeccionCard(icono: "text.alignleft", titulo: "Notas y Observaciones") {
                        ZStack(alignment: .topLeading) {
                            if notas.isEmpty {
                                Text("Escribe observaciones del campo, recomendaciones, problemas detectados...")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "AAAAAA"))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 14)
                            }
                            TextEditor(text: $notas)
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "1A1A1A"))
                                .frame(minHeight: 100)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .opacity(notas.isEmpty ? 0.25 : 1)
                        }
                        .background(Color(hex: "F0FAF0"))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(hex: "3CB504").opacity(0.4), lineWidth: 1)
                        )
                    }

                    // Espaciado para el botón flotante
                    Color.clear.frame(height: 80)
                }
                .padding(16)
            }
            .background(Color(hex: "F5F5F5"))
            .overlay(alignment: .bottom) {

                // ── BOTÓN GUARDAR FLOTANTE ────────────────────────
                Button(action: {
                    if formularioValido {
                        mostrarAlertaGuardado = true
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.down")
                        Text("Guardar Visita")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        formularioValido
                        ? LinearGradient(
                            colors: [Color(hex: "3CB504"), Color(hex: "1E7A00")],
                            startPoint: .leading,
                            endPoint: .trailing
                          )
                        : LinearGradient(
                            colors: [Color(hex: "AAAAAA"), Color(hex: "888888")],
                            startPoint: .leading,
                            endPoint: .trailing
                          )
                    )
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Visita guardada", isPresented: $mostrarAlertaGuardado) {
            Button("OK") { dismiss() }
        } message: {
            Text("La visita de \(nombreProductor) en \(ranchoEjido) fue registrada correctamente.")
        }
    }
}

// MARK: - Componentes reutilizables

struct SeccionCard<Contenido: View>: View {
    let icono: String
    let titulo: String
    let contenido: () -> Contenido

    init(icono: String, titulo: String, @ViewBuilder contenido: @escaping () -> Contenido) {
        self.icono = icono
        self.titulo = titulo
        self.contenido = contenido
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icono)
                    .foregroundColor(Color(hex: "3CB504"))
                    .font(.system(size: 15))
                Text(titulo)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(hex: "1A1A1A"))
            }
            contenido()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

struct CampoTexto: View {
    let icono: String
    let placeholder: String
    @Binding var texto: String

    var body: some View {
        HStack {
            Image(systemName: icono)
                .foregroundColor(Color(hex: "3CB504"))
                .frame(width: 20)
            TextField(placeholder, text: $texto)
                .foregroundColor(Color(hex: "1A1A1A"))
                .autocapitalization(.words)
                .disableAutocorrection(true)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(Color(hex: "F0FAF0"))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: "3CB504").opacity(0.4), lineWidth: 1)
        )
    }
}

// Layout de chips que hace wrap automático
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width {
                y += maxHeight + spacing
                x = 0
                maxHeight = 0
            }
            maxHeight = max(maxHeight, size.height)
            x += size.width + spacing
            height = y + maxHeight
        }
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var maxHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                y += maxHeight + spacing
                x = bounds.minX
                maxHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            maxHeight = max(maxHeight, size.height)
            x += size.width + spacing
        }
    }
}

#Preview {
    NavigationStack {
        NuevaVisitaView()
    }
}

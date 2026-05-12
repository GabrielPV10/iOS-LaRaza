//
//  NuevaVisitaView.swift
//  La-Raza
//
//  Created by Alumno on 22/04/26.
//

import SwiftUI
import SwiftData
import CoreLocation

// MARK: - LocationManager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var latitud:  Double? = nil
    @Published var longitud: Double? = nil
    @Published var estado:   String  = "Sin ubicación"
    @Published var cargando: Bool    = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func solicitarUbicacion() {
        cargando = true
        estado   = "Obteniendo ubicación..."
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }

    func limpiar() {
        latitud  = nil
        longitud = nil
        estado   = "Sin ubicación"
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else { return }
        latitud  = loc.coordinate.latitude
        longitud = loc.coordinate.longitude
        estado   = String(format: "%.5f, %.5f", loc.coordinate.latitude, loc.coordinate.longitude)
        cargando = false
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        estado   = "Error al obtener ubicación"
        cargando = false
    }
}

// MARK: - NuevaVisitaView
struct NuevaVisitaView: View {
    // ── Modo edición (opcional) — igual que visitaEditar en Flutter
    var visitaEditar: VisitaLocal? = nil
    var esEdicion: Bool { visitaEditar != nil }

    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext

    @StateObject private var locationManager = LocationManager()
    @StateObject private var cultivosVM      = CultivosViewModel()
    @StateObject private var visitasVM       = VisitasViewModel()

    // Campos
    @State private var nombreProductor: String = ""
    @State private var ranchoEjido:     String = ""
    @State private var notas:           String = ""
    @State private var cultivoSeleccionado: CultivoDTO? = nil

    // Productos con búsqueda debounced
    @State private var productosSeleccionados: [String]     = []
    @State private var busquedaProducto:        String       = ""
    @State private var resultadosBusqueda:      [ArticuloDTO] = []
    @State private var buscandoProducto:        Bool         = false
    @State private var searchTask: Task<Void, Never>?        = nil

    var formularioValido: Bool {
        !nombreProductor.isEmpty && !ranchoEjido.isEmpty && cultivoSeleccionado != nil
    }

    var body: some View {
        VStack(spacing: 0) {

            // ── HEADER ───────────────────────────────────────────
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "3CB504"), Color(hex: "1E7A00")],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .ignoresSafeArea(edges: .top)

                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .semibold))
                    }
                    Spacer()
                    Text(esEdicion ? "Editar Visita" : "Nueva Visita")
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

            // Banner de estado
            if !visitasVM.mensajeEstado.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: visitasVM.guardadoExitoso
                          ? "checkmark.circle.fill" : "clock.fill")
                    Text(visitasVM.mensajeEstado)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(visitasVM.guardadoExitoso
                                 ? Color(hex: "3CB504") : Color(hex: "E6A817"))
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(visitasVM.guardadoExitoso
                            ? Color(hex: "D6F5D6") : Color(hex: "FFF3D6"))
                .transition(.opacity)
            }

            ScrollView {
                VStack(spacing: 16) {

                    // SECCIÓN 1 — Datos del Productor
                    SeccionCard(icono: "person.2", titulo: "Datos del Productor") {
                        CampoTexto(icono: "person",  placeholder: "Nombre del productor", texto: $nombreProductor)
                        CampoTexto(icono: "mappin",  placeholder: "Rancho / Ejido",       texto: $ranchoEjido)
                    }

                    // SECCIÓN 2 — Cultivo (API con fallback)
                    SeccionCard(icono: "leaf", titulo: "Cultivo") {
                        if cultivosVM.cargando {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "3CB504")))
                                    .scaleEffect(0.8)
                                Text("Cargando cultivos...")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "888888"))
                            }
                            .padding(.vertical, 8)
                        } else {
                            Menu {
                                ForEach(cultivosVM.cultivos, id: \.id) { c in
                                    Button(c.nombre) { cultivoSeleccionado = c }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "leaf")
                                        .foregroundColor(Color(hex: "3CB504"))
                                        .frame(width: 20)
                                    Text(cultivoSeleccionado?.nombre ?? "Selecciona el cultivo")
                                        .foregroundColor(cultivoSeleccionado == nil
                                                         ? Color(hex: "AAAAAA") : Color(hex: "1A1A1A"))
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
                    }

                    // SECCIÓN 3 — Ubicación GPS
                    SeccionCard(icono: "location.circle", titulo: "Ubicación GPS") {
                        if locationManager.latitud == nil {
                            Button(action: { locationManager.solicitarUbicacion() }) {
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
                            .disabled(locationManager.cargando)
                        } else {
                            // Ubicación obtenida — botones Actualizar / Quitar
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(hex: "3CB504"))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Ubicación obtenida ✅")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(Color(hex: "1E7A00"))
                                    Text(locationManager.estado)
                                        .font(.system(size: 11))
                                        .foregroundColor(Color(hex: "555555"))
                                }
                                Spacer()
                                Button("Actualizar") { locationManager.solicitarUbicacion() }
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color(hex: "3CB504"))
                                Button("Quitar") { locationManager.limpiar() }
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color(hex: "E53935"))
                            }
                            .padding(12)
                            .background(Color(hex: "D6F5D6"))
                            .cornerRadius(10)
                        }
                    }

                    // SECCIÓN 4 — Productos Recomendados (búsqueda debounced = API)
                    SeccionCard(icono: "shippingbox", titulo: "Productos Recomendados") {

                        // Buscador
                        HStack(spacing: 8) {
                            if buscandoProducto {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "3CB504")))
                                    .scaleEffect(0.7)
                                    .frame(width: 20)
                            } else {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(Color(hex: "888888"))
                                    .frame(width: 20)
                            }
                            TextField("Buscar en inventario...", text: $busquedaProducto)
                                .font(.system(size: 13))
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .onChange(of: busquedaProducto) { _, query in
                                    buscarProductos(query)
                                }
                            if !busquedaProducto.isEmpty {
                                Button(action: {
                                    busquedaProducto   = ""
                                    resultadosBusqueda = []
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Color(hex: "AAAAAA"))
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .background(Color(hex: "F0FAF0"))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(hex: "3CB504").opacity(0.35), lineWidth: 1)
                        )

                        // Dropdown de resultados — igual que Flutter ListView.builder de 8 items
                        if !resultadosBusqueda.isEmpty {
                            VStack(spacing: 0) {
                                ForEach(Array(resultadosBusqueda.prefix(8).enumerated()), id: \.offset) { idx, art in
                                    Button(action: { agregarProducto(art.nombre) }) {
                                        HStack(spacing: 10) {
                                            Image(systemName: "plus.circle")
                                                .foregroundColor(Color(hex: "3CB504"))
                                                .font(.system(size: 15))
                                            Text(art.nombre)
                                                .font(.system(size: 13))
                                                .foregroundColor(Color(hex: "1A1A1A"))
                                                .lineLimit(1)
                                            Spacer()
                                            if art.stockTotal > 0 {
                                                Text("\(art.stockTotal) en stock")
                                                    .font(.system(size: 11))
                                                    .foregroundColor(Color(hex: "888888"))
                                            }
                                        }
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                    }
                                    .buttonStyle(.plain)
                                    if idx < min(resultadosBusqueda.count, 8) - 1 {
                                        Divider().padding(.horizontal, 14)
                                    }
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(hex: "3CB504").opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                        }

                        // Chips con botón eliminar — igual que Chip onDeleted de Flutter
                        if !productosSeleccionados.isEmpty {
                            FlowLayout(spacing: 8) {
                                ForEach(productosSeleccionados, id: \.self) { producto in
                                    HStack(spacing: 4) {
                                        Text(producto)
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(Color(hex: "1E7A00"))
                                        Button(action: {
                                            productosSeleccionados.removeAll { $0 == producto }
                                        }) {
                                            Image(systemName: "xmark")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(Color(hex: "1E7A00"))
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color(hex: "D6F5D6"))
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color(hex: "3CB504"), lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }

                    // SECCIÓN 5 — Notas
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

                    Color.clear.frame(height: 80)
                }
                .padding(16)
            }
            .background(Color(hex: "F5F5F5"))
            .overlay(alignment: .bottom) {
                Button(action: guardar) {
                    ZStack {
                        LinearGradient(
                            colors: formularioValido
                                ? [Color(hex: "3CB504"), Color(hex: "1E7A00")]
                                : [Color(hex: "AAAAAA"), Color(hex: "888888")],
                            startPoint: .leading, endPoint: .trailing
                        )
                        .cornerRadius(14)

                        if visitasVM.guardando {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: esEdicion ? "pencil.circle" : "square.and.arrow.down")
                                Text(esEdicion ? "Actualizar Visita" : "Guardar Visita")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundColor(.white)
                        }
                    }
                    .frame(height: 52)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .disabled(!formularioValido || visitasVM.guardando)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            cultivosVM.cargarCultivos()
            poblarSiEdicion()
        }
        .onChange(of: cultivosVM.cultivos) { _, cultivos in
            if let v = visitaEditar, cultivoSeleccionado == nil {
                cultivoSeleccionado = cultivos.first { $0.id == (v.cultivoId ?? 0) }
            }
        }
        .onChange(of: visitasVM.guardadoExitoso) { _, exitoso in
            if exitoso {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { dismiss() }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: visitasVM.mensajeEstado)
    }

    // MARK: - Helpers

    private func poblarSiEdicion() {
        guard let v = visitaEditar else { return }
        nombreProductor        = v.nombreProductor
        ranchoEjido            = v.ranchoEjido
        notas                  = v.notas
        productosSeleccionados = v.productosRecomendados
        if let lat = v.latitud, let lon = v.longitud {
            locationManager.latitud  = lat
            locationManager.longitud = lon
            locationManager.estado   = String(format: "%.5f, %.5f", lat, lon)
        }
    }

    private func guardar() {
        guard let cultivo = cultivoSeleccionado else { return }
        if esEdicion, let v = visitaEditar {
            visitasVM.actualizarVisita(
                visita:          v,
                nombreProductor: nombreProductor,
                ranchoEjido:     ranchoEjido,
                cultivoId:       cultivo.id,
                cultivoNombre:   cultivo.nombre,
                latitud:         locationManager.latitud,
                longitud:        locationManager.longitud,
                notas:           notas,
                productos:       productosSeleccionados,
                modelContext:    modelContext
            )
        } else {
            visitasVM.guardarVisita(
                nombreProductor: nombreProductor,
                ranchoEjido:     ranchoEjido,
                cultivoId:       cultivo.id,
                cultivoNombre:   cultivo.nombre,
                latitud:         locationManager.latitud,
                longitud:        locationManager.longitud,
                notas:           notas,
                productos:       productosSeleccionados,
                modelContext:    modelContext
            )
        }
    }

    // Debounce 400 ms — igual que Timer(400ms) de Flutter
    private func buscarProductos(_ query: String) {
        searchTask?.cancel()
        guard !query.isEmpty else { resultadosBusqueda = []; return }
        buscandoProducto = true
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !Task.isCancelled else { return }
            do {
                let dtos = try await APIService.shared.getArticulos(limit: 8, search: query)
                await MainActor.run {
                    resultadosBusqueda = dtos
                    buscandoProducto   = false
                }
            } catch {
                await MainActor.run { buscandoProducto = false }
            }
        }
    }

    private func agregarProducto(_ nombre: String) {
        guard !productosSeleccionados.contains(nombre) else { return }
        productosSeleccionados.append(nombre)
        busquedaProducto   = ""
        resultadosBusqueda = []
    }
}

#Preview { NavigationStack { NuevaVisitaView() } }

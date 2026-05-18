//
//  NuevaVisitaView.swift
//  La-Raza
//
//  Created by Alumno on 15/04/26.
//

import SwiftUI
import SwiftData
import CoreLocation

struct NuevaVisitaView: View {
    // ── Parámetro opcional para edición ──────────────────────────
    var visitaEditar: VisitaLocal? = nil
    var esEdicion: Bool { visitaEditar != nil }

    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var vm = VisitasViewModel()
    @StateObject private var cultivosVM = CultivosViewModel()
    @StateObject private var locationManager = LocationManager()

    // Campos del formulario
    @State private var nombreProductor = ""
    @State private var ranchoEjido = ""
    @State private var notas = ""
    @State private var modo = "cultivo"

    // Cultivo
    @State private var cultivoIdSeleccionado: Int? = nil
    @State private var cultivoNombreSeleccionado = ""

    // Veterinario
    @State private var especieSeleccionada: String? = nil
    let especies = ["Bovino", "Porcino", "Ovino", "Caprino",
                    "Equino", "Aviar", "Canino", "Felino", "Otro"]

    // Productos con búsqueda real + debounce
    @State private var busquedaProducto = ""
    @State private var resultadosBusqueda: [ArticuloDTO] = []
    @State private var buscandoProducto = false
    @State private var productosSeleccionados: [String] = []
    @State private var debounceTask: Task<Void, Never>? = nil

    var formularioValido: Bool {
        let baseOk = !nombreProductor.isEmpty && !ranchoEjido.isEmpty
        return modo == "cultivo"
            ? baseOk && cultivoIdSeleccionado != nil
            : baseOk && especieSeleccionada != nil
    }

    var body: some View {
        VStack(spacing: 0) {

            // ── HEADER ───────────────────────────────────────────
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "52E808"), Color(hex: "3CB504"),
                             Color(hex: "1E7A00")],
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

                    // ← AQUÍ va el Text que preguntabas
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

            // ── FORMULARIO ───────────────────────────────────────
            ScrollView {
                VStack(spacing: 16) {

                    // SECCIÓN 1 — Datos del Productor
                    SeccionCard(icono: "person.2",
                                titulo: "Datos del Productor") {
                        CampoTexto(icono: "person",
                                   placeholder: "Nombre del productor",
                                   texto: $nombreProductor)
                        CampoTexto(icono: "mappin",
                                   placeholder: "Rancho / Ejido",
                                   texto: $ranchoEjido)
                    }

                    // SECCIÓN 2 — Tipo de Visita
                    SeccionCard(icono: "slider.horizontal.3",
                                titulo: "Tipo de Visita") {
                        HStack(spacing: 10) {
                            ModoButton(
                                modo: "cultivo",
                                label: "Cultivo",
                                icono: "leaf.fill",
                                colorHex: "3CB504",
                                seleccionado: modo
                            ) { modo = "cultivo" }

                            ModoButton(
                                modo: "veterinario",
                                label: "Veterinario",
                                icono: "pawprint.fill",
                                colorHex: "0891b2",
                                seleccionado: modo
                            ) { modo = "veterinario" }
                        }
                    }

                    // SECCIÓN 3 — Cultivo o Especie
                    if modo == "cultivo" {
                        SeccionCard(icono: "leaf", titulo: "Cultivo") {
                            if cultivosVM.cargando {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .progressViewStyle(
                                            CircularProgressViewStyle(
                                                tint: Color(hex: "3CB504"))
                                        )
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                            } else {
                                Menu {
                                    ForEach(cultivosVM.cultivos,
                                            id: \.id) { cultivo in
                                        Button(cultivo.nombre) {
                                            cultivoIdSeleccionado =
                                                cultivo.id
                                            cultivoNombreSeleccionado =
                                                cultivo.nombre
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "leaf")
                                            .foregroundColor(
                                                Color(hex: "3CB504"))
                                            .frame(width: 20)
                                        Text(cultivoNombreSeleccionado.isEmpty
                                             ? "Selecciona el cultivo"
                                             : cultivoNombreSeleccionado)
                                            .foregroundColor(
                                                cultivoNombreSeleccionado.isEmpty
                                                ? Color(hex: "AAAAAA")
                                                : Color(hex: "1A1A1A")
                                            )
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(
                                                Color(hex: "3CB504"))
                                            .font(.system(size: 13))
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 14)
                                    .background(Color(hex: "F0FAF0"))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(
                                                Color(hex: "3CB504")
                                                    .opacity(0.4),
                                                lineWidth: 1)
                                    )
                                }
                            }
                        }
                    } else {
                        SeccionCard(icono: "pawprint",
                                    titulo: "Especie Animal") {
                            Menu {
                                ForEach(especies, id: \.self) { e in
                                    Button(e) {
                                        especieSeleccionada = e
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "pawprint")
                                        .foregroundColor(
                                            Color(hex: "0891b2"))
                                        .frame(width: 20)
                                    Text(especieSeleccionada
                                         ?? "Selecciona la especie")
                                        .foregroundColor(
                                            especieSeleccionada == nil
                                            ? Color(hex: "AAAAAA")
                                            : Color(hex: "1A1A1A")
                                        )
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(
                                            Color(hex: "0891b2"))
                                        .font(.system(size: 13))
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 14)
                                .background(Color(hex: "e0f2fe"))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(
                                            Color(hex: "0891b2")
                                                .opacity(0.4),
                                            lineWidth: 1)
                                )
                            }
                        }
                    }

                    // SECCIÓN 4 — GPS
                    SeccionCard(icono: "location.circle",
                                titulo: "Ubicación GPS") {
                        if locationManager.latitud == nil {
                            Button(action: {
                                locationManager.solicitarUbicacion()
                            }) {
                                HStack(spacing: 8) {
                                    if locationManager.cargando {
                                        ProgressView()
                                            .progressViewStyle(
                                                CircularProgressViewStyle(
                                                    tint: Color(
                                                        hex: "3CB504"))
                                            )
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName:
                                            "location.circle")
                                            .foregroundColor(
                                                Color(hex: "3CB504"))
                                    }
                                    Text(locationManager.cargando
                                         ? "Obteniendo ubicación..."
                                         : "Obtener ubicación actual")
                                        .font(.system(size: 14,
                                                      weight: .medium))
                                        .foregroundColor(
                                            Color(hex: "3CB504"))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(hex: "3CB504"),
                                                lineWidth: 1.5)
                                )
                            }
                        } else {
                            HStack(spacing: 10) {
                                Image(systemName:
                                    "checkmark.circle.fill")
                                    .foregroundColor(
                                        Color(hex: "3CB504"))
                                    .font(.system(size: 20))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Ubicación obtenida ✅")
                                        .font(.system(size: 13,
                                                      weight: .bold))
                                        .foregroundColor(
                                            Color(hex: "1E7A00"))
                                    Text(String(
                                        format: "Lat: %.5f  Lon: %.5f",
                                        locationManager.latitud!,
                                        locationManager.longitud!))
                                        .font(.system(size: 11))
                                        .foregroundColor(
                                            Color(hex: "888888"))
                                }

                                Spacer()

                                Button("Actualizar") {
                                    locationManager.solicitarUbicacion()
                                }
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "3CB504"))

                                Button("Quitar") {
                                    locationManager.latitud = nil
                                    locationManager.longitud = nil
                                }
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "E53935"))
                            }
                            .padding(14)
                            .background(Color(hex: "F0FAF0"))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        Color(hex: "3CB504").opacity(0.3),
                                        lineWidth: 1)
                            )
                        }
                    }

                    // SECCIÓN 5 — Productos con búsqueda real
                    SeccionCard(
                        icono: "shippingbox",
                        titulo: modo == "veterinario"
                            ? "Medicamentos / Productos"
                            : "Productos Recomendados"
                    ) {
                        HStack {
                            if buscandoProducto {
                                ProgressView()
                                    .scaleEffect(0.7)
                                    .frame(width: 20)
                            } else {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(Color(hex: "888888"))
                                    .frame(width: 20)
                            }
                            TextField("Buscar en inventario...",
                                      text: $busquedaProducto)
                                .foregroundColor(Color(hex: "1A1A1A"))
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .onChange(of: busquedaProducto) {
                                    _, query in
                                    debounceTask?.cancel()
                                    if query.isEmpty {
                                        resultadosBusqueda = []
                                        return
                                    }
                                    debounceTask = Task {
                                        try? await Task.sleep(
                                            nanoseconds: 400_000_000)
                                        guard !Task.isCancelled else {
                                            return
                                        }
                                        await buscarProductos(query)
                                    }
                                }
                            if !busquedaProducto.isEmpty {
                                Button(action: {
                                    busquedaProducto = ""
                                    resultadosBusqueda = []
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(
                                            Color(hex: "AAAAAA"))
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color(hex: "F0FAF0"))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    Color(hex: "3CB504").opacity(0.4),
                                    lineWidth: 1)
                        )

                        // Resultados dropdown
                        if !resultadosBusqueda.isEmpty {
                            VStack(spacing: 0) {
                                ForEach(
                                    resultadosBusqueda.prefix(8),
                                    id: \.id
                                ) { articulo in
                                    Button(action: {
                                        agregarProducto(articulo.nombre)
                                    }) {
                                        HStack(spacing: 10) {
                                            Image(systemName:
                                                "plus.circle")
                                                .foregroundColor(
                                                    Color(hex: "3CB504"))
                                                .font(.system(size: 15))
                                            Text(articulo.nombre)
                                                .font(.system(size: 13))
                                                .foregroundColor(
                                                    Color(hex: "1A1A1A"))
                                                .lineLimit(1)
                                            Spacer()
                                            Text("\(articulo.stockTotal) en stock")
                                                .font(.system(size: 11))
                                                .foregroundColor(
                                                    Color(hex: "888888"))
                                        }
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                    }
                                    .buttonStyle(.plain)

                                    if articulo.id !=
                                        resultadosBusqueda
                                            .prefix(8).last?.id {
                                        Divider()
                                            .padding(.leading, 14)
                                    }
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        Color(hex: "3CB504").opacity(0.3),
                                        lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.05),
                                    radius: 4, x: 0, y: 2)
                        }

                        // Chips seleccionados
                        if !productosSeleccionados.isEmpty {
                            FlowLayout(spacing: 8) {
                                ForEach(productosSeleccionados,
                                        id: \.self) { p in
                                    HStack(spacing: 6) {
                                        Text(p)
                                            .font(.system(
                                                size: 12,
                                                weight: .semibold))
                                            .foregroundColor(
                                                Color(hex: "1E7A00"))
                                        Button(action: {
                                            productosSeleccionados
                                                .removeAll { $0 == p }
                                        }) {
                                            Image(systemName: "xmark")
                                                .font(.system(
                                                    size: 10,
                                                    weight: .bold))
                                                .foregroundColor(
                                                    Color(hex: "1E7A00"))
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .background(Color(hex: "F0FAF0"))
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color(hex: "3CB504"),
                                                    lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }

                    // SECCIÓN 6 — Notas
                    SeccionCard(icono: "text.alignleft",
                                titulo: "Notas y Observaciones") {
                        ZStack(alignment: .topLeading) {
                            if notas.isEmpty {
                                Text("Escribe observaciones del campo, recomendaciones, problemas detectados...")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "AAAAAA"))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 14)
                                    .allowsHitTesting(false)
                            }
                            TextEditor(text: $notas)
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "1A1A1A"))
                                .frame(minHeight: 100)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .opacity(notas.isEmpty ? 0.01 : 1)
                        }
                        .background(Color(hex: "F0FAF0"))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    Color(hex: "3CB504").opacity(0.4),
                                    lineWidth: 1)
                        )
                    }

                    Color.clear.frame(height: 80)
                }
                .padding(16)
            }
            .background(Color(hex: "F5F5F5"))
            .overlay(alignment: .bottom) {

                // ── BOTÓN GUARDAR ─────────────────────────────────
                Button(action: {
                    guard formularioValido else { return }

                    let cultivoFinal: Int
                    let cultivoNombreFinal: String

                    if modo == "veterinario" {
                        cultivoFinal = 0
                        cultivoNombreFinal = especieSeleccionada ?? ""
                    } else {
                        cultivoFinal = cultivoIdSeleccionado ?? 0
                        cultivoNombreFinal = cultivoNombreSeleccionado
                    }

                    vm.guardarVisita(
                        nombreProductor: nombreProductor,
                        ranchoEjido: ranchoEjido,
                        cultivoId: cultivoFinal,
                        cultivoNombre: cultivoNombreFinal,
                        modo: modo,
                        especie: modo == "veterinario"
                            ? especieSeleccionada : nil,
                        latitud: locationManager.latitud,
                        longitud: locationManager.longitud,
                        notas: notas,
                        productos: productosSeleccionados,
                        modelContext: modelContext
                    )
                }) {
                    HStack(spacing: 8) {
                        if vm.guardando {
                            ProgressView()
                                .progressViewStyle(
                                    CircularProgressViewStyle(
                                        tint: .white))
                        } else {
                            Image(systemName: esEdicion
                                  ? "pencil" : "square.and.arrow.down")

                            // ← AQUÍ también cambia el texto
                            Text(esEdicion
                                 ? "Actualizar Visita"
                                 : "Guardar Visita")
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        formularioValido
                        ? LinearGradient(
                            colors: [Color(hex: "3CB504"),
                                     Color(hex: "1E7A00")],
                            startPoint: .leading,
                            endPoint: .trailing)
                        : LinearGradient(
                            colors: [Color(hex: "AAAAAA"),
                                     Color(hex: "888888")],
                            startPoint: .leading,
                            endPoint: .trailing)
                    )
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.15),
                            radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .alert(esEdicion
                       ? "Visita actualizada"
                       : "Visita registrada",
                       isPresented: $vm.guardadoExitoso) {
                    Button("OK") { dismiss() }
                } message: {
                    Text(vm.mensajeEstado)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            cultivosVM.cargarCultivos()

            // ← CARGA DE DATOS PARA EDICIÓN
            guard let v = visitaEditar else { return }
            nombreProductor = v.nombreProductor
            ranchoEjido = v.ranchoEjido
            notas = v.notas
            modo = v.modo
            productosSeleccionados = v.productosRecomendados

            if v.modo == "veterinario" {
                especieSeleccionada = v.especie
            } else {
                cultivoIdSeleccionado = v.cultivoId
                cultivoNombreSeleccionado = v.cultivoNombre
            }

            if let lat = v.latitud, let lon = v.longitud {
                locationManager.latitud = lat
                locationManager.longitud = lon
            }
        }
    }

    // ── Funciones helper ─────────────────────────────────────────
    @MainActor
    private func buscarProductos(_ query: String) async {
        buscandoProducto = true
        do {
            resultadosBusqueda = try await APIService.shared
                .getArticulosParaVisita(search: query)
        } catch {
            resultadosBusqueda = []
        }
        buscandoProducto = false
    }

    private func agregarProducto(_ nombre: String) {
        if !productosSeleccionados.contains(nombre) {
            productosSeleccionados.append(nombre)
        }
        busquedaProducto = ""
        resultadosBusqueda = []
    }
}

#Preview {
    NavigationStack {
        NuevaVisitaView()
    }
}

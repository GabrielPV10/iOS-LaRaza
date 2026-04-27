//
//  HistorialView.swift
//  La-Raza
//
//  Created by Alumno on 27/04/26.
//

import SwiftUI

// MARK: - Modelo de Visita para Historial
struct VisitaHistorial: Identifiable {
    let id = UUID()
    let nombreProductor: String
    let ranchoEjido: String
    let cultivo: String
    let fecha: Date
    let productosRecomendados: [String]
    let notas: String
    let sincronizado: Bool
    let latitud: Double?
    let longitud: Double?
}

// MARK: - Datos de prueba
extension VisitaHistorial {
    static let ejemplos: [VisitaHistorial] = [
        VisitaHistorial(
            nombreProductor: "Juan Perez Lopez",
            ranchoEjido: "Ejido La Union",
            cultivo: "Maiz",
            fecha: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            productosRecomendados: ["Urea 46%", "Clorpirifos 480 EC"],
            notas: "Se detecto plaga de cogollero en etapa V4. Se recomienda aplicacion preventiva.",
            sincronizado: true,
            latitud: 16.7516,
            longitud: -93.1153
        ),
        VisitaHistorial(
            nombreProductor: "Maria Gomez Ruiz",
            ranchoEjido: "Rancho El Palmito",
            cultivo: "Soya",
            fecha: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            productosRecomendados: ["Glifosato 480 SL", "DAP 18-46-0"],
            notas: "Suelo con deficiencia de fosforo. Aplicar DAP antes de siguiente lluvia.",
            sincronizado: true,
            latitud: 16.8210,
            longitud: -93.0874
        ),
        VisitaHistorial(
            nombreProductor: "Carlos Hernandez",
            ranchoEjido: "Ejido Buena Vista",
            cultivo: "Chile",
            fecha: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
            productosRecomendados: ["Mancozeb 80 WP"],
            notas: "Presencia de antracnosis en frutos. Aplicacion urgente de fungicida.",
            sincronizado: false,
            latitud: nil,
            longitud: nil
        ),
        VisitaHistorial(
            nombreProductor: "Rosa Mendez",
            ranchoEjido: "Rancho San Jose",
            cultivo: "Maiz",
            fecha: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
            productosRecomendados: ["Urea 46%", "Sulfato de Potasio"],
            notas: "Plantas con amarillamiento foliar. Probable deficiencia de nitrogeno.",
            sincronizado: false,
            latitud: 16.7890,
            longitud: -93.2100
        ),
        VisitaHistorial(
            nombreProductor: "Pedro Vazquez",
            ranchoEjido: "Ejido 20 de Noviembre",
            cultivo: "Sorgo",
            fecha: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
            productosRecomendados: ["Clorpirifos 480 EC"],
            notas: "Control de pulgon amarillo. Segunda aplicacion necesaria en 10 dias.",
            sincronizado: true,
            latitud: 16.6543,
            longitud: -93.0432
        ),
    ]
}

// MARK: - HistorialView
struct HistorialView: View {
    @Environment(\.dismiss) var dismiss
    @State private var busqueda: String = ""
    @State private var filtroSincronizado: String = "Todas"
    @State private var visitaSeleccionada: VisitaHistorial? = nil

    let filtros = ["Todas", "Sincronizadas", "Pendientes"]

    var visitasFiltradas: [VisitaHistorial] {
        VisitaHistorial.ejemplos.filter { visita in
            let coincideFiltro: Bool
            switch filtroSincronizado {
            case "Sincronizadas": coincideFiltro = visita.sincronizado
            case "Pendientes":    coincideFiltro = !visita.sincronizado
            default:              coincideFiltro = true
            }
            let coincideBusqueda = busqueda.isEmpty ||
                visita.nombreProductor.localizedCaseInsensitiveContains(busqueda) ||
                visita.ranchoEjido.localizedCaseInsensitiveContains(busqueda) ||
                visita.cultivo.localizedCaseInsensitiveContains(busqueda)
            return coincideFiltro && coincideBusqueda
        }
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

                VStack(spacing: 10) {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                        }
                        Spacer()
                        Text("Historial de Visitas")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.left").opacity(0)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // Barra de búsqueda
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.7))
                        TextField("", text: $busqueda,
                            prompt: Text("Buscar productor, rancho...")
                                .foregroundColor(.white.opacity(0.6))
                        )
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
            }
            .fixedSize(horizontal: false, vertical: true)

            // ── FILTROS ──────────────────────────────────────────
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(filtros, id: \.self) { filtro in
                        Button(action: { filtroSincronizado = filtro }) {
                            Text(filtro)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(filtroSincronizado == filtro ? .white : Color(hex: "444444"))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(filtroSincronizado == filtro ? Color(hex: "3CB504") : Color.white)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(
                                            filtroSincronizado == filtro ? Color.clear : Color(hex: "CCCCCC"),
                                            lineWidth: 1
                                        )
                                )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            .background(Color.white)

            // Contador
            HStack {
                Text("\(visitasFiltradas.count) visitas registradas")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "888888"))
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(hex: "F5F5F5"))

            // ── LISTA ────────────────────────────────────────────
            if visitasFiltradas.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "clock.badge.xmark")
                        .font(.system(size: 48))
                        .foregroundColor(Color(hex: "CCCCCC"))
                    Text("No hay visitas registradas")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "888888"))
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(visitasFiltradas) { visita in
                            Button(action: { visitaSeleccionada = visita }) {
                                VisitaCard(visita: visita)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                }
                .background(Color(hex: "F5F5F5"))
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $visitaSeleccionada) { visita in
            DetalleVisitaSheet(visita: visita)
        }
    }
}

// MARK: - Card de visita
struct VisitaCard: View {
    let visita: VisitaHistorial

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Fila superior: productor + badge sincronizado
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(visita.nombreProductor)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(hex: "1A1A1A"))
                    Text(visita.ranchoEjido)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "555555"))
                }
                Spacer()
                // Badge sincronizado
                HStack(spacing: 4) {
                    Image(systemName: visita.sincronizado ? "checkmark.circle.fill" : "clock.fill")
                        .font(.system(size: 11))
                    Text(visita.sincronizado ? "Sincronizado" : "Pendiente")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(visita.sincronizado ? Color(hex: "3CB504") : Color(hex: "E6A817"))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(visita.sincronizado ? Color(hex: "D6F5D6") : Color(hex: "FFF3D6"))
                .cornerRadius(20)
            }

            Divider()

            // Fila: cultivo + fecha
            HStack(spacing: 16) {
                HStack(spacing: 5) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "3CB504"))
                    Text(visita.cultivo)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "555555"))
                }

                Spacer()

                HStack(spacing: 5) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "888888"))
                    Text(visita.fecha, style: .date)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "888888"))
                }
            }

            // Chips de productos
            if !visita.productosRecomendados.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(visita.productosRecomendados, id: \.self) { producto in
                            Text(producto)
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: "3CB504"))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color(hex: "D6F5D6"))
                                .cornerRadius(10)
                        }
                    }
                }
            }

            // Notas (preview)
            if !visita.notas.isEmpty {
                Text(visita.notas)
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "777777"))
                    .lineLimit(2)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Sheet de detalle
struct DetalleVisitaSheet: View {
    let visita: VisitaHistorial
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Handle
            Capsule()
                .fill(Color(hex: "DDDDDD"))
                .frame(width: 40, height: 4)
                .padding(.top, 12)

            // Header
            HStack {
                Text("Detalle de Visita")
                    .font(.system(size: 17, weight: .bold))
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "CCCCCC"))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // Productor
                    InfoSeccion(titulo: "Productor") {
                        FilaDetalle(icono: "person.fill", etiqueta: "Nombre", valor: visita.nombreProductor)
                        FilaDetalle(icono: "mappin.fill", etiqueta: "Rancho", valor: visita.ranchoEjido)
                        FilaDetalle(icono: "leaf.fill", etiqueta: "Cultivo", valor: visita.cultivo)
                    }

                    // Fecha y GPS
                    InfoSeccion(titulo: "Registro") {
                        FilaDetalle(icono: "calendar", etiqueta: "Fecha",
                            valor: visita.fecha.formatted(date: .long, time: .shortened))
                        if let lat = visita.latitud, let lon = visita.longitud {
                            FilaDetalle(icono: "location.fill", etiqueta: "GPS",
                                valor: String(format: "%.5f, %.5f", lat, lon))
                        } else {
                            FilaDetalle(icono: "location.slash", etiqueta: "GPS", valor: "Sin ubicacion")
                        }
                    }

                    // Productos
                    if !visita.productosRecomendados.isEmpty {
                        InfoSeccion(titulo: "Productos Recomendados") {
                            FlowLayout(spacing: 8) {
                                ForEach(visita.productosRecomendados, id: \.self) { p in
                                    Text(p)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(Color(hex: "3CB504"))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color(hex: "D6F5D6"))
                                        .cornerRadius(20)
                                }
                            }
                        }
                    }

                    // Notas
                    if !visita.notas.isEmpty {
                        InfoSeccion(titulo: "Notas y Observaciones") {
                            Text(visita.notas)
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "555555"))
                                .lineSpacing(4)
                        }
                    }
                }
                .padding(20)
            }
        }
        .background(Color(hex: "F5F5F5"))
    }
}

// MARK: - Componentes del sheet
struct InfoSeccion<C: View>: View {
    let titulo: String
    let contenido: () -> C

    init(titulo: String, @ViewBuilder contenido: @escaping () -> C) {
        self.titulo = titulo
        self.contenido = contenido
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(titulo)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Color(hex: "3CB504"))
                .textCase(.uppercase)
            contenido()
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)
    }
}

struct FilaDetalle: View {
    let icono: String
    let etiqueta: String
    let valor: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icono)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "3CB504"))
                .frame(width: 18)
            Text(etiqueta)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "888888"))
            Spacer()
            Text(valor)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(hex: "1A1A1A"))
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        HistorialView()
    }
}

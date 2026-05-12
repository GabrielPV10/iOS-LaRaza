//
//  HistorialView.swift
//  La-Raza
//
//  Created by Alumno on 24/04/26.
//

import SwiftUI
import SwiftData

// MARK: - HistorialView
struct HistorialView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var vm = HistorialViewModel()

    @State private var visitaParaEditar:   VisitaLocal? = nil   // sheet edición
    @State private var visitaParaEliminar: VisitaLocal? = nil   // alerta confirmar
    @State private var mostrarAlertaEliminar = false

    // Color por cultivo — igual que _colorVisita() de Flutter
    func colorCultivo(_ nombre: String) -> Color {
        switch nombre {
        case "Maíz":           return Color(hex: "d97706")
        case "Soya":           return Color(hex: "16a34a")
        case "Sorgo":          return Color(hex: "dc2626")
        case "Caña de azúcar": return Color(hex: "0891b2")
        case "Frijol":         return Color(hex: "7c3aed")
        case "Chile":          return Color(hex: "e11d48")
        case "Tomate":         return Color(hex: "ea580c")
        default:               return Color(hex: "888888")
        }
    }

    var pendientesCount: Int { vm.visitas.filter { !$0.sincronizado }.count }

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
                    Text("Historial de Visitas")
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

            // ── STRIP contador + pendientes — igual que Flutter header strip
            HStack(spacing: 6) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))
                Text("\(vm.visitas.count) visita\(vm.visitas.count != 1 ? "s" : "") registrada\(vm.visitas.count != 1 ? "s" : "")")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
                if pendientesCount > 0 {
                    Text("\(pendientesCount) pendiente\(pendientesCount != 1 ? "s" : "")")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(hex: "E6A817"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(Color(hex: "E6A817").opacity(0.2))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                LinearGradient(
                    colors: [Color(hex: "3CB504"), Color(hex: "1E7A00")],
                    startPoint: .leading, endPoint: .trailing
                )
            )

            // ── LISTA ────────────────────────────────────────────
            if vm.visitas.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: "3CB504").opacity(0.1))
                            .frame(width: 80, height: 80)
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 36))
                            .foregroundColor(Color(hex: "3CB504"))
                    }
                    Text("Sin visitas registradas")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "1A1A1A"))
                    Text("Las visitas que registres\naparecerán aquí")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "888888"))
                        .multilineTextAlignment(.center)
                }
                Spacer()
            } else {
                // Pull-to-refresh
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(vm.visitas) { visita in
                            VisitaCard(
                                visita:       visita,
                                colorCultivo: colorCultivo(visita.cultivoNombre),
                                onEditar:     { visitaParaEditar = visita },
                                onEliminar:   {
                                    visitaParaEliminar   = visita
                                    mostrarAlertaEliminar = true
                                }
                            )
                        }
                    }
                    .padding(16)
                }
                .background(Color(hex: "F5F5F5"))
                .refreshable {
                    vm.cargarHistorial(modelContext: modelContext)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear { vm.cargarHistorial(modelContext: modelContext) }

        // Sheet de edición — presenta NuevaVisitaView con visitaEditar
        .sheet(item: $visitaParaEditar) { visita in
            NuevaVisitaView(visitaEditar: visita)
                .onDisappear { vm.cargarHistorial(modelContext: modelContext) }
        }

        // Alerta confirmación eliminar
        .alert("Eliminar visita", isPresented: $mostrarAlertaEliminar, presenting: visitaParaEliminar) { v in
            Button("Cancelar", role: .cancel) {}
            Button("Eliminar", role: .destructive) {
                vm.eliminar(v, modelContext: modelContext)
            }
        } message: { v in
            Text("¿Eliminar la visita de \(v.nombreProductor) en \(v.ranchoEjido)?\nEsta acción no se puede deshacer.")
        }
    }
}

// MARK: - VisitaCard
struct VisitaCard: View {
    let visita:       VisitaLocal
    let colorCultivo: Color
    let onEditar:     () -> Void
    let onEliminar:   () -> Void

    var tieneUbicacion: Bool { visita.latitud != nil && visita.longitud != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // ── Fila superior: ícono + productor + fecha ─────────
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorCultivo.opacity(0.12))
                        .frame(width: 46, height: 46)
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 22))
                        .foregroundColor(colorCultivo)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(visita.nombreProductor)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(hex: "1A1A1A"))
                    HStack(spacing: 3) {
                        Image(systemName: "mappin")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "888888"))
                        Text(visita.ranchoEjido)
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "888888"))
                    }
                }

                Spacer()

                Text(visita.fechaVisita.formatted(.dateTime.day().month(.abbreviated).year()))
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "888888"))
            }

            // ── Chips: cultivo, GPS, sincronización ──────────────
            FlowLayout(spacing: 6) {
                // Cultivo
                ChipItem(
                    icono:  "eco",
                    label:  visita.cultivoNombre.isEmpty ? "Sin cultivo" : visita.cultivoNombre,
                    color:  colorCultivo
                )
                // GPS
                ChipItem(
                    icono:  tieneUbicacion ? "location.fill" : "location.slash",
                    label:  tieneUbicacion
                        ? String(format: "%.4f, %.4f", visita.latitud!, visita.longitud!)
                        : "Sin GPS",
                    color: tieneUbicacion ? Color(hex: "3CB504") : Color(hex: "888888")
                )
                // Sincronización
                ChipItem(
                    icono:  visita.sincronizado ? "checkmark.icloud" : "arrow.triangle.2.circlepath",
                    label:  visita.sincronizado ? "Sincronizada" : "Pendiente",
                    color:  visita.sincronizado ? Color(hex: "3CB504") : Color(hex: "E6A817")
                )
            }

            // ── Productos recomendados (preview horizontal) ──────
            if !visita.productosRecomendados.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(visita.productosRecomendados, id: \.self) { p in
                            Text(p)
                                .font(.system(size: 11))
                                .foregroundColor(colorCultivo)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(colorCultivo.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                }
            }

            // ── Notas preview ────────────────────────────────────
            if !visita.notas.isEmpty {
                Text(visita.notas)
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "777777"))
                    .lineLimit(2)
            }

            // ── Editar / Eliminar — solo si está pendiente ───────
            if !visita.sincronizado {
                Divider()
                HStack {
                    Spacer()
                    Button(action: onEditar) {
                        Label("Editar", systemImage: "pencil")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(Color(hex: "3CB504"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)

                    Button(action: onEliminar) {
                        Label("Eliminar", systemImage: "trash")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(Color(hex: "E53935"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}

// MARK: - ChipItem
private struct ChipItem: View {
    let icono: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icono)
                .font(.system(size: 11))
            Text(label)
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundColor(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .cornerRadius(20)
    }
}

#Preview { NavigationStack { HistorialView() } }

//
//  HistorialView.swift
//  La-Raza
//
//  Created by Alumno on 24/04/26.
//

import SwiftUI
import SwiftData

struct HistorialView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var vm = HistorialViewModel()
    @State private var visitaAEliminar: VisitaLocal? = nil
    @State private var mostrarConfirmacion = false
    @State private var visitaAEditar: VisitaLocal? = nil

    var pendientesCount: Int {
        vm.visitas.filter { !$0.sincronizado }.count
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

            if vm.cargando {
                Spacer()
                ProgressView()
                    .progressViewStyle(
                        CircularProgressViewStyle(tint: Color(hex: "3CB504"))
                    )
                Spacer()

            } else if vm.visitas.isEmpty {
                // ── ESTADO VACÍO — igual que Flutter ─────────────
                Spacer()
                VStack(spacing: 16) {
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
                        .foregroundColor(Color(hex: "1F2937"))
                    Text("Las visitas que registres\naparecerán aquí")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "888888"))
                        .multilineTextAlignment(.center)
                }
                Spacer()

            } else {
                // ── STRIP CONTADOR — igual que Flutter ────────────
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
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color(hex: "E6A817").opacity(0.2))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "52E808"), Color(hex: "3CB504"),
                                 Color(hex: "1E7A00")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

                // ── LISTA — pull to refresh igual que Flutter ─────
                List {
                    ForEach(vm.visitas) { visita in
                        VisitaCardHistorial(visita: visita)
                            .listRowInsets(EdgeInsets(
                                top: 6, leading: 16,
                                bottom: 6, trailing: 16))
                            .listRowBackground(Color(hex: "F5F5F5"))
                            .listRowSeparator(.hidden)
                            // Botones editar/eliminar solo si pendiente
                            .swipeActions(edge: .trailing,
                                          allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    visitaAEliminar = visita
                                    mostrarConfirmacion = true
                                } label: {
                                    Label("Eliminar", systemImage: "trash")
                                }

                                Button {
                                    visitaAEditar = visita
                                } label: {
                                    Label("Editar", systemImage: "pencil")
                                }
                                .tint(Color(hex: "3CB504"))
                            }
                    }
                }
                .listStyle(.plain)
                .background(Color(hex: "F5F5F5"))
                .refreshable {
                    vm.cargarHistorial(modelContext: modelContext)
                }
            }
        }
        .background(Color(hex: "F5F5F5"))
        .navigationBarHidden(true)
        .onAppear {
            vm.cargarHistorial(modelContext: modelContext)
        }
        // Confirmación eliminar — igual que Flutter AlertDialog
        .alert("Eliminar visita",
               isPresented: $mostrarConfirmacion) {
            Button("Cancelar", role: .cancel) {}
            Button("Eliminar", role: .destructive) {
                if let v = visitaAEliminar {
                    vm.eliminar(v, modelContext: modelContext)
                }
            }
        } message: {
            if let v = visitaAEliminar {
                Text("¿Eliminar la visita de \(v.nombreProductor) en \(v.ranchoEjido)?\nEsta acción no se puede deshacer.")
            }
        }
        // Navegar a editar visita
        .navigationDestination(isPresented: Binding(
            get: { visitaAEditar != nil },
            set: { if !$0 { visitaAEditar = nil } }
        )) {
            if let v = visitaAEditar {
                NuevaVisitaView(visitaEditar: v)
            }
        }
    }
}

// ── CARD DE VISITA — refleja el Container de Flutter ─────────────
struct VisitaCardHistorial: View {
    let visita: VisitaLocal

    var colorVisita: Color {
        if visita.modo == "veterinario" { return Color(hex: "0891b2") }
        switch visita.cultivoNombre {
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

    var iconoVisita: String {
        visita.modo == "veterinario" ? "pawprint.fill" : "leaf.fill"
    }

    var tieneUbicacion: Bool {
        visita.latitud != nil && visita.longitud != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Fila superior — icono + productor + fecha
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorVisita.opacity(0.12))
                        .frame(width: 46, height: 46)
                    Image(systemName: iconoVisita)
                        .font(.system(size: 20))
                        .foregroundColor(colorVisita)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(visita.nombreProductor)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(hex: "1F2937"))

                    HStack(spacing: 4) {
                        Image(systemName: "mappin")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "888888"))
                        Text(visita.ranchoEjido)
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "888888"))
                    }
                }

                Spacer()

                Text(visita.fechaVisita.formatted(
                    .dateTime.day().month(.abbreviated).year()
                    .hour().minute()
                ))
                .font(.system(size: 10))
                .foregroundColor(Color(hex: "888888"))
            }

            // Chips — cultivo/especie, GPS, sync
            // Igual que Flutter Wrap + _chip
            FlowLayout(spacing: 6) {
                // Cultivo o especie
                ChipVisita(
                    icono: visita.modo == "veterinario"
                        ? "pawprint" : "leaf",
                    label: visita.cultivoNombre.isEmpty
                        ? "Sin especificar"
                        : visita.cultivoNombre,
                    color: colorVisita
                )

                // GPS
                ChipVisita(
                    icono: tieneUbicacion ? "location.fill" : "location.slash",
                    label: tieneUbicacion
                        ? String(format: "%.4f, %.4f",
                                 visita.latitud!, visita.longitud!)
                        : "Sin GPS",
                    color: tieneUbicacion
                        ? Color(hex: "3CB504") : Color(hex: "888888")
                )

                // Sincronización
                ChipVisita(
                    icono: visita.sincronizado
                        ? "checkmark.icloud" : "icloud.and.arrow.up",
                    label: visita.sincronizado
                        ? "Sincronizada" : "Pendiente",
                    color: visita.sincronizado
                        ? Color(hex: "3CB504") : Color(hex: "E6A817")
                )
            }

            Divider()
            HStack {
                Spacer()
                Text("← Desliza para editar o eliminar")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "AAAAAA"))
                    .italic()
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        HistorialView()
    }
}

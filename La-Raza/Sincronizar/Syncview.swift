//
//  Syncview.swift
//  La-Raza
//
//  Created by Alumno on 12/05/26.
//

import SwiftUI
import SwiftData

struct SyncView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var vm = VisitasViewModel()

    @State private var pendientesCount: Int = 0

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
                    Text("Sincronización")
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

            VStack(spacing: 20) {

                // ── CARD CONTADOR ─────────────────────────────────
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(pendientesCount > 0
                                  ? Color(hex: "E6A817").opacity(0.15)
                                  : Color(hex: "D6F5D6"))
                            .frame(width: 80, height: 80)
                        Image(systemName: pendientesCount > 0
                              ? "arrow.triangle.2.circlepath.icloud"
                              : "checkmark.icloud")
                            .font(.system(size: 36))
                            .foregroundColor(pendientesCount > 0
                                             ? Color(hex: "E6A817")
                                             : Color(hex: "3CB504"))
                    }

                    Text("\(pendientesCount)")
                        .font(.system(size: 52, weight: .bold))
                        .foregroundColor(Color(hex: "1E7A00"))

                    VStack(spacing: 4) {
                        Text("visita\(pendientesCount != 1 ? "s" : "") pendiente\(pendientesCount != 1 ? "s" : "")")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "888888"))
                        Text(pendientesCount > 0
                             ? "Sin sincronizar al servidor"
                             : "Todo sincronizado ✓")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(pendientesCount > 0
                                             ? Color(hex: "E6A817")
                                             : Color(hex: "3CB504"))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)

                // ── RESULTADO DE ÚLTIMA SYNC ──────────────────────
                if let resultado = vm.resultadoSync {
                    let exitoso = resultado.creadas > 0 || resultado.duplicadas >= 0
                    HStack(spacing: 10) {
                        Image(systemName: exitoso ? "checkmark.circle.fill" : "exclamationmark.circle")
                            .foregroundColor(exitoso ? Color(hex: "3CB504") : Color(hex: "E53935"))
                        Text(vm.mensajeEstado)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(exitoso ? Color(hex: "1E7A00") : Color(hex: "E53935"))
                        Spacer()
                    }
                    .padding(14)
                    .background(exitoso ? Color(hex: "D6F5D6") : Color(hex: "E53935").opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(exitoso
                                    ? Color(hex: "3CB504").opacity(0.3)
                                    : Color(hex: "E53935").opacity(0.3),
                                    lineWidth: 1)
                    )
                }

                if vm.mensajeEstado == "Sin conexión al servidor" && vm.resultadoSync == nil {
                    HStack(spacing: 10) {
                        Image(systemName: "exclamationmark.circle")
                            .foregroundColor(Color(hex: "E53935"))
                        Text(vm.mensajeEstado)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "E53935"))
                        Spacer()
                    }
                    .padding(14)
                    .background(Color(hex: "E53935").opacity(0.1))
                    .cornerRadius(12)
                }

                Spacer()

                // ── BOTÓN SINCRONIZAR ─────────────────────────────
                VStack(spacing: 8) {
                    Button(action: sincronizar) {
                        ZStack {
                            LinearGradient(
                                colors: [Color(hex: "3CB504"), Color(hex: "1E7A00")],
                                startPoint: .leading, endPoint: .trailing
                            )
                            .cornerRadius(14)

                            if vm.sincronizando {
                                HStack(spacing: 8) {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    Text("Sincronizando...")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            } else {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text("Sincronizar ahora")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                .foregroundColor(.white)
                            }
                        }
                        .frame(height: 54)
                        .shadow(color: Color(hex: "3CB504").opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                    .disabled(vm.sincronizando)

                    Text("Asegúrate de tener conexión WiFi o datos móviles")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "888888"))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "F5F5F5"))
        }
        .navigationBarHidden(true)
        .onAppear { pendientesCount = vm.contarPendientes(modelContext: modelContext) }
        .onChange(of: vm.sincronizando) { _, activo in
            if !activo {
                pendientesCount = vm.contarPendientes(modelContext: modelContext)
            }
        }
    }

    private func sincronizar() {
        vm.sincronizarPendientes(modelContext: modelContext)
    }
}

#Preview { NavigationStack { SyncView() } }

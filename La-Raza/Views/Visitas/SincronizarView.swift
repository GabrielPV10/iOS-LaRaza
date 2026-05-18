//
//  SincronizarView.swift
//  La-Raza
//
//  Created by Alumno on 15/04/26.
//

import SwiftUI
import SwiftData

struct SincronizarView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var vm = VisitasViewModel()
    @State private var pendientes: Int = 0

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

            Spacer()

            VStack(spacing: 20) {

                // ── CARD CONTADOR — igual que Flutter ─────────────
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                pendientes > 0
                                ? Color(hex: "E6A817").opacity(0.15)
                                : Color(hex: "D6F5D6")
                            )
                            .frame(width: 80, height: 80)

                        Image(systemName:
                            pendientes > 0
                            ? "icloud.and.arrow.up"
                            : "checkmark.icloud"
                        )
                        .font(.system(size: 36))
                        .foregroundColor(
                            pendientes > 0
                            ? Color(hex: "E6A817")
                            : Color(hex: "3CB504")
                        )
                    }

                    Text("\(pendientes)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(Color(hex: "1E7A00"))

                    Text(pendientes == 1
                         ? "visita pendiente"
                         : "visitas pendientes")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "888888"))

                    Text(
                        pendientes > 0
                        ? "Sin sincronizar al servidor"
                        : "Todo sincronizado ✓"
                    )
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(
                        pendientes > 0
                        ? Color(hex: "E6A817")
                        : Color(hex: "3CB504")
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05),
                        radius: 6, x: 0, y: 2)
                .padding(.horizontal, 20)

                // ── RESULTADO — igual que Flutter ─────────────────
                if vm.resultadoSync != nil {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "3CB504"))
                            .font(.system(size: 20))

                        Text(vm.mensajeEstado)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "1E7A00"))
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: "D6F5D6"))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "3CB504").opacity(0.3),
                                    lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .transition(.opacity)
                }
            }

            Spacer()

            VStack(spacing: 8) {
                // ── BOTÓN SINCRONIZAR — igual que Flutter ─────────
                Button(action: {
                    vm.sincronizarPendientes(modelContext: modelContext)
                }) {
                    HStack(spacing: 8) {
                        if vm.sincronizando {
                            ProgressView()
                                .progressViewStyle(
                                    CircularProgressViewStyle(tint: .white)
                                )
                                .frame(width: 18, height: 18)
                        } else {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 18))
                        }
                        Text(vm.sincronizando
                             ? "Sincronizando..."
                             : "Sincronizar ahora")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        vm.sincronizando
                        ? Color(hex: "AAAAAA")
                        : Color(hex: "3CB504")
                    )
                    .cornerRadius(14)
                }
                .disabled(vm.sincronizando)
                .padding(.horizontal, 20)

                Text("Asegúrate de tener conexión WiFi o datos móviles")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "AAAAAA"))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 24)
            }
        }
        .background(Color(hex: "F5F5F5").ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            pendientes = vm.contarPendientes(modelContext: modelContext)
        }
        .onChange(of: vm.sincronizando) { _, sincronizando in
            if !sincronizando {
                // Recargar conteo después de sync
                pendientes = vm.contarPendientes(
                    modelContext: modelContext)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: vm.resultadoSync != nil)
    }
}

#Preview {
    NavigationStack {
        SincronizarView()
    }
}

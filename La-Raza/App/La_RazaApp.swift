//
//  La_RazaApp.swift
//  La-Raza
//
//  Created by Alumno on 25/03/26.
//
import SwiftUI
import SwiftData

@main
struct La_RazaApp: App {
    @State private var estaAutenticado: Bool = false

    init() {
        // Cargar JWT guardado del login anterior
        APIService.shared.cargarTokenGuardado()
        // Si hay token guardado, saltar el login
        if APIService.shared.token != nil {
            _estaAutenticado = State(initialValue: true)
        }
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if estaAutenticado {
                    DashboardView(estaAutenticado: $estaAutenticado)
                } else {
                    LoginView(estaAutenticado: $estaAutenticado)
                }
            }
        }
        .modelContainer(for: [VisitaLocal.self, ProductoLocal.self])
    }
}

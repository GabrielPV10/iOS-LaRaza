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
        // SwiftData — crea la BD local en el iPhone
        .modelContainer(for: [
            VisitaLocal.self,
            ProductoLocal.self
        ])
    }
}

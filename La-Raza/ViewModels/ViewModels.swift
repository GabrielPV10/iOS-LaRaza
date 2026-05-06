//
//  ViewModels.swift
//  La-Raza
//
//  Created by Alumno on 06/05/26.
//

import SwiftUI
import SwiftData

// MARK: - LOGIN VIEWMODEL
@MainActor
class LoginViewModel: ObservableObject {
    @Published var cargando: Bool = false
    @Published var error: String? = nil

    func iniciarSesion(
        username: String,
        password: String,
        estaAutenticado: Binding<Bool>
    ) {
        guard !username.isEmpty && !password.isEmpty else {
            error = "Ingresa usuario y contraseña."
            return
        }
        cargando = true
        error = nil

        Task {
            do {
                let resp = try await APIService.shared.login(
                    username: username,
                    password: password
                )
                APIService.shared.token = resp.token
                estaAutenticado.wrappedValue = true

            } catch APIError.sinConexion {
                // Sin red — permite acceso temporal hardcoded
                if username == "admin" && password == "1234" {
                    estaAutenticado.wrappedValue = true
                } else {
                    self.error = "Sin conexión. Usa admin / 1234 para pruebas."
                }

            } catch APIError.noAutorizado {
                error = "Usuario o contraseña incorrectos."

            } catch let err {
                self.error = err.localizedDescription
            }
            cargando = false
        }
    }
}

// MARK: - PRODUCTOS VIEWMODEL
@MainActor
class ProductosViewModel: ObservableObject {
    @Published var productos: [ProductoLocal] = []
    @Published var cargando: Bool = false
    @Published var modoOffline: Bool = false
    @Published var error: String? = nil

    func cargarProductos(modelContext: ModelContext) {
        cargando = true
        modoOffline = false
        error = nil

        Task {
            do {
                // 1. Intentar cargar desde API
                let dtos = try await APIService.shared.obtenerProductos()

                // 2. Limpiar cache viejo
                let descriptor = FetchDescriptor<ProductoLocal>()
                let existentes = (try? modelContext.fetch(descriptor)) ?? []
                for p in existentes { modelContext.delete(p) }

                // 3. Guardar nuevo cache en SwiftData
                for dto in dtos {
                    let local = ProductoLocal(
                        id: dto.id,
                        nombre: dto.nombre,
                        categoria: dto.categoria,
                        precio: dto.precio,
                        stock: dto.stock,
                        unidad: dto.unidad,
                        descripcion: dto.descripcion
                    )
                    modelContext.insert(local)
                }
                try? modelContext.save()

                // 4. Cargar en la vista
                let nuevo = FetchDescriptor<ProductoLocal>(
                    sortBy: [SortDescriptor(\.nombre)]
                )
                productos = (try? modelContext.fetch(nuevo)) ?? []

            } catch {
                // Sin red — usar cache local
                modoOffline = true
                let descriptor = FetchDescriptor<ProductoLocal>(
                    sortBy: [SortDescriptor(\.nombre)]
                )
                let cache = (try? modelContext.fetch(descriptor)) ?? []

                if cache.isEmpty {
                    // Sin cache y sin red — datos de prueba
                  //  productos = ProductoLocal.ejemplos
                    self.error = "Sin conexión ni cache. Mostrando datos de ejemplo."
                } else {
                    productos = cache
                }
            }
            cargando = false
        }
    }
}

// MARK: - VISITAS VIEWMODEL
@MainActor
class VisitasViewModel: ObservableObject {
    @Published var guardando: Bool = false
    @Published var guardadoExitoso: Bool = false
    @Published var mensajeEstado: String = ""
    @Published var sincronizando: Bool = false
    @Published var resultadoSync: (subidas: Int, errores: Int)? = nil

    // ── Guardar visita nueva ─────────────────────────────────────
    func guardarVisita(
        nombreProductor: String,
        ranchoEjido: String,
        cultivo: String,
        latitud: Double?,
        longitud: Double?,
        notas: String,
        productos: [String],
        modelContext: ModelContext
    ) {
        guard !nombreProductor.isEmpty && !ranchoEjido.isEmpty && !cultivo.isEmpty else {
            mensajeEstado = "Completa los campos obligatorios."
            return
        }

        guardando = true
        mensajeEstado = ""

        // 1. SIEMPRE guardar local primero (offline-first)
        let visitaLocal = VisitaLocal(
            nombreProductor: nombreProductor,
            ranchoEjido: ranchoEjido,
            cultivo: cultivo,
            latitud: latitud,
            longitud: longitud,
            notas: notas,
            productosRecomendados: productos
        )
        modelContext.insert(visitaLocal)
        try? modelContext.save()

        // 2. Intentar subir a la API
        Task {
            do {
                let resp = try await APIService.shared.subirVisita(visitaLocal)
                visitaLocal.sincronizado = true
                visitaLocal.idRemoto = resp.id
                try? modelContext.save()
                mensajeEstado = "Visita guardada y sincronizada."

            } catch {
                // Sin red — queda pendiente para sincronizar después
                mensajeEstado = "Guardada localmente. Se sincronizará cuando haya conexión."
            }

            guardando = false
            guardadoExitoso = true
        }
    }

    // ── Sincronizar todas las visitas pendientes ─────────────────
    func sincronizarPendientes(modelContext: ModelContext) {
        sincronizando = true
        resultadoSync = nil

        Task {
            let descriptor = FetchDescriptor<VisitaLocal>(
                predicate: #Predicate { !$0.sincronizado }
            )
            let pendientes = (try? modelContext.fetch(descriptor)) ?? []

            var subidas = 0
            var errores = 0

            for visita in pendientes {
                do {
                    let resp = try await APIService.shared.subirVisita(visita)
                    visita.sincronizado = true
                    visita.idRemoto = resp.id
                    subidas += 1
                } catch {
                    errores += 1
                }
            }

            try? modelContext.save()
            resultadoSync = (subidas: subidas, errores: errores)
            sincronizando = false
        }
    }

    // ── Contar pendientes (para el badge en Dashboard) ───────────
    func contarPendientes(modelContext: ModelContext) -> Int {
        let descriptor = FetchDescriptor<VisitaLocal>(
            predicate: #Predicate { !$0.sincronizado }
        )
        return (try? modelContext.fetch(descriptor))?.count ?? 0
    }
}

// MARK: - HISTORIAL VIEWMODEL
@MainActor
class HistorialViewModel: ObservableObject {
    @Published var visitas: [VisitaLocal] = []
    @Published var cargando: Bool = false

    func cargarHistorial(modelContext: ModelContext) {
        cargando = true
        let descriptor = FetchDescriptor<VisitaLocal>(
            sortBy: [SortDescriptor(\.fechaVisita, order: .reverse)]
        )
        visitas = (try? modelContext.fetch(descriptor)) ?? []
        cargando = false
    }

    func eliminarVisita(_ visita: VisitaLocal, modelContext: ModelContext) {
        modelContext.delete(visita)
        try? modelContext.save()
        cargarHistorial(modelContext: modelContext)
    }
}

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
    @Published var cargando = false
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
                try await APIService.shared.login(username: username, password: password)
                estaAutenticado.wrappedValue = true
            } catch APIError.noAutorizado {
                self.error = "Usuario o contraseña incorrectos."
            } catch APIError.sinConexion {
                self.error = "Sin conexión al servidor."
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
    @Published var cargando  = false
    @Published var modoOffline = false
    @Published var error: String? = nil

    func cargarProductos(modelContext: ModelContext) {
        cargando = true
        modoOffline = false
        error = nil
        Task {
            do {
                let dtos = try await APIService.shared.getArticulos(page: 1, limit: 200)
                let viejos = (try? modelContext.fetch(FetchDescriptor<ProductoLocal>())) ?? []
                viejos.forEach { modelContext.delete($0) }
                let nuevos = dtos.map { ProductoLocal(from: $0) }
                nuevos.forEach { modelContext.insert($0) }
                try? modelContext.save()
                productos = nuevos
            } catch APIError.sinConexion {
                modoOffline = true
                let descriptor = FetchDescriptor<ProductoLocal>(sortBy: [SortDescriptor(\.nombre)])
                productos = (try? modelContext.fetch(descriptor)) ?? []
                if productos.isEmpty { error = "Sin conexión y sin cache local." }
            } catch let decErr as DecodingError {
                #if DEBUG
                print("❌ DecodingError artículos: \(decErr)")
                #endif
                error = "Error al leer la respuesta del servidor. Revisa la consola."
            } catch let apiErr as APIError {
                error = apiErr.localizedDescription
            } catch {
                self.error = error.localizedDescription
            }
            cargando = false
        }
    }

    func buscar(_ texto: String, modelContext: ModelContext) {
        guard !texto.isEmpty else { cargarProductos(modelContext: modelContext); return }
        cargando = true
        error = nil
        Task {
            do {
                let dtos = try await APIService.shared.getArticulos(search: texto)
                productos = dtos.map { ProductoLocal(from: $0) }
            } catch APIError.sinConexion {
                let pred = #Predicate<ProductoLocal> { $0.nombre.localizedStandardContains(texto) }
                productos = (try? modelContext.fetch(FetchDescriptor<ProductoLocal>(predicate: pred))) ?? []
            } catch let decErr as DecodingError {
                #if DEBUG
                print("❌ DecodingError búsqueda: \(decErr)")
                #endif
                error = "Error al leer la respuesta del servidor."
            } catch {
                self.error = error.localizedDescription
            }
            cargando = false
        }
    }
}

// MARK: - CULTIVOS VIEWMODEL
@MainActor
class CultivosViewModel: ObservableObject {
    @Published var cultivos: [CultivoDTO] = []
    @Published var cargando = false

    let cultivosFallback: [CultivoDTO] = [
        CultivoDTO(id: 1,  nombre: "Maíz"),
        CultivoDTO(id: 2,  nombre: "Soya"),
        CultivoDTO(id: 3,  nombre: "Sorgo"),
        CultivoDTO(id: 4,  nombre: "Caña de azúcar"),
        CultivoDTO(id: 5,  nombre: "Frijol"),
        CultivoDTO(id: 6,  nombre: "Chile"),
        CultivoDTO(id: 7,  nombre: "Tomate"),
        CultivoDTO(id: 11, nombre: "Otro"),
    ]

    func cargarCultivos() {
        cargando = true
        Task {
            do { cultivos = try await APIService.shared.getCultivos() }
            catch { cultivos = cultivosFallback }
            cargando = false
        }
    }
}

// MARK: - VISITAS VIEWMODEL
@MainActor
class VisitasViewModel: ObservableObject {
    @Published var guardando       = false
    @Published var guardadoExitoso = false
    @Published var mensajeEstado   = ""
    @Published var sincronizando   = false
    @Published var resultadoSync: (creadas: Int, duplicadas: Int)? = nil

    // ── NUEVA VISITA ─────────────────────────────────────────────
    func guardarVisita(
        nombreProductor: String,
        ranchoEjido: String,
        cultivoId: Int,
        cultivoNombre: String,
        modo: String,           // ← agrega
        especie: String?,       // ← agrega
        latitud: Double?,
        longitud: Double?,
        notas: String,
        productos: [String],
        modelContext: ModelContext
    ) {
        guardando = true
        guardadoExitoso = false

        let visitaLocal = VisitaLocal(
                nombreProductor: nombreProductor,
                ranchoEjido: ranchoEjido,
                cultivoId: cultivoId,
                cultivoNombre: cultivoNombre,
                modo: modo,         // ← agrega
                especie: especie,   // ← agrega
                latitud: latitud,
                longitud: longitud,
                notas: notas,
                productosRecomendados: productos
            )
        modelContext.insert(visitaLocal)
        try? modelContext.save()

        mensajeEstado = "Visita guardada. Sincronízala cuando estés listo."
        guardando = false
        guardadoExitoso = true
    }

    // ── EDITAR VISITA ────────────────────────────────────────────
    // Equivalente a actualizarVisita() en Flutter
    func actualizarVisita(
        visita: VisitaLocal,
        nombreProductor: String,
        ranchoEjido: String,
        cultivoId: Int,
        cultivoNombre: String,
        latitud: Double?,
        longitud: Double?,
        notas: String,
        productos: [String],
        modelContext: ModelContext
    ) {
        guardando = true
        guardadoExitoso = false

        // Mutar la visita existente en SwiftData
        visita.nombreProductor      = nombreProductor
        visita.ranchoEjido          = ranchoEjido
        visita.cultivoId            = cultivoId
        visita.cultivoNombre        = cultivoNombre
        visita.latitud              = latitud
        visita.longitud             = longitud
        visita.notas                = notas
        visita.productosRecomendados = productos
        visita.sincronizado         = false
        try? modelContext.save()

        mensajeEstado = "Visita actualizada. Sincronízala cuando estés listo."
        guardando = false
        guardadoExitoso = true
    }

    // ── SYNC MASIVO ──────────────────────────────────────────────
    func sincronizarPendientes(modelContext: ModelContext) {
        sincronizando = true
        resultadoSync = nil

        Task {
            let descriptor = FetchDescriptor<VisitaLocal>(
                predicate: #Predicate { !$0.sincronizado }
            )
            let pendientes = (try? modelContext.fetch(descriptor)) ?? []

            guard !pendientes.isEmpty else {
                mensajeEstado = "No hay visitas pendientes"
                sincronizando = false
                resultadoSync = (creadas: 0, duplicadas: 0)
                return
            }

            do {
                let resultado = try await APIService.shared.sincronizarVisitas(pendientes)
                pendientes.forEach { $0.sincronizado = true }
                try? modelContext.save()
                resultadoSync = (
                    creadas:    resultado.creadas    ?? 0,
                    duplicadas: resultado.duplicadas ?? 0
                )
                mensajeEstado = "\(resultado.creadas ?? 0) nuevas, \(resultado.duplicadas ?? 0) ya existían"
            } catch {
                mensajeEstado = "Sin conexión al servidor"
                resultadoSync = (creadas: 0, duplicadas: 0)
            }
            sincronizando = false
        }
    }

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
    @Published var cargando = false

    func cargarHistorial(modelContext: ModelContext) {
        cargando = true
        let descriptor = FetchDescriptor<VisitaLocal>(
            sortBy: [SortDescriptor(\.fechaVisita, order: .reverse)]
        )
        visitas  = (try? modelContext.fetch(descriptor)) ?? []
        cargando = false
    }

    func eliminar(_ visita: VisitaLocal, modelContext: ModelContext) {
        modelContext.delete(visita)
        try? modelContext.save()
        cargarHistorial(modelContext: modelContext)
    }
}

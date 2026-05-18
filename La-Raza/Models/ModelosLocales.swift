//
//  ModelosLocales.swift
//  La-Raza
//
//  Created by Alumno on 28/04/26.
//

import SwiftData
import Foundation

@Model
class VisitaLocal {
    var id: UUID
    var nombreProductor: String
    var ranchoEjido: String
    var cultivoId: Int
    var cultivoNombre: String
    var modo: String              // ← NUEVO: "cultivo" | "veterinario"
    var especie: String?          // ← NUEVO: solo veterinario
    var latitud: Double?
    var longitud: Double?
    var notas: String
    var productosRecomendados: [String]
    var fechaVisita: Date
    var sincronizado: Bool
    var idRemoto: Int?

    init(
        nombreProductor: String,
        ranchoEjido: String,
        cultivoId: Int = 0,
        cultivoNombre: String = "",
        modo: String = "cultivo",
        especie: String? = nil,
        latitud: Double? = nil,
        longitud: Double? = nil,
        notas: String = "",
        productosRecomendados: [String] = []
    ) {
        self.id = UUID()
        self.nombreProductor = nombreProductor
        self.ranchoEjido = ranchoEjido
        self.cultivoId = cultivoId
        self.cultivoNombre = cultivoNombre
        self.modo = modo
        self.especie = especie
        self.latitud = latitud
        self.longitud = longitud
        self.notas = notas
        self.productosRecomendados = productosRecomendados
        self.fechaVisita = Date()
        self.sincronizado = false
        self.idRemoto = nil
    }
}

// toRequest() refleja exactamente toBackendJson() de Flutter
extension VisitaLocal {
    func toRequest() -> VisitaRequest {
        let prods = productosRecomendados.map {
            ProductoRecomendadoDTO(articuloNombre: $0)
        }
        let formatter = ISO8601DateFormatter()
        return VisitaRequest(
            idLocal: id.uuidString,
            productor: nombreProductor,
            rancho: ranchoEjido,
            cultivoId: cultivoId,
            modo: modo,
            especie: especie,
            latitud: latitud,
            longitud: longitud,
            notas: notas,
            fechaVisita: formatter.string(from: fechaVisita),
            productosRecomendados: prods
        )
    }
}

// MARK: - ProductoLocal
@Model
class ProductoLocal {
    var id: Int
    var clave: String
    var nombre: String
    var descripcion: String
    var precio: Double
    var precioMayoreo: Double
    var stock: Int
    var marca: String
    var ultimaActualizacion: Date

    init(from dto: ArticuloDTO) {
        self.id = dto.id
        self.clave = dto.clave
        self.nombre = dto.nombre
        self.descripcion = dto.descripcion ?? ""
        self.precio = dto.precio
        self.precioMayoreo = dto.precioReferencia ?? 0
        self.stock = dto.stockTotal
        self.marca = dto.marca ?? ""
        self.ultimaActualizacion = Date()
    }
}

extension ProductoLocal {
    static let ejemplos: [ProductoLocal] = []
}


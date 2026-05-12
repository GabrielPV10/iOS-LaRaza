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
    var cultivoId: Int?        
    var cultivoNombre: String
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
        cultivoId: Int? = nil,
        cultivoNombre: String = "",
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
        self.latitud = latitud
        self.longitud = longitud
        self.notas = notas
        self.productosRecomendados = productosRecomendados
        self.fechaVisita = Date()
        self.sincronizado = false
        self.idRemoto = nil
    }
}

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

// ── SESION LOCAL ─────────────────────────────────────────────────
// Guarda el JWT para no pedir login cada vez
@Model
class SesionLocal {
    var token: String
    var username: String
    var rol: String
    var expiracion: Date

    var estaVigente: Bool {
        Date() < expiracion
    }

    init(token: String, username: String, rol: String, expiracion: Date) {
        self.token = token
        self.username = username
        self.rol = rol
        self.expiracion = expiracion
    }
}


// En ModelosLocales.swift, dentro de la clase VisitaLocal
// agrega esta extensión al final del archivo:

extension VisitaLocal {
    // Convierte al DTO que espera el backend
    // igual que toBackendJson() en Flutter
    func toRequest() -> VisitaRequest {
        let prods = productosRecomendados.map {
            ProductoRecomendadoDTO(articuloNombre: $0)
        }

        let formatter = ISO8601DateFormatter()
        let fechaStr = formatter.string(from: fechaVisita)

        return VisitaRequest(
            idLocal: id.uuidString,          // UUID como string
            productor: nombreProductor,
            rancho: ranchoEjido,
            cultivoId: cultivoId ?? 0,
            latitud: latitud,
            longitud: longitud,
            notas: notas,
            fechaVisita: fechaStr,
            productosRecomendados: prods
        )
    }
}

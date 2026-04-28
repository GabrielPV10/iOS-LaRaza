//
//  ModelosLocales.swift
//  La-Raza
//
//  Created by Alumno on 28/04/26.
//

import SwiftData
import Foundation

// ── VISITA LOCAL ────────────────────────────────────────────────
// Refleja la tabla laraza.visitas_tecnicas en PostgreSQL
@Model
class VisitaLocal {
    var id: UUID
    var nombreProductor: String
    var ranchoEjido: String
    var cultivo: String
    var latitud: Double?
    var longitud: Double?
    var notas: String
    var productosRecomendados: [String]
    var fechaVisita: Date
    var sincronizado: Bool       // false = pendiente de subir a la API
    var idRemoto: Int?           // ID asignado por PostgreSQL al sincronizar

    init(
        nombreProductor: String,
        ranchoEjido: String,
        cultivo: String,
        latitud: Double? = nil,
        longitud: Double? = nil,
        notas: String = "",
        productosRecomendados: [String] = []
    ) {
        self.id = UUID()
        self.nombreProductor = nombreProductor
        self.ranchoEjido = ranchoEjido
        self.cultivo = cultivo
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
    var nombre: String
    var categoria: String
    var precio: Double
    var stock: Double
    var unidad: String
    var descripcion: String
    var ultimaActualizacion: Date

    init(id: Int, nombre: String, categoria: String,
         precio: Double, stock: Double, unidad: String, descripcion: String) {
        self.id = id
        self.nombre = nombre
        self.categoria = categoria
        self.precio = precio
        self.stock = stock
        self.unidad = unidad
        self.descripcion = descripcion
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

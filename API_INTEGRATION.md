# 🔌 Integración con API Real - SmartStay Personal

## 📋 Nueva Funcionalidad: Apertura de Puertas

Se ha agregado la funcionalidad para que el personal pueda **abrir puertas de habitaciones con un click**.

### ✨ Características Implementadas

1. **Pantalla de Habitaciones** (`rooms_screen.dart`)
   - Lista de todas las habitaciones del hotel
   - Búsqueda por número de habitación, huésped o tipo
   - Filtros por estado: Todas, Ocupadas, Disponibles, Limpieza
   - Botón "ABRIR PUERTA" en cada habitación
   - Indicadores visuales del estado de la puerta

2. **Servicio de Cerraduras** (`lock_service.dart`)
   - Gestión de habitaciones
   - Apertura de puertas
   - Consulta de estado de cerraduras
   - Historial de accesos

3. **Modelos de Datos** según tu base de datos:
   - `Room` - Habitaciones (tabla `Habitaciones`)
   - `Cerradura` - Cerraduras inteligentes (tabla `CerradurasInteligentes`)

## 🗄️ Tablas de Base de Datos Utilizadas

La aplicación está diseñada para trabajar con las siguientes tablas de tu BD:

### 1. Habitaciones
```sql
SELECT
    HabitacionId,
    HotelId,
    NumeroHabitacion,
    TipoHabitacion,
    Estado,
    EstaDisponible
FROM [dbo].[Habitaciones]
```

### 2. CerradurasInteligentes
```sql
SELECT
    c.CerraduraId,
    c.HabitacionId,
    c.DispositivoId,
    c.EstadoPuerta,
    c.ModoOperacion,
    c.ContadorAperturas,
    c.EstaActiva,
    h.NumeroHabitacion
FROM [dbo].[CerradurasInteligentes] c
INNER JOIN [dbo].[Habitaciones] h ON c.HabitacionId = h.HabitacionId
```

### 3. RegistrosAcceso (para historial)
```sql
SELECT
    RegistroId,
    CerraduraId,
    UsuarioId,
    FechaHoraAcceso,
    TipoAcceso,
    ResultadoAcceso,
    FueExitoso
FROM [dbo].[RegistrosAcceso]
WHERE CerraduraId = @CerraduraId
ORDER BY FechaHoraAcceso DESC
```

## 🔧 Endpoints de API Necesarios

Para conectar con la API real, necesitas implementar estos endpoints en tu backend:

### 1. GET /api/habitaciones
Obtener lista de habitaciones con sus cerraduras.

**Request:**
```http
GET /api/habitaciones?hotelId=1
Authorization: Bearer {token}
```

**Response:**
```json
[
  {
    "habitacionId": 1,
    "hotelId": 1,
    "numeroHabitacion": "101",
    "tipoHabitacion": "Suite",
    "estado": "Ocupada",
    "cerraduraId": 1,
    "estadoPuerta": "Cerrada",
    "guestName": "Carlos Méndez",
    "checkInDate": "2025-12-06T00:00:00Z",
    "checkOutDate": "2025-12-11T00:00:00Z",
    "estaDisponible": false
  }
]
```

### 2. POST /api/cerraduras/{cerraduraId}/abrir
Abrir puerta de habitación.

**Request:**
```http
POST /api/cerraduras/1/abrir
Authorization: Bearer {token}
Content-Type: application/json

{
  "habitacionId": 1,
  "motivo": "Acceso Personal",
  "tipoAcceso": "AccesoPersonalLimpieza"
}
```

**Response:**
```json
{
  "exitoso": true,
  "mensaje": "Puerta de habitación 101 desbloqueada correctamente",
  "cerraduraId": 1,
  "habitacionId": 1,
  "fechaHora": "2025-12-08T14:30:00Z",
  "registroId": 12345
}
```

**Response (Error):**
```json
{
  "exitoso": false,
  "mensaje": "Error al desbloquear puerta: Dispositivo offline",
  "cerraduraId": 1,
  "habitacionId": 1,
  "codigoError": "DEVICE_OFFLINE"
}
```

### 3. GET /api/cerraduras/{cerraduraId}
Obtener información de una cerradura específica.

**Request:**
```http
GET /api/cerraduras/1
Authorization: Bearer {token}
```

**Response:**
```json
{
  "cerraduraId": 1,
  "habitacionId": 1,
  "dispositivoId": 101,
  "numeroHabitacion": "101",
  "estadoPuerta": "Cerrada",
  "modoOperacion": "Normal",
  "contadorAperturas": 45,
  "estaActiva": true,
  "ultimaApertura": "2025-12-08T12:15:00Z"
}
```

### 4. GET /api/habitaciones/{habitacionId}/accesos
Obtener historial de accesos de una habitación.

**Request:**
```http
GET /api/habitaciones/1/accesos?limit=10
Authorization: Bearer {token}
```

**Response:**
```json
[
  {
    "registroId": 12345,
    "fechaHora": "2025-12-08T14:30:00Z",
    "tipoAcceso": "AccesoPersonalLimpieza",
    "resultado": "Exitoso",
    "usuario": "Personal Limpieza",
    "nombreCompleto": "María González"
  }
]
```

## 🔄 Cómo Conectar con la API Real

### Paso 1: Configurar URL Base

Edita `lib/config/constants.dart`:

```dart
class AppConstants {
  // Cambia esta URL por tu servidor real
  static const String apiBaseUrl = 'https://tu-dominio.com/api';

  // O para desarrollo local:
  // static const String apiBaseUrl = 'http://10.0.2.2:5000/api';
}
```

### Paso 2: Actualizar LockService

Edita `lib/services/lock_service.dart`:

**Descomentar el código de API real** y comentar el código mock:

```dart
// En el método getRooms()
Future<List<Room>> getRooms({int? hotelId}) async {
  // COMENTAR O ELIMINAR ESTE BLOQUE DE MOCK DATA
  /*
  await Future.delayed(const Duration(milliseconds: 500));
  return [ ... datos mock ... ];
  */

  // DESCOMENTAR ESTE BLOQUE
  final token = await _getAuthToken(); // Implementar obtención de token

  try {
    final response = await http.get(
      Uri.parse('${AppConstants.apiBaseUrl}/habitaciones'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Room.fromJson(json)).toList();
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error de conexión: $e');
  }
}
```

**Hacer lo mismo para:**
- `unlockDoor()`
- `getCerradura()`
- `getAccessHistory()`

### Paso 3: Obtener Token de Autenticación

Agregar método helper en `LockService`:

```dart
import '../services/auth_service.dart';

class LockService {
  final AuthService _authService = AuthService();

  Future<String?> _getAuthToken() async {
    return await _authService.getAccessToken();
  }

  // ... resto del código
}
```

### Paso 4: Manejo de Errores

La API debe retornar códigos de estado HTTP apropiados:

- `200 OK` - Operación exitosa
- `401 Unauthorized` - Token inválido o expirado
- `403 Forbidden` - Sin permisos para esta acción
- `404 Not Found` - Habitación/cerradura no encontrada
- `500 Internal Server Error` - Error del servidor
- `503 Service Unavailable` - Cerradura offline

## 📝 Stored Procedures Recomendados

Puedes crear estos SPs en tu base de datos para facilitar la integración:

### SP_AbrirPuertaHabitacion
```sql
CREATE PROCEDURE [dbo].[SP_AbrirPuertaHabitacion]
    @CerraduraId INT,
    @UsuarioId NVARCHAR(450),
    @TipoAcceso NVARCHAR(50),
    @Motivo NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Exitoso BIT = 0;
    DECLARE @Mensaje NVARCHAR(500);
    DECLARE @EstadoDispositivo NVARCHAR(50);

    -- Verificar estado del dispositivo
    SELECT @EstadoDispositivo = d.EstadoFuncional
    FROM [dbo].[CerradurasInteligentes] c
    INNER JOIN [dbo].[Dispositivos] d ON c.DispositivoId = d.DispositivoId
    WHERE c.CerraduraId = @CerraduraId;

    IF @EstadoDispositivo = 'Operativo'
    BEGIN
        -- Actualizar estado de la cerradura
        UPDATE [dbo].[CerradurasInteligentes]
        SET EstadoPuerta = 'Abierta',
            ContadorAperturas = ContadorAperturas + 1,
            UltimaApertura = GETUTCDATE()
        WHERE CerraduraId = @CerraduraId;

        -- Registrar el acceso
        INSERT INTO [dbo].[RegistrosAcceso]
            (CerraduraId, UsuarioId, TipoAcceso, ResultadoAcceso,
             MotivoAcceso, FueExitoso, FechaHoraAcceso)
        VALUES
            (@CerraduraId, @UsuarioId, @TipoAcceso, 'Exitoso',
             @Motivo, 1, GETUTCDATE());

        SET @Exitoso = 1;
        SET @Mensaje = 'Puerta desbloqueada correctamente';
    END
    ELSE
    BEGIN
        SET @Mensaje = 'Error: Dispositivo no operativo - ' + @EstadoDispositivo;

        -- Registrar intento fallido
        INSERT INTO [dbo].[RegistrosAcceso]
            (CerraduraId, UsuarioId, TipoAcceso, ResultadoAcceso,
             MotivoAcceso, FueExitoso, CodigoError, FechaHoraAcceso)
        VALUES
            (@CerraduraId, @UsuarioId, @TipoAcceso, 'Denegado',
             @Motivo, 0, 'DEVICE_NOT_OPERATIONAL', GETUTCDATE());
    END

    SELECT
        @Exitoso AS Exitoso,
        @Mensaje AS Mensaje,
        @CerraduraId AS CerraduraId,
        GETUTCDATE() AS FechaHora,
        SCOPE_IDENTITY() AS RegistroId;
END
GO
```

### SP_ObtenerHabitacionesConCerraduras
```sql
CREATE PROCEDURE [dbo].[SP_ObtenerHabitacionesConCerraduras]
    @HotelId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        h.HabitacionId,
        h.HotelId,
        h.NumeroHabitacion,
        h.TipoHabitacion,
        h.Estado,
        h.EstaDisponible,
        c.CerraduraId,
        c.EstadoPuerta,
        -- Datos del huésped actual si está ocupada
        hues.NombreCompleto AS GuestName,
        r.FechaCheckIn AS CheckInDate,
        r.FechaCheckOut AS CheckOutDate
    FROM [dbo].[Habitaciones] h
    LEFT JOIN [dbo].[CerradurasInteligentes] c ON h.HabitacionId = c.HabitacionId
    LEFT JOIN [dbo].[Reservas] r ON h.HabitacionId = r.HabitacionId
        AND r.Estado = 'CheckInRealizado'
        AND GETUTCDATE() BETWEEN r.FechaCheckIn AND r.FechaCheckOut
    LEFT JOIN [dbo].[Huespedes] hues ON r.HuespedId = hues.HuespedId
    WHERE h.HotelId = @HotelId
    ORDER BY h.NumeroHabitacion;
END
GO
```

## 🎯 Funcionalidades Listas para Usar

Con datos mock (actual):
- ✅ Ver lista de habitaciones
- ✅ Buscar y filtrar habitaciones
- ✅ Botón para abrir puertas
- ✅ Confirmación antes de abrir
- ✅ Feedback visual del resultado
- ✅ Indicadores de estado de puerta

Para habilitar con API real:
- 🔄 Descomentar código de API en `lock_service.dart`
- 🔄 Configurar URL de API en `constants.dart`
- 🔄 Implementar endpoints en el backend
- 🔄 Crear stored procedures en SQL Server

## 🔒 Seguridad

La aplicación ya incluye:
- ✅ Confirmación antes de abrir puertas
- ✅ Registro de quién abre cada puerta (con token JWT)
- ✅ Validación de permisos (manejado por backend)
- ✅ Auditoría de accesos

Tu backend debe:
- 🔐 Validar que el personal tenga permisos para esa habitación
- 🔐 Registrar todos los accesos en `RegistrosAcceso`
- 🔐 Verificar estado del dispositivo antes de abrir
- 🔐 Implementar rate limiting para prevenir abuso

## 📊 Dashboard de Personal

La app ya incluye en el dashboard:
- Total de solicitudes pendientes/completadas
- Navegación rápida a solicitudes

Puedes agregar:
- Total de habitaciones accedidas hoy
- Alertas de cerraduras con batería baja
- Notificaciones de cerraduras offline

## 🚀 Próximos Pasos

1. **Ahora:** Prueba la funcionalidad con datos mock
2. **Desarrollo:** Implementa los endpoints en tu API
3. **Integración:** Descomenta el código real en `lock_service.dart`
4. **Testing:** Prueba con dispositivos reales
5. **Producción:** Deploy con la API real conectada

---

**¿Preguntas?** Consulta la documentación completa en `README_APP.md`

# 🏗️ Arquitectura de SmartStay Personal

## 📐 Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                         PRESENTACIÓN                         │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌──────────┐ │
│  │  Login    │  │ Dashboard │  │  Requests │  │ Profile  │ │
│  │  Screen   │  │  Screen   │  │   Screen  │  │  Screen  │ │
│  └─────┬─────┘  └─────┬─────┘  └─────┬─────┘  └────┬─────┘ │
│        │              │              │              │        │
│        └──────────────┴──────────────┴──────────────┘        │
│                           │                                   │
└───────────────────────────┼───────────────────────────────────┘
                            │
┌───────────────────────────┼───────────────────────────────────┐
│                    STATE MANAGEMENT                           │
│                           │                                   │
│         ┌─────────────────┴─────────────────┐                │
│         │                                   │                │
│  ┌──────▼──────┐                   ┌───────▼──────┐         │
│  │   Auth      │                   │   Request    │         │
│  │  Provider   │                   │   Provider   │         │
│  └──────┬──────┘                   └───────┬──────┘         │
└─────────┼──────────────────────────────────┼────────────────┘
          │                                  │
┌─────────┼──────────────────────────────────┼────────────────┐
│         │         LÓGICA DE NEGOCIO        │                │
│         │                                  │                │
│  ┌──────▼──────┐  ┌──────────┐   ┌────────▼───────┐       │
│  │    Auth     │  │   NFC    │   │    Request     │       │
│  │   Service   │  │ Service  │   │    Service     │       │
│  └──────┬──────┘  └─────┬────┘   └────────┬───────┘       │
└─────────┼────────────────┼─────────────────┼───────────────┘
          │                │                 │
┌─────────┼────────────────┼─────────────────┼───────────────┐
│         │      CAPA DE DATOS               │               │
│         │                │                 │               │
│  ┌──────▼──────┐  ┌──────▼────┐   ┌───────▼───────┐      │
│  │   Secure    │  │    NFC    │   │  HTTP Client  │      │
│  │   Storage   │  │  Hardware │   │   (API)       │      │
│  └─────────────┘  └───────────┘   └───────────────┘      │
└───────────────────────────────────────────────────────────┘
```

## 🔄 Flujo de Datos

### 1. Autenticación
```
Usuario → Login Screen → Auth Provider → Auth Service → API
                              ↓                           ↓
                     Actualiza Estado              Guarda Tokens
                              ↓                           ↓
                     Navega a Dashboard      Secure Storage
```

### 2. Gestión de Solicitudes
```
Usuario → Requests Screen → Request Provider → Request Service
                                  ↓                    ↓
                           Actualiza Estado       Mock Data
                                  ↓              (o API Real)
                            Renderiza UI
```

### 3. NFC
```
Usuario → FAB → NFC Screen → NFC Service → Hardware NFC
                                  ↓              ↓
                          Muestra Feedback   Lee Tag
                                  ↓              ↓
                          Desbloquea Puerta ←────┘
```

## 📁 Estructura de Carpetas Detallada

```
smartstay_personal/
│
├── lib/
│   ├── config/                    # Configuración global
│   │   ├── theme.dart            # Tema corporativo
│   │   └── constants.dart        # Constantes de la app
│   │
│   ├── models/                    # Modelos de datos
│   │   ├── user.dart             # Usuario/Empleado
│   │   ├── request.dart          # Solicitud de servicio
│   │   ├── room.dart             # Habitación
│   │   └── auth_response.dart    # Respuesta de autenticación
│   │
│   ├── services/                  # Lógica de negocio
│   │   ├── auth_service.dart     # Autenticación con API
│   │   ├── nfc_service.dart      # Operaciones NFC
│   │   └── request_service.dart  # Gestión de solicitudes
│   │
│   ├── providers/                 # State Management
│   │   ├── auth_provider.dart    # Estado de autenticación
│   │   └── request_provider.dart # Estado de solicitudes
│   │
│   ├── screens/                   # Pantallas de la app
│   │   ├── login_screen.dart
│   │   ├── main_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── requests_list_screen.dart
│   │   ├── request_detail_screen.dart
│   │   ├── history_screen.dart
│   │   ├── profile_screen.dart
│   │   └── nfc_unlock_screen.dart
│   │
│   ├── widgets/                   # Componentes reutilizables
│   │   ├── request_card.dart
│   │   └── stats_card.dart
│   │
│   └── main.dart                  # Punto de entrada
│
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml   # Permisos NFC
│
├── ios/
│   └── Runner/
│       └── Info.plist            # Configuración iOS
│
├── pubspec.yaml                   # Dependencias
├── README_APP.md                  # Documentación principal
├── TESTING_GUIDE.md              # Guía de pruebas
├── PROJECT_SUMMARY.md            # Resumen ejecutivo
├── QUICK_START.md                # Inicio rápido
└── ARCHITECTURE.md               # Este archivo
```

## 🎯 Patrones de Diseño Utilizados

### 1. MVVM (Model-View-ViewModel)
- **Model**: `lib/models/` - Datos y lógica de negocio
- **View**: `lib/screens/` y `lib/widgets/` - UI
- **ViewModel**: `lib/providers/` - Estado y lógica de presentación

### 2. Repository Pattern
- Servicios actúan como repositorios
- Abstracción de fuentes de datos
- Facilita testing y mantenimiento

### 3. Singleton
- Servicios como instancias únicas
- Compartidos entre providers

### 4. Observer Pattern
- Provider notifica cambios
- Widgets se reconstruyen automáticamente

## 🔐 Flujo de Seguridad

```
┌──────────────────────────────────────────────────────┐
│                 Usuario Inicia Sesión                │
└───────────────────────┬──────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────┐
│         Envía credenciales a API (HTTPS)             │
└───────────────────────┬──────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────┐
│    API valida y retorna Access + Refresh Tokens      │
└───────────────────────┬──────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────┐
│      Tokens guardados en Secure Storage (AES)        │
└───────────────────────┬──────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────┐
│  Access Token usado en headers de peticiones API     │
└───────────────────────┬──────────────────────────────┘
                        │
                ┌───────┴───────┐
                │               │
                ▼               ▼
        ┌──────────┐    ┌─────────────┐
        │  Token   │    │   Token     │
        │  Válido  │    │   Expirado  │
        └────┬─────┘    └──────┬──────┘
             │                 │
             │                 ▼
             │     ┌────────────────────┐
             │     │  Refresh Token     │
             │     │  Automático        │
             │     └──────┬─────────────┘
             │            │
             └────────────┴──────────────┐
                                        │
                                        ▼
                              ┌──────────────────┐
                              │  Continuar uso   │
                              │  sin interrupción│
                              └──────────────────┘
```

## 🔄 Ciclo de Vida de una Solicitud

```
1. CREACIÓN (Backend/Huésped)
   │
   ├─→ Solicitud aparece en Dashboard
   │
2. VISUALIZACIÓN (Personal)
   │
   ├─→ Personal ve solicitud en lista
   │
3. ACCIÓN
   │
   ├─→ Personal toca solicitud
   │   │
   │   ├─→ Ve detalles completos
   │   │
   │   └─→ Decide acción:
   │       │
   │       ├─→ Completar
   │       │   │
   │       │   ├─→ Confirma en diálogo
   │       │   │
   │       │   ├─→ Estado → Completada
   │       │   │
   │       │   └─→ Aparece en Historial
   │       │
   │       └─→ Requiere Asistencia
   │           │
   │           └─→ Notifica a supervisor
   │
4. HISTORIAL
   │
   └─→ Registro permanente
       │
       └─→ Estadísticas y reportes
```

## 🎨 Jerarquía de Widgets Principales

```
MaterialApp
└── MultiProvider
    ├── AuthProvider
    └── RequestProvider
        │
        ├── SplashScreen (inicial)
        │   │
        │   ├─→ LoginScreen (no autenticado)
        │   │   └── Login Form
        │   │
        │   └─→ MainScreen (autenticado)
        │       │
        │       ├── BottomNavigationBar
        │       │   ├── Dashboard (Tab 1)
        │       │   ├── Requests List (Tab 2)
        │       │   ├── History (Tab 3)
        │       │   └── Profile (Tab 4)
        │       │
        │       └── FloatingActionButton
        │           └── NFC Unlock Screen
        │
        └── Request Detail Screen
            ├── Guest Info Card
            ├── Request Info Card
            └── Action Buttons
```

## 🔌 Integración con API

### Endpoints Utilizados

```
┌─────────────────────────────────────────────────────┐
│  POST /login                                        │
│  ├── Request: { email, password }                  │
│  └── Response: { accessToken, refreshToken }       │
├─────────────────────────────────────────────────────┤
│  POST /refresh                                      │
│  ├── Request: { refreshToken }                     │
│  └── Response: { accessToken, refreshToken }       │
├─────────────────────────────────────────────────────┤
│  GET /manage/info                                   │
│  ├── Headers: { Authorization: Bearer token }      │
│  └── Response: { email, isEmailConfirmed }         │
└─────────────────────────────────────────────────────┘

Nota: Endpoints de solicitudes pendientes de implementar
en backend. Actualmente usa datos mock.
```

## 📊 Estado de la Aplicación

### AuthProvider State
```dart
{
  user: User?,              // Usuario actual
  isLoading: bool,          // Cargando
  errorMessage: String?,    // Error si existe
  isAuthenticated: bool     // Estado de autenticación
}
```

### RequestProvider State
```dart
{
  requests: List<ServiceRequest>,      // Lista completa
  filteredRequests: List<ServiceRequest>, // Lista filtrada
  isLoading: bool,                     // Cargando
  errorMessage: String?,               // Error si existe
  filterStatus: RequestStatus?,        // Filtro activo
  searchQuery: String,                 // Búsqueda activa
  pendingCount: int,                   // Contador
  completedCount: int,                 // Contador
  inProgressCount: int                 // Contador
}
```

## 🚀 Optimizaciones Implementadas

1. **State Management Eficiente**
   - Solo reconstruye widgets necesarios
   - Consumer widgets específicos

2. **Lazy Loading**
   - ListView.builder para listas largas
   - IndexedStack para tabs

3. **Caché de Autenticación**
   - Tokens en memoria + storage
   - Evita llamadas innecesarias

4. **Animaciones Suaves**
   - Transiciones de 200-300ms
   - Hardware acceleration

5. **Secure Storage**
   - Cifrado AES para tokens
   - Keychain en iOS / Keystore en Android

## 📱 Responsive Design

```
Breakpoints (no implementados aún):
├── Mobile: < 600px
├── Tablet: 600px - 1024px
└── Desktop: > 1024px

Actualmente optimizado para:
└── Mobile Portrait & Landscape
```

## 🧩 Componentes Reutilizables

### RequestCard
```dart
RequestCard({
  required ServiceRequest request,
  VoidCallback? onTap,
})
```
- Muestra información de solicitud
- Código de colores por prioridad
- Tiempo transcurrido
- Badge de estado

### StatsCard
```dart
StatsCard({
  required IconData icon,
  required String title,
  required String count,
  Color? color,
})
```
- Tarjeta de estadística
- Icono + número + título
- Color personalizable

## 🔮 Escalabilidad Futura

### Horizontal (Más Funcionalidades)
- Chat con huéspedes
- Reportes personalizados
- Gestión de inventario
- Asignación de tareas
- Check-in/Check-out

### Vertical (Más Usuarios)
- Caché inteligente
- Sincronización offline
- Compresión de datos
- Optimización de queries
- CDN para assets

### Técnica
- Tests unitarios
- Tests de integración
- CI/CD pipeline
- Monitoring & Analytics
- Error tracking

---

**Esta arquitectura permite:**
✅ Fácil mantenimiento
✅ Testing sencillo
✅ Escalabilidad
✅ Separación de responsabilidades
✅ Reutilización de código

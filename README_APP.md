# SmartStay Personal - App del Personal del Hotel

Aplicación móvil profesional para el personal del hotel que permite gestionar solicitudes de huéspedes y abrir puertas con tecnología NFC.

## 🎨 Características de Diseño

### Identidad Visual Corporativa
- **Color Principal**: Navy Blue (#0A2463 / #001F54)
- **Colores de Estado**:
  - Verde (#10B981): Solicitudes completadas
  - Amarillo (#F59E0B): Solicitudes en proceso
  - Rojo (#EF4444): Solicitudes urgentes/pendientes

### Pantallas Implementadas

1. **Login Screen**
   - Diseño con gradiente Navy Blue
   - Campos de email y contraseña
   - Validación de formularios
   - Integración con API de autenticación

2. **Dashboard Principal**
   - Resumen de solicitudes (pendientes y completadas)
   - Lista de solicitudes activas
   - Navegación rápida a detalles
   - Pull-to-refresh

3. **Lista de Solicitudes**
   - Búsqueda por habitación o huésped
   - Filtros: Todas, Pendientes, En Proceso, Completadas
   - Tarjetas con código de colores por prioridad
   - Indicadores de tiempo transcurrido

4. **Detalle de Solicitud**
   - Información completa del huésped
   - Detalles de la solicitud con notas
   - Botones de acción: Completar / Requiere Asistencia
   - Badges de prioridad

5. **Historial**
   - Selector de fecha con calendario
   - Estadísticas del día
   - Tiempo promedio de respuesta
   - Lista de solicitudes completadas

6. **Perfil del Personal**
   - Información del empleado
   - Estadísticas personales
   - Configuración de notificaciones
   - Cerrar sesión

7. **Pantalla NFC**
   - Interfaz de escaneo NFC animada
   - Instrucciones de uso
   - Feedback visual y auditivo
   - Desbloqueo de puertas

## 🏗️ Arquitectura

### Estructura de Carpetas
```
lib/
├── config/
│   ├── theme.dart           # Tema corporativo
│   └── constants.dart       # Constantes de la app
├── models/
│   ├── user.dart           # Modelo de usuario
│   ├── request.dart        # Modelo de solicitud
│   ├── room.dart           # Modelo de habitación
│   └── auth_response.dart  # Modelo de respuesta de auth
├── services/
│   ├── auth_service.dart   # Servicio de autenticación
│   ├── nfc_service.dart    # Servicio NFC
│   └── request_service.dart # Servicio de solicitudes
├── providers/
│   ├── auth_provider.dart  # State management de auth
│   └── request_provider.dart # State management de requests
├── screens/
│   ├── login_screen.dart
│   ├── main_screen.dart
│   ├── dashboard_screen.dart
│   ├── requests_list_screen.dart
│   ├── request_detail_screen.dart
│   ├── history_screen.dart
│   ├── profile_screen.dart
│   └── nfc_unlock_screen.dart
├── widgets/
│   ├── request_card.dart   # Tarjeta de solicitud
│   └── stats_card.dart     # Tarjeta de estadísticas
└── main.dart
```

## 🔧 Tecnologías Utilizadas

### Dependencias Principales
- **flutter**: Framework principal
- **provider**: State management
- **http**: Cliente HTTP para API calls
- **nfc_manager**: Funcionalidad NFC
- **flutter_secure_storage**: Almacenamiento seguro de tokens
- **intl**: Formateo de fechas e internacionalización
- **shared_preferences**: Preferencias del usuario

### Dependencias UI
- **lucide_icons**: Iconos profesionales
- **shimmer**: Efectos de carga
- **pull_to_refresh**: Pull to refresh en listas
- **fl_chart**: Gráficos y estadísticas

## 🚀 Instalación y Configuración

### Prerrequisitos
- Flutter SDK 3.8.1 o superior
- Android Studio / VS Code con extensiones de Flutter
- Dispositivo Android con NFC (para pruebas de NFC)

### Pasos de Instalación

1. **Clonar el repositorio** (si aplica)
   ```bash
   cd smartstay_personal
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Configurar la API**
   - Editar `lib/config/constants.dart`
   - Actualizar `apiBaseUrl` con la URL de tu servidor de autenticación
   ```dart
   static const String apiBaseUrl = 'http://tu-servidor:8080';
   ```

4. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

### Compilar para Producción

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## 📱 Funcionalidades Principales

### 1. Autenticación
- Login con email y contraseña
- Almacenamiento seguro de tokens (Access Token + Refresh Token)
- Auto-refresh de tokens expirados
- Persistencia de sesión

### 2. Gestión de Solicitudes
- Visualización de solicitudes en tiempo real
- Filtros por estado (Pendientes, En Proceso, Completadas)
- Búsqueda por habitación o nombre de huésped
- Actualización de estado de solicitudes
- Notificaciones de nuevas solicitudes

### 3. NFC para Apertura de Puertas
- Escaneo de tags NFC
- Verificación de autorización
- Desbloqueo de puertas
- Registro de accesos
- Feedback visual y auditivo

### 4. Historial y Estadísticas
- Historial de solicitudes completadas
- Selector de fecha con calendario
- Tiempo promedio de respuesta
- Estadísticas personales del empleado

## 🔐 Seguridad

- **Tokens JWT**: Autenticación basada en JWT
- **Secure Storage**: Almacenamiento cifrado de credenciales
- **HTTPS**: Comunicación segura con la API
- **Validación de NFC**: Verificación de tags autorizados
- **Timeout de sesión**: Cierre automático después de inactividad

## 🎯 API Endpoints Utilizados

La aplicación se integra con los siguientes endpoints de la API de autenticación:

- `POST /login` - Iniciar sesión
- `POST /register` - Registrar nuevo usuario
- `POST /refresh` - Refrescar access token
- `GET /manage/info` - Obtener información del usuario

## 📋 Datos Mock

La aplicación incluye datos de ejemplo para desarrollo:
- 5 solicitudes de muestra
- Diferentes tipos: Toallas, Room Service, Mantenimiento, Limpieza, Amenidades
- Variedad de prioridades y estados

Para producción, reemplazar `RequestService` con llamadas a tu API real.

## 🎨 Personalización

### Cambiar Colores
Editar `lib/config/theme.dart`:
```dart
static const Color navyBlue = Color(0xFF0A2463);
static const Color statusGreen = Color(0xFF10B981);
// etc...
```

### Cambiar Logo
Reemplazar los iconos en:
- `android/app/src/main/res/mipmap-*/ic_launcher.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### Cambiar Nombre de la App
- Android: `android/app/src/main/AndroidManifest.xml`
- iOS: `ios/Runner/Info.plist`

## 🐛 Troubleshooting

### NFC no funciona
- Verificar que el dispositivo tenga hardware NFC
- Activar NFC en configuración del dispositivo
- Verificar permisos en AndroidManifest.xml

### Errores de autenticación
- Verificar que la URL de la API sea correcta
- Comprobar conectividad de red
- Verificar que los tokens no estén expirados

### Problemas de compilación
```bash
flutter clean
flutter pub get
flutter run
```

## 📱 Requisitos del Sistema

### Android
- Android 6.0 (API 23) o superior
- Hardware NFC (opcional pero recomendado)
- 50 MB de espacio libre

### iOS
- iOS 12.0 o superior
- Dispositivos con chip NFC (iPhone 7 o superior)
- 50 MB de espacio libre

## 🔄 Próximas Mejoras

- [ ] Notificaciones push en tiempo real
- [ ] Modo offline con sincronización
- [ ] Chat con huéspedes
- [ ] Escaneo de QR codes
- [ ] Reportes detallados
- [ ] Modo oscuro
- [ ] Múltiples idiomas
- [ ] Integración con sistemas de gestión hotelera

## 👥 Soporte

Para reportar problemas o solicitar nuevas funcionalidades, contactar al equipo de desarrollo.

## 📄 Licencia

Todos los derechos reservados © 2025 SmartStay

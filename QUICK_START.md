# 🚀 Quick Start - SmartStay Personal

## Inicio Rápido en 5 Pasos

### 1️⃣ Instalar Dependencias
```bash
cd smartstay_personal
flutter pub get
```

### 2️⃣ Verificar Dispositivo
```bash
flutter devices
```

### 3️⃣ Ejecutar la App
```bash
flutter run
```

### 4️⃣ Probar Login
- **Email**: `personal@hotel.com` (ajustar según tu API)
- **Password**: `password123` (ajustar según tu API)

### 5️⃣ Explorar Funcionalidades
- 🏠 **Inicio**: Dashboard con resumen
- 📋 **Lista**: Todas las solicitudes con filtros
- ⏱️ **Historial**: Solicitudes completadas
- 👤 **Perfil**: Info del personal
- 📱 **FAB Central**: Abrir puertas con NFC

## ⚙️ Configuración Inicial

### Cambiar URL de API
Editar: `lib/config/constants.dart`
```dart
static const String apiBaseUrl = 'http://TU-SERVIDOR:8080';
```

### Habilitar NFC
1. Activar NFC en el dispositivo Android
2. La app detectará automáticamente la disponibilidad

## 📱 Funcionalidades Principales

### ✅ Gestión de Solicitudes
- Ver todas las solicitudes
- Filtrar por estado
- Buscar por habitación/huésped
- Completar solicitudes
- Ver historial

### 🔓 Apertura de Puertas NFC
- Tap en botón central (FAB)
- Tap "Escanear Puerta"
- Acercar dispositivo a la puerta
- ¡Listo! Puerta desbloqueada

### 👤 Perfil
- Ver estadísticas personales
- Configurar notificaciones
- Cerrar sesión

## 🎨 Tema Corporativo

- **Primary**: Navy Blue (#0A2463)
- **Success**: Green (#10B981)
- **Warning**: Yellow (#F59E0B)
- **Error**: Red (#EF4444)

## 📋 Datos de Prueba Incluidos

La app incluye 5 solicitudes mock para pruebas:
1. Hab. 302 - Toallas (Urgente)
2. Hab. 205 - Room Service (Normal)
3. Hab. 410 - Mantenimiento (Urgente)
4. Hab. 156 - Limpieza (Baja)
5. Hab. 289 - Amenidades (Completada)

## 🔧 Comandos Útiles

### Limpiar proyecto
```bash
flutter clean
flutter pub get
```

### Compilar APK
```bash
flutter build apk --release
```

### Ver logs
```bash
flutter logs
```

### Analizar código
```bash
flutter analyze
```

## ❓ Solución de Problemas Rápidos

### Error de dependencias
```bash
flutter clean
rm -rf pubspec.lock
flutter pub get
```

### NFC no funciona
1. ✅ Verificar que el dispositivo tenga NFC
2. ✅ Activar NFC en configuración
3. ✅ Usar un tag NFC real

### Error de autenticación
1. ✅ Verificar URL de API en `constants.dart`
2. ✅ Verificar conectividad de red
3. ✅ Verificar credenciales

## 📚 Documentación Completa

- **README_APP.md**: Documentación detallada
- **TESTING_GUIDE.md**: Guía de pruebas completa
- **PROJECT_SUMMARY.md**: Resumen del proyecto

## 🎯 Siguiente: ¿Qué probar?

1. ✅ Login y navegación
2. ✅ Ver y filtrar solicitudes
3. ✅ Completar una solicitud
4. ✅ Ver historial
5. ✅ Probar NFC (si tienes dispositivo compatible)
6. ✅ Cerrar sesión

## 💡 Tips

- Usa pull-to-refresh para actualizar datos
- Los filtros se aplican en tiempo real
- La búsqueda funciona en múltiples campos
- El historial muestra tiempo promedio
- Las estadísticas se actualizan automáticamente

## 🚨 Importante

### Antes de Producción
- [ ] Cambiar URL de API
- [ ] Reemplazar datos mock con API real
- [ ] Configurar notificaciones push
- [ ] Agregar analytics
- [ ] Probar en múltiples dispositivos

### Requisitos Mínimos
- Android 6.0+ (API 23+)
- iOS 12.0+
- 50 MB espacio libre
- NFC (para función de puertas)

---

**¿Listo para empezar? Ejecuta `flutter run` 🚀**

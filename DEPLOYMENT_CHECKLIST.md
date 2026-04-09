# ✅ Checklist de Deployment - SmartStay Personal

## 📋 Antes de Ejecutar

### Requisitos del Sistema
- [ ] Flutter SDK 3.8.1+ instalado
- [ ] Dart SDK 3.8.1+ instalado
- [ ] Android Studio o VS Code con extensiones Flutter
- [ ] Dispositivo Android/iOS o emulador configurado
- [ ] Git instalado (opcional)

### Verificación del Entorno
```bash
# Verificar versión de Flutter
flutter --version

# Verificar dispositivos disponibles
flutter devices

# Verificar estado de Flutter
flutter doctor
```

## 🔧 Configuración Inicial

### 1. Dependencias
- [ ] Ejecutar `flutter pub get`
- [ ] Verificar que no haya errores de dependencias
- [ ] Revisar `pubspec.lock` generado

### 2. Configuración de API
- [ ] Abrir `lib/config/constants.dart`
- [ ] Actualizar `apiBaseUrl` con tu servidor
- [ ] Verificar que la URL sea accesible
- [ ] Probar endpoints con Postman/curl

**Ejemplo:**
```dart
static const String apiBaseUrl = 'https://tu-dominio.com';
// o para desarrollo local:
static const String apiBaseUrl = 'http://192.168.1.100:8080';
```

### 3. Permisos Android
- [ ] Verificar `AndroidManifest.xml` tiene permisos de Internet
- [ ] Verificar permisos de NFC si usarás esa función
- [ ] Configurar `minSdkVersion` si es necesario

### 4. Permisos iOS (si aplica)
- [ ] Configurar `Info.plist` para NFC
- [ ] Agregar descripciones de permisos
- [ ] Configurar signing & capabilities

## 🧪 Testing Básico

### Funcionalidad Core
- [ ] La app inicia sin crashes
- [ ] Splash screen aparece correctamente
- [ ] Login screen carga sin errores
- [ ] Puedo hacer login (con datos correctos)
- [ ] Dashboard carga después del login
- [ ] Bottom navigation funciona
- [ ] Pull-to-refresh funciona
- [ ] Puedo ver detalles de solicitudes
- [ ] Puedo cerrar sesión

### UI/UX
- [ ] Colores corporativos están correctos
- [ ] Fuentes se ven bien
- [ ] Iconos cargan correctamente
- [ ] Animaciones son suaves
- [ ] No hay overflow de texto
- [ ] Las imágenes cargan (si las hay)

### NFC (Opcional)
- [ ] Dispositivo tiene hardware NFC
- [ ] NFC está habilitado
- [ ] Pantalla NFC abre correctamente
- [ ] Puede detectar tags NFC
- [ ] Feedback visual funciona

## 🚀 Deployment en Desarrollo

### Android Debug
```bash
# Conectar dispositivo Android o iniciar emulador
flutter devices

# Ejecutar en modo debug
flutter run

# O ejecutar en dispositivo específico
flutter run -d <device-id>
```

### Android Release (APK)
```bash
# Limpiar proyecto
flutter clean
flutter pub get

# Compilar APK de release
flutter build apk --release

# APK estará en: build/app/outputs/flutter-apk/app-release.apk
```

### Android Release (App Bundle)
```bash
# Compilar App Bundle
flutter build appbundle --release

# Bundle estará en: build/app/outputs/bundle/release/app-release.aab
```

### iOS (requiere Mac)
```bash
# Limpiar proyecto
flutter clean
flutter pub get

# Compilar para iOS
flutter build ios --release

# Luego abrir en Xcode para signing y deployment
open ios/Runner.xcworkspace
```

## 🔐 Seguridad Pre-Production

### Verificaciones de Seguridad
- [ ] No hay API keys hardcodeadas
- [ ] URLs de producción están configuradas
- [ ] Secure Storage está implementado
- [ ] HTTPS está forzado en producción
- [ ] No hay console.log/print statements sensibles
- [ ] Validación de inputs está implementada

### Datos Sensibles
- [ ] Tokens se guardan en Secure Storage
- [ ] Passwords no se guardan en plain text
- [ ] No hay credenciales en el código
- [ ] .gitignore incluye archivos sensibles

## 📱 Testing en Dispositivos Reales

### Android
- [ ] Probar en Android 6.0 (mínimo)
- [ ] Probar en Android 10+ (recomendado)
- [ ] Probar en diferentes fabricantes
- [ ] Probar con NFC si está disponible
- [ ] Probar con diferentes tamaños de pantalla

### iOS (si aplica)
- [ ] Probar en iOS 12.0 (mínimo)
- [ ] Probar en iOS 14+ (recomendado)
- [ ] Probar en iPhone y iPad
- [ ] Probar NFC en iPhone 7+

## 🎨 Personalización (Opcional)

### Branding
- [ ] Cambiar nombre de la app
- [ ] Actualizar icono de la app
- [ ] Actualizar splash screen
- [ ] Cambiar colores corporativos si es necesario

### Localización
- [ ] Configurar idiomas soportados
- [ ] Agregar traducciones
- [ ] Probar con diferentes locales

## 📊 Monitoreo y Analytics (Recomendado)

### Pre-Production
- [ ] Configurar Firebase (opcional)
- [ ] Agregar Analytics
- [ ] Configurar Crashlytics
- [ ] Implementar logging estructurado

## 🐛 Troubleshooting Común

### Si la app no compila:
```bash
flutter clean
rm -rf pubspec.lock
rm -rf ios/Podfile.lock
flutter pub get
cd ios && pod install && cd ..
flutter run
```

### Si hay problemas con dependencias:
```bash
flutter pub cache repair
flutter pub get
```

### Si NFC no funciona:
1. Verificar que el dispositivo tenga NFC
2. Activar NFC en configuración del sistema
3. Verificar permisos en AndroidManifest.xml
4. Usar un tag NFC real, no simulado

### Si el login falla:
1. Verificar URL de API
2. Verificar conectividad de red
3. Revisar logs: `flutter logs`
4. Probar API con Postman primero

## 📦 Assets y Recursos

### Verificar que existan:
- [ ] Iconos de la app (Android)
- [ ] Iconos de la app (iOS)
- [ ] Splash screen
- [ ] Assets en pubspec.yaml

## 🔄 CI/CD (Opcional)

### GitHub Actions / GitLab CI
- [ ] Configurar pipeline de testing
- [ ] Configurar pipeline de build
- [ ] Configurar deployment automático
- [ ] Configurar notificaciones

## 📱 Stores (Para Producción)

### Google Play Store
- [ ] Crear cuenta de desarrollador
- [ ] Preparar assets (icono, screenshots, descripción)
- [ ] Configurar signing keys
- [ ] Crear App Bundle signed
- [ ] Subir a Play Console
- [ ] Completar Store Listing
- [ ] Pasar review de Google

### Apple App Store
- [ ] Crear cuenta de Apple Developer
- [ ] Preparar assets
- [ ] Configurar certificates y profiles
- [ ] Crear build signed
- [ ] Subir via Xcode o Transporter
- [ ] Completar App Store Connect
- [ ] Pasar review de Apple

## ✅ Checklist Final Pre-Release

### Funcionalidad
- [ ] Todas las features funcionan correctamente
- [ ] No hay crashes conocidos
- [ ] Performance es aceptable
- [ ] UI/UX es intuitivo
- [ ] Navegación es fluida

### Código
- [ ] Código está limpio y comentado
- [ ] No hay TODOs críticos pendientes
- [ ] Warnings están resueltos
- [ ] Tests están pasando (si los hay)

### Documentación
- [ ] README está actualizado
- [ ] Guías de usuario están completas
- [ ] Documentación técnica está actualizada
- [ ] Changelog está actualizado

### Legal
- [ ] Política de privacidad preparada
- [ ] Términos de servicio preparados
- [ ] Licencias de third-party revisadas
- [ ] Cumplimiento GDPR/regulaciones locales

## 📞 Soporte Post-Deployment

### Monitoreo
- [ ] Configurar alertas de crashes
- [ ] Monitorear analytics
- [ ] Revisar reviews de usuarios
- [ ] Recopilar feedback

### Mantenimiento
- [ ] Plan de actualizaciones
- [ ] Plan de hotfixes
- [ ] Backup de datos
- [ ] Documentación de issues

## 🎯 Métricas de Éxito

### KPIs a Monitorear
- [ ] Tasa de crashes
- [ ] Tiempo de carga
- [ ] Tasa de retención
- [ ] Engagement
- [ ] Reviews/Ratings
- [ ] Tiempo promedio de sesión

---

## 📝 Notas Finales

### Para Desarrollo Local
1. ✅ Ejecutar `flutter pub get`
2. ✅ Configurar URL de API
3. ✅ Ejecutar `flutter run`
4. ✅ Probar funcionalidades básicas

### Para Testing
1. ✅ Seguir `TESTING_GUIDE.md`
2. ✅ Documentar bugs encontrados
3. ✅ Verificar todas las features

### Para Producción
1. ✅ Completar todos los checkboxes arriba
2. ✅ Hacer testing exhaustivo
3. ✅ Preparar rollback plan
4. ✅ Deployment gradual recomendado

---

**¿Todo listo? ¡Es hora de deployar! 🚀**

Para cualquier problema, consulta:
- `README_APP.md` - Documentación completa
- `TESTING_GUIDE.md` - Guía de pruebas
- `QUICK_START.md` - Inicio rápido
- `ARCHITECTURE.md` - Arquitectura técnica

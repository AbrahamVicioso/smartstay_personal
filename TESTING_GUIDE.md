# Guía de Pruebas - SmartStay Personal

## 🧪 Instrucciones para Probar la Aplicación

### Paso 1: Preparación del Entorno

1. **Instalar dependencias**:
   ```bash
   flutter pub get
   ```

2. **Verificar dispositivos conectados**:
   ```bash
   flutter devices
   ```

3. **Ejecutar la aplicación**:
   ```bash
   flutter run
   ```

### Paso 2: Pruebas de Autenticación

#### Login Screen
**Credenciales de prueba** (ajustar según tu API):
- Email: `personal@hotel.com`
- Password: `password123`

**Casos de prueba**:
1. ✅ Login exitoso con credenciales válidas
2. ❌ Login fallido con credenciales inválidas
3. ❌ Validación de email (formato inválido)
4. ❌ Validación de contraseña (mínimo 6 caracteres)
5. 👁️ Toggle de visibilidad de contraseña
6. 🔄 Indicador de carga durante login

**Resultados esperados**:
- Login exitoso → Navega a Dashboard
- Login fallido → Muestra SnackBar con error
- Validación → Muestra mensajes de error en los campos

### Paso 3: Pruebas del Dashboard

#### Visualización de Datos
1. **Tarjetas de estadísticas**:
   - Contador de solicitudes pendientes
   - Contador de solicitudes completadas

2. **Lista de solicitudes activas**:
   - Tarjetas con borde de color según prioridad
   - Información de habitación y huésped
   - Tiempo transcurrido actualizado
   - Badges de estado

**Acciones a probar**:
- 🔄 Pull to refresh para actualizar datos
- 👆 Tap en tarjeta para ver detalles
- 📊 Verificar que los contadores sean correctos

### Paso 4: Pruebas de Lista de Solicitudes

#### Búsqueda y Filtros
1. **Búsqueda**:
   - Buscar por número de habitación (ej: "302")
   - Buscar por nombre de huésped (ej: "Carlos")
   - Buscar por descripción (ej: "Toallas")

2. **Filtros**:
   - Todas las solicitudes
   - Solo pendientes
   - Solo en proceso
   - Solo completadas

**Casos de prueba**:
```
Búsqueda: "302"
Resultado esperado: Mostrar habitación 302

Filtro: "Pendientes"
Resultado esperado: Mostrar solo solicitudes con estado pendiente

Búsqueda: "xyz123"
Resultado esperado: "No se encontraron solicitudes"
```

### Paso 5: Pruebas de Detalle de Solicitud

#### Información Mostrada
- ✅ Nombre del huésped
- ✅ Número de habitación
- ✅ Fecha de solicitud
- ✅ Tipo de solicitud con icono
- ✅ Prioridad con badge de color
- ✅ Descripción y notas
- ✅ Hora de solicitud

#### Acciones Disponibles
1. **Marcar como completada**:
   - Tap en "MARCAR COMO COMPLETADA"
   - Confirmar en diálogo
   - Verificar SnackBar de éxito
   - Verificar que regresa al dashboard
   - Verificar que la solicitud aparece en historial

2. **Requiere asistencia**:
   - Tap en "REQUIERE ASISTENCIA"
   - Verificar SnackBar de confirmación

### Paso 6: Pruebas de Historial

#### Selector de Fecha
1. **Navegación por fechas**:
   - Tap flecha izquierda → día anterior
   - Tap flecha derecha → día siguiente
   - Tap icono calendario → selector de fecha

2. **Visualización**:
   - Estadísticas del día seleccionado
   - Total de solicitudes
   - Tiempo promedio de respuesta
   - Lista de solicitudes completadas

**Casos de prueba**:
```
Seleccionar: Hoy
Resultado: Mostrar solicitudes de hoy

Seleccionar: Fecha sin solicitudes
Resultado: "No hay solicitudes completadas"
```

### Paso 7: Pruebas de Perfil

#### Información del Usuario
- Avatar o icono de perfil
- Nombre del empleado
- Email
- Departamento

#### Estadísticas Personales
- Solicitudes pendientes
- Solicitudes en proceso
- Solicitudes completadas

#### Opciones de Configuración
1. **Notificaciones** (placeholder)
2. **Configuración NFC** (placeholder)
3. **Idioma** (placeholder)
4. **Acerca de**: Muestra diálogo con versión

#### Cerrar Sesión
1. Tap "Cerrar Sesión"
2. Confirmar en diálogo
3. Verificar navegación a Login
4. Verificar que tokens se eliminaron

### Paso 8: Pruebas de NFC

**⚠️ Requiere dispositivo Android con NFC habilitado**

#### Preparación
1. Verificar que NFC esté habilitado en el dispositivo
2. Tener un tag NFC disponible para pruebas

#### Flujo de Prueba
1. **Acceder a pantalla NFC**:
   - Tap en botón flotante (FAB) en el centro del bottom bar
   - Verificar animación circular
   - Verificar mensaje de estado

2. **Escanear tag NFC**:
   - Tap "Escanear Puerta"
   - Acercar dispositivo a tag NFC
   - Verificar feedback visual (animación)
   - Verificar SnackBar de resultado

3. **Cancelar escaneo**:
   - Tap "Escanear Puerta"
   - Tap "Cancelar" antes de escanear
   - Verificar mensaje de cancelación

**Casos de prueba**:
```
Escenario: NFC disponible
Resultado: Botón "Escanear Puerta" habilitado

Escenario: NFC no disponible
Resultado: Mensaje "NFC no está disponible"

Escenario: Tag NFC válido
Resultado: SnackBar verde "Puerta desbloqueada"

Escenario: Error al leer tag
Resultado: SnackBar rojo con mensaje de error
```

### Paso 9: Pruebas de Navegación

#### Bottom Navigation Bar
1. **Navegación entre pantallas**:
   - Tap "Inicio" → Dashboard
   - Tap "Lista" → Lista de solicitudes
   - Tap "Historial" → Historial
   - Tap "Perfil" → Perfil

2. **Indicador visual**:
   - Icono activo: Color blanco sólido
   - Icono inactivo: Color blanco 54% opacidad
   - Texto activo: Peso bold

3. **FAB (Floating Action Button)**:
   - Posicionado en el centro
   - Icono NFC
   - Abre pantalla de NFC al hacer tap

### Paso 10: Pruebas de UI/UX

#### Tema y Colores
- Navy Blue (#0A2463) en headers
- Colores de estado correctos:
  - Rojo para urgente/pendiente
  - Amarillo para normal/en proceso
  - Verde para baja/completado

#### Animaciones
- Pull to refresh con indicador
- Transiciones suaves entre pantallas
- Animación circular en pantalla NFC
- Ripple effect en botones

#### Responsive
- Probar en diferentes tamaños de pantalla
- Verificar que el texto no se corte
- Verificar scroll en contenido largo

### Paso 11: Pruebas de Conectividad

#### Escenarios de Red
1. **Conexión normal**:
   - Login exitoso
   - Datos se cargan correctamente

2. **Sin conexión**:
   - Login falla con mensaje de error
   - Mostrar mensaje apropiado

3. **Conexión lenta**:
   - Mostrar indicadores de carga
   - No bloquear UI

### Paso 12: Pruebas de Estado

#### Persistencia
1. **Cerrar y reabrir app**:
   - Si hay sesión activa → Dashboard
   - Si no hay sesión → Login

2. **Token refresh**:
   - Verificar que tokens se refrescan automáticamente
   - Sin interrupción para el usuario

## 📊 Checklist de Pruebas

### Funcionalidad Core
- [ ] Login con credenciales válidas
- [ ] Login con credenciales inválidas
- [ ] Logout y limpieza de sesión
- [ ] Visualización de solicitudes
- [ ] Filtrado de solicitudes
- [ ] Búsqueda de solicitudes
- [ ] Ver detalle de solicitud
- [ ] Completar solicitud
- [ ] Ver historial
- [ ] Ver perfil

### NFC
- [ ] Detectar disponibilidad de NFC
- [ ] Escanear tag NFC
- [ ] Cancelar escaneo
- [ ] Manejar errores de lectura

### UI/UX
- [ ] Colores corporativos aplicados
- [ ] Animaciones funcionando
- [ ] Pull to refresh
- [ ] Bottom navigation
- [ ] Indicadores de carga
- [ ] SnackBars de feedback

### Navegación
- [ ] Login → Dashboard
- [ ] Dashboard → Detalle
- [ ] Navegación bottom bar
- [ ] FAB → Pantalla NFC
- [ ] Logout → Login

## 🐛 Bugs Conocidos y Limitaciones

### Datos Mock
- Los datos de solicitudes son mock (no persistentes)
- Refresh devuelve los mismos datos
- No hay sincronización con backend real

### NFC
- Solo funciona en dispositivos Android con NFC
- iOS requiere configuración adicional
- Tags NFC deben estar formateados correctamente

### Notificaciones
- Notificaciones push no implementadas
- Iconos de notificación son placeholders

## 📝 Notas para Desarrollo

### Próximas Implementaciones
1. Conectar con API real de solicitudes
2. Implementar notificaciones push
3. Agregar sincronización offline
4. Implementar chat con huéspedes
5. Agregar más idiomas

### Optimizaciones Pendientes
- Caché de imágenes
- Lazy loading en listas largas
- Optimización de rendimiento
- Tests unitarios y de integración

## 🎓 Mejores Prácticas

### Para Testers
1. Probar en dispositivos reales, no solo emuladores
2. Probar con diferentes versiones de Android
3. Verificar rendimiento con datos reales
4. Documentar todos los bugs encontrados

### Para Desarrolladores
1. Reemplazar servicios mock con APIs reales
2. Agregar manejo de errores robusto
3. Implementar analytics
4. Agregar crashlytics
5. Optimizar para producción

## 📞 Contacto

Para reportar bugs o solicitar nuevas funcionalidades durante las pruebas, contactar al equipo de desarrollo.

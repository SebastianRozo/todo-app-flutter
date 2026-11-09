# To-Do App (Flutter)

Aplicación móvil de lista de tareas hecha con Flutter (Material 3).

## Funcionalidades
- Agregar, editar y eliminar tareas (deslizar a la izquierda para borrar, con "Deshacer").
- Marcar tareas como completadas.
- Filtros: Todas / Pendientes / Hechas, con contador de pendientes.
- Borrar todas las completadas de una vez.
- Las tareas se guardan en el dispositivo (`shared_preferences`), no se pierden al cerrar la app.
- Tema claro/oscuro automático.

## Ejecutar
```bash
flutter pub get
flutter run          # en emulador/dispositivo Android o iOS
flutter run -d chrome  # versión web
flutter test         # pruebas
```

## Estructura
- `lib/main.dart` — toda la app: modelo `Task`, pantalla `TodoPage` y persistencia.
- `test/widget_test.dart` — prueba de serialización y prueba de flujo completo.

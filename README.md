🧊 Frontend – App de Repartos (Sodería)

Frontend de la App de Repartos para Sodería, desarrollado en Flutter, orientado a la gestión diaria de clientes, visitas, ventas, pagos, stock, combos y reportes.

Este proyecto consume un backend propio (FastAPI) y está pensado para uso interno de repartidores y administración.

🚀 Tecnologías

Flutter (Material 3)

Dart

HTTP / REST

Intl (fechas y formatos)

Flutter Dotenv (variables de entorno)

Arquitectura por screens + services + models

📱 Funcionalidades principales

🔐 Login y autenticación

🏠 Home / Dashboard

📆 Calendario de repartos

👥 Gestión de clientes

Alta / edición

Días de visita y turnos

Cuenta corriente

🛒 Ventas

Productos

Combos

Listas de precios

💰 Pagos

Medios de pago

Registro en caja

📦 Stock

Ajustes manuales

Movimientos

📊 Reportes

Repartos por rango de fechas

Totales y estados de visita

🧱 Estructura del proyecto
lib/
├── core/
│   ├── colors.dart
│   ├── enums/
│   ├── navigation/
│   └── theme.dart
│
├── models/
│   ├── cliente.dart
│   ├── producto.dart
│   ├── combo.dart
│   └── stock.dart
│
├── services/
│   ├── auth_service.dart
│   ├── cliente_service.dart
│   ├── producto_service.dart
│   ├── venta_service.dart
│   └── stock_service.dart
│
├── screens/
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── calendario_screen.dart
│   ├── venta_screen.dart
│   ├── pago_screen.dart
│   ├── reportes/
│   └── clientes/
│
└── main.dart

⚙️ Configuración del entorno
1️⃣ Variables de entorno

Crear un archivo .env en la raíz del proyecto:

API_BASE_URL=http://localhost:8000


⚠️ No subir el archivo .env al repositorio.

2️⃣ Dependencias
flutter pub get

3️⃣ Ejecutar la app
flutter run


O seleccionar el dispositivo desde tu IDE (Android / Web / Desktop).

🔌 Backend

Este frontend depende del backend del proyecto:

FastAPI

Endpoints REST (clientes, productos, combos, ventas, stock, reportes)

👉 Asegurate de tener el backend corriendo antes de usar la app.

🎨 UI / UX

Material Design

Colores y estados derivados del negocio

Feedback visual para:

Cargando

Errores

Estados de visita

Navegación centralizada con AppShell

🧠 Convenciones importantes

La UI deriva siempre del estado, no de flags sueltos

Los services no manejan UI

Los screens no hacen lógica de negocio

Manejo defensivo de mounted en async

Refresh explícito después de operaciones críticas (venta, pago, stock)

🛠️ Estado del proyecto

🟡 En desarrollo activo
✔️ Uso interno
✔️ Funcional para operación diaria
🔧 En mejora continua

✍️ Autor

Emmanuel Quintana Fattor
Frontend Flutter / App de Repartos – Sodería San Miguel

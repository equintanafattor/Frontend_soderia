# 🧊 Frontend – App de Repartos (Sodería)

Frontend de la **App de Repartos para Sodería**, desarrollado en **Flutter**, orientado a la gestión diaria de clientes, visitas, ventas, pagos, stock, combos y reportes.

Este proyecto consume un backend propio (FastAPI) y está pensado para uso interno de repartidores y administración.

---

## 🚀 Tecnologías

- **Flutter** (Material 3)
- **Dart**
- **HTTP / REST**
- **Intl** (fechas y formatos)
- **Flutter Dotenv** (variables de entorno)
- Arquitectura por **screens + services + models**

---

## 📱 Funcionalidades principales

- 🔐 **Login y autenticación**
- 🏠 **Home / Dashboard**
- 📆 **Calendario de repartos**
- 👥 **Gestión de clientes**
  - Alta / edición
  - Días de visita y turnos
  - Cuenta corriente
- 🛒 **Ventas**
  - Productos
  - Combos
  - Listas de precios
- 💰 **Pagos**
  - Medios de pago
  - Registro en caja
- 📦 **Stock**
  - Ajustes manuales
  - Movimientos
- 📊 **Reportes**
  - Repartos por rango de fechas
  - Totales y estados de visita

---

## 🧱 Estructura del proyecto

```text
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
```

## **Configuración del entorno**

### Variables de entorno

Crear un archivo `.env` en la raíz del proyecto:

```env
API_BASE_URL=http://localhost:8000
```
No subir el archivo .env al repositorio.


## Instalación de dependencias

```
flutter pub get
```

## Ejecución de la aplicación

```
flutter run
```

O seleccionar el dispositivo desde el IDE.

---

## **Backend**

Este frontend depende de un backend desarrollado en FastAPI que expone endpoints REST para:

- Clientes
- Productos
- Combos
- Ventas
- Stock
- Reportes

El backend debe estar en ejecución para el correcto funcionamiento de la aplicación.

---

## **UI y UX**

- Material Design
- Estados visuales derivados del negocio
- Manejo de estados de carga y error
- Navegación centralizada mediante AppShell

---

## **Convenciones de desarrollo**

- La interfaz de usuario deriva del estado
- Los services no manejan lógica de UI
- Las screens no contienen lógica de negocio
- Uso defensivo de mounted en operaciones asincrónicas
- Refresco explícito luego de operaciones críticas (venta, pago, stock)

---

## **Estado del proyecto**

- En desarrollo activo.
- Uso interno.
- Funcional para operación diaria.
- En mejora continua.

---

## **Autor**

Emmanuel Quintana Fattor
App de Repartos - Sodería San Miguel



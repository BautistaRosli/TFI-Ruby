# TFI-Ruby - Sistema de Gestión de Discos

Sistema web para la gestión de ventas de discos musicales (nuevos y usados) desarrollado con Ruby on Rails.

---

## Tabla de Contenidos

- [Dependencias Necesarias](#dependencias-necesarias)
- [Instalación](#instalación)
- [Configuración Inicial](#configuración-inicial)
- [Usuarios de Prueba](#usuarios-de-prueba)
- [Clientes Predefinidos](#clientes-predefinidos)
- [Solución de Problemas](#solución-de-problemas)
- [Arquitectura del Sistema](#arquitectura-del-sistema)
- [Módulo de Ventas](#modulo-de-ventas)
  - [Flujo de Creación](#flujo-de-creación-de-una-venta)
  - [Componentes Principales](#componentes-principales)
  - [Sistema de Filtros](#sistema-de-filtros)
  - [Borrado Lógico](#borrado-lógico)
  - [Notas Técnicas](#notas)

---

## Dependencias Necesarias

| Componente | Versión |
|------------|---------|
| **Ruby** | 3.4.0 |
| **Rails** | 8.0.0 |
| **Bundler** | Última versión estable |
| **Base de Datos** | SQLite3 (archivo local en `storage/`) |

---

## Instalación

Pasos después de clonar el repositorio:

```bash
# 1. Instalar dependencias
bundle install

# 2. Crear y migrar la base de datos
rails db:create db:migrate

# 3. Cargar datos de prueba
rails db:seed

# 4. Configurar WickedPDF para generación de PDFs
rails generate wicked_pdf
# o :
rails g wicked_pdf

# 5. Iniciar el servidor
rails server
```

Se puede acceder entrando en `http://localhost:3000`

---

## Configuración Inicial

### Generación de PDFs

El sistema utiliza **WickedPDF** para generar comprobantes de venta en formato PDF. El comando `rails generate wicked_pdf` crea automáticamente los archivos de configuración e inicialización necesarios.

---

##  Usuarios de Prueba

El sistema incluye usuarios predefinidos para testing con diferentes roles:

###  Administrador

| Email | Contraseña |
|-------|------------|
| `admin@example.com` | `123456` |

###  Empleados (10 usuarios)

| Email | Contraseña |
|-------|------------|
| `empleado1@example.com` - `empleado10@example.com` | `123456` |

**Formato**: `empleadoN@example.com` N es un número del 1 al 10

###  Gerentes (10 usuarios)

| Email | Contraseña |
|-------|------------|
| `gerente1@example.com` - `gerente10@example.com` | `123456` |

**Formato**: `gerenteN@example.com`  N es un número del 1 al 10

---

##  Clientes Predefinidos

- **Total de clientes**: 20 clientes cargados en el sistema
- **Cliente Anónimo**: Disponible para ventas sin datos del cliente
  - **Tipo de documento**: DNI
  - **Número de documento**: 0

---

## Solución de Problemas

### Errores con SQLite3

Si se rompe SQLite al instalar o ejecutar la gema `sqlite3`, se pueden ejecutar los siguientes comandos:

```bash
# Desinstalar la gema actual
gem uninstall sqlite3

# Forzar compilación desde código fuente
bundle config set force_ruby_platform true

# Reinstalar dependencias
bundle install
```

Esto compilará la gema `sqlite3` directamente desde el código fuente, evitando conflictos de plataforma.

---

## Notas

- Los datos de prueba se cargan automáticamente con `rails db:seed`

---

## Arquitectura del Sistema

El sistema está construido siguiendo el patrón **MVC (Model-View-Controller)** de Rails con las siguientes características arquitectónicas:

- **Concerns**: Módulos compartidos que encapsulan lógica reutilizable
  - `CartManagement`: Gestión del carrito de compras en sesión
  - Otros concerns para funcionalidades transversales

- **Callbacks**: Automatización de procesos en modelos
  - Gestión automática de stock al crear/eliminar ventas
  - Validaciones previas a operaciones críticas

### Tecnologías y Gemas Principales

- **Active Storage**: Gestión de imágenes de portadas de discos
- **Devise**: Sistema de autenticación de usuarios
- **CanCanCan**: Autorización basada en roles (admin, gerente, empleado)
- **Kaminari**: Paginación de listados
- **WickedPDF**: Generación de comprobantes en formato PDF
- **Bootstrap 5**: Framework CSS para interfaz responsive

### Módulos del Sistema

#### Módulo de Usuarios
- Gestión de empleados, gerentes y administradores
- Sistema de roles con permisos diferenciados
- Autenticación con Devise

#### Modulo de estadisticas y gráficos


#### Módulo de Discos
- Catálogo de discos nuevos y usados
- Gestión de stock diferenciado por tipo
- Carga de imágenes de portada con Active Storage
- Atributos: artista, álbum, género, año, precio


### Módulo de Frontsore
- Interfaz para que los clientes visualicen el catálogo
- Búsqueda y filtrado de discos
- Recomendaciones por similaridad al ver el detalle de un disco 



## Modulo de Ventas

### Descripción General

El módulo de ventas permite gestionar el proceso completo de venta de discos, desde la selección de productos hasta la generación del comprobante. Incluye gestión de carrito, validación de stock, y generación de PDFs.

---

###  Flujo de de creación de una venta

1. **Selección de Productos**
   - Al tocar el botón "Nueva Venta", redirige al listado de discos, que muestra todos los discos con su stock disponible e inicializa un carrito vacío en sesión.
   - Se puede seleccionar la cantidad vendida de cada disco y agregarlo al carrito.
   - Cada vez que se agrega un disco, se valida que haya stock suficiente. 
   - Si hay stock, se agrega al carrito.

2. **Gestión del Carrito**
   - Si se apreta el botón "Ver Carrito", se muestra el contenido del carrito con los discos agregados y las unidades seleccionadas.
   - Pueden eliminarse items del carrito, actualizando el monto total automáticamente.
   - El monto se recalcula cada vez que se agrega o elimina un item

3. **Confirmación de Venta**
   - Una vez que se selecciona el confirmar venta, se solicita completar los datos del cliente.
   - Si el cliente no existe, se crea uno nuevo, sino se utiliza el existente, el cual se puede buscar por DNI o email.
   - A la hora de guardar la venta, se valida nuevamente el stock de cada disco y, si es correcto, se pasa a:
     - Disminuir el stock de los discos vendidos, mediante callbacks en el modelo.
     - Guardar la venta en la base de datos.

4. **Comprobante**
   - Al confirmar la venta, se redirige a la vista de detalle de la venta donde se muestra un resumen de la misma.
   - Desde ahí, se puede descargar el comprobante en formato PDF.
   - El PDF incluye:
     - Información de la venta (ID, fecha, empleado que registra la venta)
     - Datos del cliente (DNI, email)
---

### Componentes Principales

#### Modelos

- **`Sale`**: Representa una venta completa
  - Relaciones: `belongs_to :user`, `belongs_to :customer`, `has_many :items`
  - Scopes: Filtrado por fecha, monto, usuario, cliente, estado
  - **Explicación de relaciones:**
    - **`User`**: Usuario que registra la venta
    - **`Customer`**: Cliente asociado a la venta
    - **`Item`**: Discos vendidos en la venta, con cantidad y precio unitario

- **`Item`**: Representa un producto dentro de una venta
  - Relaciones: `belongs_to :sale`, `belongs_to :disk`
  - Atributos: `quantity`, `unit_price`, `subtotal`
  - **Explicación de relaciones:**
    - **`Disk`**: Disco vendido (NewDisk o UsedDisk)
    - **`Sale`**: Venta a la que pertenece el item


#### Concerns

- **`CartManagement`**: Manejo de carrito en sesión
  - Métodos: `add_to_cart`, `remove_from_cart`, `cart_items`, `cart_total`, `clear_cart`
  - Storage: Sesión del navegador
  - Contiene lógica para agregar, eliminar y calcular totales del carrito, esas funciones son utilizadas en el controlador de ventas.

#### Sistema de Filtros

- **Filtros disponibles**:
  - ID de venta
  - Usuario vendedor
  - Cliente
  - Rango de fechas (desde/hasta)
  - Monto mínimo/máximo
  - Ventas eliminadas (checkbox)

#### Borrado Lógico

- Las ventas no se eliminan físicamente
- Campo `deleted` marca ventas anuladas
- Callback automático: devuelve stock de los discos al borrar la venta
- Filtro opcional para mostrar ventas eliminadas

### Notas 

- **Manejo de stock**: Callbacks automáticos en `before_create` y `after_update`
   - `validate_and_decrease_stock`: valida y disminuye stock antes de crear la venta.
   - `return_stock`: devuelve stock si la venta es eliminada. Utiliza una validación de active storage (`saved_change_to_deleted`) para asegurar que solo se devuelva stock si la venta estaba activa y se marca como eliminada en el update actual.

- **Session Storage**: Carrito persiste solo durante la sesión activa
   - Al empezar una nueva venta, se inicializa un carrito vacío en la sesión con la siguiente estructura:
   
   ```ruby
   session["cart"] ||= { "items" => [], "total_amount" => 0 }
   ```
   
   - Es un hash con un array de items (`items`) y el monto total (`total_amount`)
   - Al confirmar la venta, se limpia automáticamente el carrito de la sesión

---

## Licencia

Este proyecto fue desarrollado como Trabajo Final Integrador.

---

**Desarrollado con Ruby on Rails**  
Versión 1.0.0 | Última actualización: Diciembre 2025


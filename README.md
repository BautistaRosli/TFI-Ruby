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
- [Módulo de Usuarios](#modulo-de-usuarios)
  - [Flujo de Creación](#flujo-de-creación/edición-de-un-usuario)
  - [Componentes Principales](#componentes-principales-de-usuario)
  - [Manejo de sesiones](#manejo-de-sesiones)
- [Módulo de Estadísticas y Gráficos](#modulo-de-estadísticas-y-gráficos)
  - [Flujo de Gráficos](#flujo-de-gráficos)
- [Módulo de Ventas](#modulo-de-ventas)
  - [Flujo de Creación](#flujo-de-creación-de-una-venta)
  - [Componentes Principales](#componentes-principales)
  - [Sistema de Filtros](#sistema-de-filtros)
  - [Borrado Lógico](#borrado-lógico)
  - [Notas Técnicas](#notas)
- [Ruteo](#ruteo)
  - [Flujo de Ruteo](#flujo-de-ruteo)

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

# Módulos del Sistema

## Módulo de Usuarios

### Descripción General

El módulo de usuarios permite gestionar la visualización, creación, edición y borrado lógico de usuarios. Entendiendo a un usuario como Empleado, Manager y Administrador, estos con sus respectivos permisos.

---

###  Flujo de creación/edición de un usuarios
1. **Seleccionar acción**
   - En caso de creación al ser un administrador o manager se presentará al final del listado de usuarios un botón para crear un usuario.
   - En caso de la edición se podrá a esta vista si se selecciona un usuario ajeno (si se tiene permiso) o al detalle de uno mismo.

2. **Rellenar el formulario**
   - En caso de creación se solicitara llenar todos los campos solicitados incluyendo entre estos email y contraseña.
   - En caso de edición los campos se rellenan automaticamente, luego de editar al usuario se podrá guardar los cambios.
   - Como administrador se presentar la opción de cambiar contraseña de los demás usuarios, funciona igual que la edición.
3. **Envío del formulario**
   - En cualquier caso se validan todos los datos ingresado en el formulario para que cumpla las restricciones del modelo.
   - En caso de fallar alguna validación no se realiza la acción y se indica el problema.
---

### Componentes Principales de usuario
 
#### Modelos

- **`Ability`**: Representa los permisos de la entidad User, se maneja mediante la gema CanCanCan
  - Los administradores pueden realizar cualquier acción.
  - Los manager pueden:
    - Ver el listado de usuarios habilitados.
    - Ver detalles de usuarios con rol de empleado.
    - Editar usuarios de rol de empleado.
    - Editar su propio perfil.
    - Crear usuarios de rol empleado.
    - Ver la sección de graficos.
  - Los empleados pueden:
    - Ver el listado de usuarios habilitados.
    - Editar su propio perfil.

- **`User`**: Representa a un usuario.
  - Relaciones: `has_many :sales`
  - Scopes: Filtrado por nombre, apellido, email y rol. Obtener las ventas que el realizó.
  - Rol: Se maneja mediante enum.
  - Devise: La entidad incluye modulos de devise, entre ellos
    - `database_authenticatable`: Permite guardar la contraseña hasheada y validar al usuario para iniciar sesión
    - `timeoutable`: Permite mantener un tiempo limitado de sesión para las sesiones de los usuarios.
    - `validatable`: Incluye validaciones basicas como formatos de email o contraseñas.

#### Manejo de sesiones
  Para esto nos apoyamos en la gema Devise. Su uso se aprecia principalmente en 2 controladores:
  - **`admin/auth/session_controller`**
    - Se hereda del controlador que brinda Devise `Auth::SessionsController < Devise::SessionsController`
    - Se extienden metodos heredados para agregar funcionalidad y personalización.
  - **`application_controller`**
    - Se redefine `after_sign_in_path_for`, `after_sign_out_path_for` y `authenticate_user!`. Métodos que utiliza devise para el manejo del log-in, log-out y el chequeo de estar validado para acceder a recursos.



## Modulo de estadisticas y gráficos

### Descripción General

El módulo de gráficos permite visualizar información respecto a las ventas del sistema.

---

###  Flujo de los gráficos
1. **Seleccionar acción**
   - En caso de ser un administrador o manager tanto en el layout de ventas como de discos esta la el botón de `Ver analisís de ventas`

2. **Manejo en vista**
   - Se presentara una vista con todos gráficos generales presentes hasta la fecha
   - En la parte superior se presentar la opción de que tipo de reportes consultar

3. **Gráficos personalizados (Reportes)**
   - Se pueden realizar 3 tipos de reportes, Empleado, Cliente y Género Musical.
   - Cada tipo de reporte pide un dato para mostrar gráficos especificos de esa entidad dentro del tipo seleccionado.
   - En caso de no encontrar el dato se muestra los gráficos generales nuevamente.

---

### Notas de graficos

- **Un solo controlador**: Se optó por utilizar un solo controlador ya que técnicamente todo es una misma vista solo que se brinda la opcion de realizar una especie de filtro.
- **Manejo de permisos**: Para que este controlador se visto para que se le manejen permisos se tuvo que incluir `authorize_resource :admin_graphic, class: false` ya que este controlador no maneja un modelo de Active Record.


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

## Ruteo

El archivo principal de este modulo es `routes.rb`. Aquí configuramos los recursos de nuestro sistema y sus rutas.
En este archivo se realizan configuraciones clave como:
- `devise_for :users...`: Se le asigna a devise el recurso de user para que maneje las sesiones con esta entidad y se le indica que controladores usar.
- `namespace :admin do`: Se define un namespace `admin` para que sea la base de las rutas de los modulos privados.
- `root to: "disk/new#index"`: Se define una landing page de la aplicación.
- `match "*path", to: "application#routing_error", via: :all,`: Se define una acción en caso de que la ruta ruta buscado por un usuario de la aplicación no coincida con ninguna, delegando la accion a la funcion routing_error del controlador application_controller.

Se configuro también en el archivo `ApplicationController` el cual es la base de todos nuestros controladores manejadores de excepciones y decisiones de ruteo. Una importante decision de ruteo se encuentra dentro del metodo `authenticate_user!` luego de la clausula `unless user_signed_in?`, en esta sección se ocultan rutas a usuarios no autenticados.

---

### Flujo de ruteo

1. **Inicio de la aplicacíon**
   - Una vez dentro de la aplicación nuestra landing page es `disk/new#index`
2. **Acceso a sección administrativa**
   - Se le agruega al navegador el path `/admin` o `/admin/login`.
   - Si no estas logeado `/admin` te redirige a `/admin/login` indicando que se requiere estar logeado.
   - En caso de no estar logeado y queres ir a cualquier seccion de qute contengas el prefijo `/admin` que no sean las mencionadas anteriormente
   se nos denegara el acceso exista o no la ruta, indicando el mismo mensaje ya sea una ruta existente o no.
3. **Acceso a sección restringida**
   - En caso de no estar logeados e intentar ingresar a una seccion con permisos la clausula de `before_action :authenticate_user`
   no nos permitira el ingreso.
   - En caso de estar logeados e intentar ingresar a una seccion con permisos el manejador de la excepcion `CanCan::AccessDenied` no nos permitira al ingreso y nos indicara la falta de permisos.
4. **Acceso a recursos inexistent**
   - En caso de estar logeado si queremos acceder a un recurso inexistente como `/admin/users/1132` el manejador de la excepcion `ActiveRecord::RecordNotFound` no nos permitira al ingreso y nos indicara la inexistencia del recurso. 




## Licencia

Este proyecto fue desarrollado como Trabajo Final Integrador.

---

**Desarrollado con Ruby on Rails**  
Versión 1.0.0 | Última actualización: Diciembre 2025


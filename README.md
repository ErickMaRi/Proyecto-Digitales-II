### Receptor de Transacciones MDIO 📡🔄💾

## Descripción del Proyecto 📝

Este proyecto abarca el diseño e implementación de un receptor de transacciones MDIO (Management Data Input/Output), conformándose a la cláusula 22 del estándar IEEE 802.3. El receptor es crucial para interpretar y procesar transacciones MDIO, esenciales en la gestión y configuración de dispositivos de red Ethernet.

## Estructura del Proyecto 🗂️

```
.
├── MDIO
│   ├── controller
│   │   ├── controller_tb.v
│   │   └── controller.v
│   ├── Makefile
│   ├── MDIO_tb.v
│   └── peripheral
│       ├── peripheral_tb.v
│       └── peripheral.v
├── Parte 1 Proyecto Final.pdf
├── Parte 2 Proyecto Final.pdf
└── README.md
```

### Detalles del Controlador y Periférico MDIO ⚙️

#### Protocolo MDIO 🔄
- **Formato de Transacción:** Serial de 32 bits.
- **Estructura de Transacción:**

| Bit(s) | Campo             | Descripción                                                                 |
|--------|-------------------|-----------------------------------------------------------------------------|
| 31-30  | ST (Start)        | Código de inicio de trama (01 para Clause 22)                               |
| 29-28  | Op Code           | 10: Lectura, 01: Escritura                                                  |
| 27-23  | PHY Address       | Dirección del dispositivo PHY                                               |
| 22-18  | Reg Address       | Dirección del registro a leer o escribir en el dispositivo PHY              |
| 17-16  | TA (Turnaround)   | Tiempo de espera para cambio de control del bus                             |
| 15-0   | Data              | Datos a escribir o leídos                                                   |

- **Señales Usadas:** MDC (reloj) y MDIO (datos).
- **Comportamiento:** Las transacciones se transmiten bit a bit en cada ciclo de reloj MDC.

### Controlador 🎛️
- **Entradas:**
  - **CLK:** Reloj principal.
  - **RESET:** Señal de reinicio.
  - **MDIO_IN:** Entrada de datos del PHY.
- **Salidas:**
  - **MDC:** Reloj de MDIO.
  - **MDIO_OUT:** Salida de datos hacia el PHY.
  - **MDIO_OE:** Control de salida de MDIO.
- **Registros Internos:**
  - **Address Register:** Almacena la dirección PHY y de registro durante la operación.
  - **Data Register:** Almacena los datos a enviar o recibir.
- **Descripción:**
  - Controla el flujo de transacciones MDIO, genera el reloj MDC y maneja las señales de entrada/salida para comunicarse con dispositivos PHY.

### Periférico 🖧
- **Entradas:**
  - **ADDR:** Dirección de la operación de memoria.
  - **WR_DATA:** Datos para escribir en memoria.
- **Salidas:**
  - **RD_DATA:** Datos leídos de memoria.
- **Registros Internos:**
  - **Memory Array:** Array para almacenar los datos escritos.
- **Descripción:**
  - Implementa memoria para almacenar y recuperar registros según las transacciones MDIO.

### Bancos de Pruebas 🛠️

#### `controller_tb.v`
- **Objetivo:** Verificar el correcto manejo de las señales del controlador.
- **Procedimientos:**
  - Generación de señal de reloj y reset.
  - Simulación de entradas MDIO_IN con variadas tramas de datos.
  - Verificación de las salidas MDC, MDIO_OUT y MDIO_OE.
- **Salidas Esperadas:** Archivos `.vcd` que muestran el correcto secuenciado y sincronización de las señales.

#### `peripheral_tb.v`
- **Objetivo:** Probar la capacidad del periférico para manejar escrituras y lecturas de memoria.
- **Procedimientos:**
  - Escritura en todas las direcciones de memoria.
 

 - Lectura y verificación de los datos escritos.
- **Salidas Esperadas:** Confirmación de la integridad de los datos en la memoria.

#### `MDIO_tb.v`
- **Objetivo:** Integrar y probar el sistema completo de transacciones MDIO.
- **Procedimientos:**
  - Simulación de una serie de transacciones MDIO completas.
  - Verificación de la coordinación entre el controlador y el periférico.
- **Salidas Esperadas:** Tramas detalladas en `.vcd` mostrando las transacciones completas y la correcta operación del sistema.

### Uso del Makefile para Probar los Módulos y el Protocolo MDIO 🛠️

Para compilar y ejecutar los bancos de pruebas:

1. Abre una terminal en el directorio raíz del proyecto.
2. Ejecuta `make` para compilar todos los módulos y bancos de pruebas.
3. Utiliza `make controller`, `make peripheral`, y `make mdio` para testear cada componente respectivamente.
4. Los resultados se visualizan en GTKWave usando los archivos `*.vcd` generados.

### Fuentes y Software Usado 💻

- **Estándar IEEE 802.3 (cláusula 22)**
- **Icarus Verilog:** Compilador de Verilog.
- **GTKWave:** Visor de formas de onda.

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

### Controlador MDIO 🎛️

#### Descripción 📝
El controlador MDIO es el encargado de manejar el protocolo MDIO y gestionar las transacciones de lectura y escritura con los dispositivos PHY conectados. Implementa una máquina de estados finita (FSM) para controlar el flujo de la transacción y generar las señales de control adecuadas.

#### Entradas ⚙️
- **CLK:** Reloj del sistema.
- **RESET:** Señal de reinicio del controlador.
- **MDIO_IN:** Entrada de datos seriales del bus MDIO (desde el dispositivo PHY).

#### Salidas 📤
- **MDC:** Reloj del bus MDIO.
- **MDIO_OUT:** Salida de datos seriales hacia el bus MDIO (al dispositivo PHY).
- **MDIO_OE:** Habilitación de la salida MDIO_OUT.

#### Registros Internos 💾
- **address_reg:** Registro que almacena la dirección del dispositivo PHY y el registro a leer/escribir.
- **data_reg:** Registro que almacena los datos a enviar o recibir.

#### Máquina de Estados 🏭
1. **IDLE:** Estado inicial. Espera una transacción MDIO.
2. **START:** Detecta el código de inicio de la trama (01).
3. **OP_CODE:** Determina si la operación es lectura (10) o escritura (01).
4. **PHY_ADDR:** Carga la dirección del dispositivo PHY en address_reg.
5. **REG_ADDR:** Carga la dirección del registro en address_reg.
6. **TURNAROUND:** Ciclo de espera para cambio de control del bus.
7. **WRITE_DATA:** Envía los datos seriales a través de MDIO_OUT (en escritura).
8. **READ_DATA:** Recibe los datos seriales desde MDIO_IN (en lectura).

#### Funcionamiento 🚀
1. En el estado **IDLE**, el controlador espera una transacción MDIO válida.
2. Si se detecta el código de inicio (01), se pasa al estado **START**.
3. En **OP_CODE**, se determina si la operación es lectura o escritura.
4. En **PHY_ADDR** y **REG_ADDR**, se carga la dirección completa en address_reg.
5. En **TURNAROUND**, se espera un ciclo para el cambio de control del bus.
6. En **WRITE_DATA**, se envían serialmente los datos desde data_reg a través de MDIO_OUT.
7. En **READ_DATA**, se reciben serialmente los datos desde MDIO_IN y se almacenan en data_reg.
8. Al finalizar la transacción, se vuelve al estado **IDLE**.

### Periférico MDIO 🖧

#### Descripción 📝
El periférico MDIO actúa como una memoria que almacena y recupera registros según las transacciones MDIO recibidas. Implementa un arreglo de memoria y lógica para manejar las operaciones de lectura y escritura.

#### Entradas ⚙️
- **ADDR:** Dirección de memoria para la operación actual.
- **WR_DATA:** Datos a escribir en la dirección especificada.

#### Salidas 📤
- **RD_DATA:** Datos leídos desde la dirección especificada.

#### Registros Internos 💾
- **mem:** Arreglo de memoria para almacenar los registros.

#### Funcionamiento 🚀
1. Cuando se recibe una transacción de escritura (determinada por las señales de control del controlador MDIO), los datos en WR_DATA se escriben en la dirección de memoria especificada por ADDR.
2. Cuando se recibe una transacción de lectura, los datos almacenados en la dirección de memoria especificada por ADDR se cargan en RD_DATA y se envían al controlador MDIO.
3. Las operaciones de lectura y escritura se sincronizan con las señales de control del controlador MDIO.
4. El periférico no realiza ninguna operación adicional además de almacenar y recuperar los registros según las transacciones MDIO.

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

## Cronograma por Semanas 📅

### Semana 1: 8 de junio - 14 de junio
- **Sábado 8 de junio:** Inicio de la redacción de la documentación.
- **Lunes 10 de junio a Viernes 14 de junio:** Continuación de la documentación, incluyendo la descripción del proyecto, estructura, detalles del protocolo MDIO, controlador y periférico, y bancos de pruebas.

### Semana 2: 15 de junio - 21 de junio
- **Sábado 15 de junio:** Inicio de la programación de los módulos (controlador y periférico) en Verilog.
- **Lunes 17 de junio a Viernes 21 de junio:** Desarrollo continuo del controlador y periférico, asegurando el cumplimiento con el protocolo MDIO y la implementación correcta de la máquina de estados, comienza también el desarrollo de los bancos de prueba.

### Semana 3: 22 de junio - 24 de junio
- **Sábado 22 de junio a Lunes 24 de junio:** Desarrollo de los bancos de pruebas `controller_tb.v` y `peripheral_tb.v`, incluyendo la simulación y verificación de las señales.

### Semana 4: 24 de junio - 1 de julio
- **Sábado 29 de junio:** Integración del sistema completo y desarrollo del banco de pruebas `MDIO_tb.v`.
- **Domingo 30 de junio:** Verificación y simulación de las transacciones MDIO completas. Redacción de la presentación power point.
- **Lunes 1 de julio:** Finalización de la documentación en LaTeX, revisando y asegurando la coherencia y completitud de la descripción del proyecto y los resultados de las pruebas.

### Tabla Resumen 📋

| Semana                     | Fechas               | Tareas                                                                                     |
|----------------------------|----------------------|--------------------------------------------------------------------------------------------|
| **Semana 1**               | 8 de junio - 14 de junio | - Inicio de la redacción de la documentación <br> - Continuación de la documentación      |
| **Semana 2**               | 15 de junio - 21 de junio | - Inicio de la programación de los módulos <br> - Desarrollo continuo del controlador y periférico |
| **Semana 3**               | 22 de junio - 24 de junio | - Finalización de la programación de los módulos (24 de junio) <br> - Desarrollo de los bancos de pruebas `controller_tb.v` y `peripheral_tb.v` |
| **Semana 4**               | 24 de junio - 1 de julio | - Integración del sistema completo <br> - Desarrollo del banco de pruebas `MDIO_tb.v` <br> - Verificación y simulación de las transacciones MDIO completas <br> - Finalización de la documentación en LaTeX |

### Fuentes y Software Usado 💻

- **Estándar IEEE 802.3 (cláusula 22)**
- **Icarus Verilog:** Compilador de Verilog.
- **GTKWave:** Visor de formas de onda.

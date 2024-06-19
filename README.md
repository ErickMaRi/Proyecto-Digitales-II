# Receptor de Transacciones MDIO 📡🔄💾

## Resumen del Proyecto 📝

Abarca el diseño e implementación de un receptor de transacciones MDIO (Management Data Input/Output), conformándose a la cláusula 22 del estándar IEEE 802.3. El receptor es crucial para interpretar y procesar transacciones MDIO, utilizado en la gestión y configuración de dispositivos de red Ethernet.

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
│       ├── PHY.v
│       ├── PHY_tb.v
│       ├── peripheral_tb.v
│       └── peripheral.v
├── Parte 1 Proyecto Final.pdf
├── Parte 2 Proyecto Final.pdf
└── README.md
```

## Descripción del Controlador y Periférico MDIO ⚙️

### Protocolo MDIO 🔄

El protocolo MDIO (Management Data Input/Output), definido en la cláusula 22 de IEEE 802.3, establece la comunicación serial entre un controlador (station management entity, STA) y dispositivos PHY. Aquí se describe de manera técnica y detallada.

#### Señales Principales

**22.2.2.13 MDC (Management Data Clock):**
- **Función:** Señal de reloj generada por el controlador hacia el PHY, utilizada como referencia de tiempo para la transferencia de información.
- **Características:**
  - Señal aperiódica.
  - Sin tiempos máximos de alto o bajo.
  - Tiempos mínimos de alto y bajo: 160 ns cada uno.
  - Periodo mínimo: 400 ns.

**22.2.2.14 MDIO (Management Data Input/Output):**
- **Función:** Señal bidireccional entre el controlador y el PHY para transferir información de control y estado.
- **Características:**
  - Controlada por el controlador y muestreada por el PHY para la información de control.
  - Controlada por el PHY y muestreada por el controlador para la información de estado.
  - Conducción mediante circuitos de tres estados, permitiendo al controlador o al PHY manejar la señal.
  - PHY debe proporcionar un pull-up resistivo para mantener la señal en estado alto.
  - Controlador debe incorporar un pull-down resistivo para determinar la conexión del PHY.

#### Estructura de la Transacción MDIO

Cada transacción consta de 32 bits sincronizados por MDC:

| Bit(s) | Campo             | Descripción                             |
|--------|-------------------|-----------------------------------------|
| 31-30  | ST (Start)        | 01 indica inicio de transacción         |
| 29-28  | Op Code           | 10: Lectura, 01: Escritura              |
| 27-23  | PHY Address       | Dirección del dispositivo PHY           |
| 22-18  | Reg Address       | Dirección del registro en el PHY        |
| 17-16  | TA (Turnaround)   | Cambio de control del bus               |
| 15-0   | Data              | Datos a escribir o leídos               |

#### Ejemplos de Transacciones

**Escritura:**
1. **Inicio:**
   - Bits ST: `01`
   - Código de operación: `01` (Escritura)
   - Dirección PHY: `00001` (1)
   - Dirección Registro: `00010` (2)
   - Turnaround: `10`
   - Datos: `0000000000001100` (12)

```
Transacción Escrita: 01 01 00001 00010 10 0000000000001100
```

**Lectura:**
1. **Inicio:**
   - Bits ST: `01`
   - Código de operación: `10` (Lectura)
   - Dirección PHY: `00001` (1)
   - Dirección Registro: `00010` (2)
   - Turnaround: `10`
   - Datos: `[datos proporcionados por el PHY]`

```
Transacción Lectura: 01 10 00001 00010 10 [datos]
```

### Controlador MDIO 🎛️

#### Descripción 📝
El controlador MDIO es el encargado de manejar el protocolo MDIO y gestionar las transacciones de lectura y escritura con los dispositivos PHY (periféricos) conectados. Implementa una máquina de estados finita (FSM) para controlar el flujo de la transacción y generar las señales de control adecuadas.

#### Entradas ⚙️
- **CLK:** Entrada que llega al controlador desde el CPU con una frecuencia determinada. (1 bit) (Señal hacia el CPU y SW)
- **RESET:** Entrada de reinicio del generador. Si **RESET=1** el generador funciona normalmente, de lo contrario vuelve al estado inicial y *todas las salidas toman el valor de cero*. (1 bit) (Señal hacia el CPU y SW)
- **MDIO_START:** Pulso de un ciclo de reloj. Indica al generador que se ha cargado un valor en la entrada **T_DATA** y que se debe iniciar la transmisión de los datos a través de la salida serial (**MDIO_OUT**). (1 bit) (Señal hacia el CPU y SW)
- **T_DATA:** Entrada paralela. Cuando se habilita **MDIO_START** en el siguiente ciclo de reloj se transmite el bit **T_DATA** por la salida **MDIO_OUT** y durante los siguientes ciclos se transmite un bit por ciclo hasta completar el envío de la palabra completa. (32 bit) (Señal hacia el CPU y SW)
- **MDIO_IN:** Entrada serial. Durante una operación de lectura, se debe leer el valor de esta entrada durante los últimos 16  ciclos de la transacción MDIO y escribirlos en la salida **RD_DATA**. (1 bit) (Señal hacia los periféricos)

#### Salidas 📤
- **RD_DATA:** Esta salida debe producir los 16 bits que se reciben desde el lado del periférico durante una transacción de lectura recibida en **MDIO_IN**. El valor de **RD_DATA** solo es válido cuando **DATA_RDY** es igual a 1. (16 bit) (Señal hacia el CPU y SW)
- **DATA_RDY:** Salida que se pone en 1 cuando se ha completado la recepción de una palabra serial complerta durante una transacción de lectura. (1 bit) (Señal hacia el CPU y SW)
- **MDC:** Salida de reloj para el MDIO, que deberá temer una frecuencia *de la mitad de la frecuencia de entrada* del **CLK**. Se debe generar MDC con la frecuencia correcta para cualquier valor de la frecuencia de entrada **CLK**. (1 bit) (Señal hacia los periféricos)
- **MDIO_OE:** Habilitación de la salida **MDIO_OUT**. Debe detectar si la transacción es de lectura o escritura. Si la transacción es de *escritura*, debe permanecer en *alto durante 32 ciclos* de la transacción y ponerse en bajo cuando termine. En una transacción de *lectura*, debe permanecer en *alto durante primeros 16 ciclos* y luego *bajo durante los finales 16 ciclos*, mientras se recibe el dato en **MDIO_IN**, la señal debe ser cero. (1 bit) (Señal hacia los periféricos)
- **MDIO_OUT:** *Salida serial*. Cuando se habilita **MDIO_START=1**, se envía a través de la salida **MDIO_OUT** los bits que se observan en la entrada T_DATA, empezando por el bit más significativo y hasta completar los 32 bits. (1 bit) (Señal hacia los periféricos)

#### Registros Internos 💾
- **address_reg:** Registro que almacena la dirección del dispositivo PHY y el registro a leer/escribir (5 bits).
- **data_reg:** Registro que almacena los datos a enviar o recibir (16 bits).

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
El periférico MDIO actúa como un receptor de transacciones MDIO de acuerdo con las especificaciones estipuladas en la cláusula 22 del estándar IEEE 802.3. Una memoria que almacena y recupera registros según las transacciones MDIO recibidas. Implementa un arreglo de memoria y lógica para manejar las operaciones de lectura y escritura. Funciona como una interfaz entre el PHY y el controlador.

#### Entradas ⚙️
- **RESET:** Entrada de reinicio del generador. Si **RESET=1** el generador funciona normalmente. En caso contrario, el enerador vuelve a su estado inicial y todas las salidas toman el valor de cero. (1 bit) (Señal controlada por el testbench o sistema en el que se declara)
- **RD_DATA:** Entrada de datos. Contiene el valor leído desde la memoria, a más tardar dos ciclos de MDC después de que se cumple que **MDIO_DONE=1** y **WR_STB=0**. (16 bit) (Señal hacia PHY)
- **MDC:** Entrada de reloj para el MDIO. El flanco activo de la señal MDC es el flanco creciente. Esta entrada debe provenir de un generador de MDIO, o al menos modelar su comportamiento. (1 bit) (Señal hacia el controlador)
- **MDIO_OE:** Habilitación de **MDIO_OUT**. Esta entrada debe detectar si el valor de **MDIO_OUT** que se está recibiendo es un valor válido habilitado. En una transacción de escritura, debe permanecer en alto durante los 32 ciclos de la transacción, pero ponerse en bajo al terminar la transacción. En una transacción de lectura, debe permanecer en alto durante los primeros 16 ciclos de la transacción, pero debe ponerse en cero durante los siguientes 16 ciclos, mientras el receptor envía el dato de **MDIO_IN**. Al final de la transacción de lectura, se espera que esta entrada debe permanecer en cero. (1 bit) (Señal hacia el controlador)
- **MDIO_OUT:** Entrada serial. Esta entrada debe provenir de un generador de MDIO, o al menos modelar su comportamiento. (1 bit) (Señal hacia el controlador)

#### Salidas 📤
- **ADDR:** Salida de dirección. Indica en qué posición de memoria se debe almacenar el dato que se recibe en **WR_DATA**, o desde cuál posición se debe leer **RD_DATA**. (5 bit) (Señal hacia PHY)
- **WR_DATA:** Salida de datos. Los datos que se presentan en esta salida se escriben en la posición de memoria indicada por **ADDR** en el ciclo de reloj donde **MDIO_DONE=1** y **WR_STB=1**. (16 bit) (Señal hacia PHY)
- **MDIO_DONE:** Strobe (pulso de un ciclo de reloj). Salida que indica que se ha completado una transacción de MDIO en el receptor. (1 bit) (Señal hacia PHY)
- **WR_STB:** Esta salida se pone en 1 para indicar que los datos de **WR_DATA** y **WR_ADDR** son válidos y deben ser escritos a la memoria. (1 bit) (Señal hacia PHY)
- **MDIO_IN:** Salida serie. Durante una operación de lectura (de acuerdo a la cláusula 22 del estándar), se debe enviar a través de esta salida, el dato almacenado en la posición **REGADDR**, durante los últimos 16 ciclos de la transacción de MDIO. (1 bit) (Señal hacia el controlador)

#### Funcionamiento 🚀
1. Cuando se recibe una transacción de escritura (determinada por las señales de control del controlador MDIO), los datos en WR_DATA se escriben en la dirección de memoria especificada por ADDR.
2. Cuando se recibe una transacción de lectura, los datos almacenados en la dirección de memoria especificada por ADDR se cargan en RD_DATA y se envían al controlador MDIO.
3. Las operaciones de lectura y escritura se sincronizan con las señales de control del controlador MDIO.
4. El periférico no realiza ninguna operación adicional además de almacenar y recuperar los registros según las transacciones MDIO.

Aquí está la documentación del módulo PHY en el estilo del README:

### Physical Layer Device (PHY) 📶

#### Descripción 📝

El Physical Layer Device (PHY) es un dispositivo que implementa la capa física del estándar Ethernet IEEE 802.3. Su función principal es actuar como una interfaz entre el medio físico de transmisión (cable de red) y el controlador MDIO. Almacena y proporciona datos según las transacciones de lectura y escritura recibidas a través de la interfaz MDIO.

#### Interfaz MDIO 🔌

El PHY se comunica con el controlador MDIO a través de las siguientes señales:

##### Entradas ⚙️

- **ADDR:** Dirección de memoria donde se deben almacenar o recuperar los datos. (5 bits)
- **WR_DATA:** Datos que se escribirán en la memoria en la dirección especificada por **ADDR**. (16 bits)
- **WR_STB:** Indica que los datos de **WR_DATA** y **ADDR** son válidos y deben escribirse en la memoria.

##### Salidas 📤

- **RD_DATA:** Datos leídos desde la memoria en la dirección especificada por **ADDR**. (16 bits)

#### Funcionamiento 🚀

1. **Escritura:**
   - Cuando se recibe una transacción de escritura (**WR_STB=1**), los datos presentes en **WR_DATA** se almacenan en la dirección de memoria indicada por **ADDR**.

2. **Lectura:**
   - Cuando se recibe una transacción de lectura (**WR_STB = 0**), los datos almacenados en la dirección de memoria indicada por **ADDR** se cargan en **RD_DATA**.

#### Memoria Interna 💾

El PHY cuenta con una memoria interna para almacenar los registros de configuración y estado. La memoria está organizada en 32 direcciones de 16 bits cada una, siguiendo el espacio de direcciones establecido por el estándar IEEE 802.3.

```
Memoria PHY:
  Dirección  | Contenido
  -----------+---------------
  0x00       | Registro 0
  0x01       | Registro 1
  ...        | ...
  0x1F       | Registro 31
```

El módulo PHY no realiza ninguna operación adicional además de almacenar y recuperar los registros según las transacciones MDIO recibidas desde el controlador a través del periférico.

### Bancos de Pruebas 🛠️

#### `controller_tb.v`
- **Objetivo:** Verificar el correcto funcionamiento del módulo controlador.
- **Procedimientos:**
  - Generación de señal de reloj y reset.
  - Simular las entradas y capturar las salidas para las pruebas de:
    * Escritura, 
    * Lectura, 
    * Condición de **RESET**
- **Salidas Esperadas:** Archivo `sim.vcd` que muestra los trazos del DUT, escritura en consola de algunos trazos relevantes en momentos sensibles.

#### `peripheral_tb.v`
- **Objetivo:** Probar el correcto funcionamiento del módulo periférico.
- **Procedimientos:**
  - Generación de señal de reloj y reset.
  - Simular las entradas y capturar las salidas para las pruebas de:
    * Escritura, 
    * Lectura,
    * Carga de memoria
    * Condición de **RESET**
- **Salidas Esperadas:** Confirmación de la integridad de los datos en la memoria.

#### `MDIO_tb.v`
- **Objetivo:** Integrar y probar el sistema completo de transacciones MDIO.
- **Procedimientos:**
  - Simulación de una serie de transacciones MDIO completas.
  - Verificación de la coordinación entre el controlador y el periférico.
- **Salidas Esperadas:** Tramas detalladas en `.vcd` mostrando las transacciones completas y la correcta operación del sistema.

#### `phy_tb.v`

- **Objetivo:** Verificar el correcto funcionamiento del módulo PHY.
- **Descripción:**
  - Genera las señales de entrada necesarias para simular las transacciones de lectura y escritura en el PHY.
  - Verifica que los datos se almacenen y recuperen correctamente de la memoria interna del PHY.
  - Prueba diversas condiciones y casos de prueba para asegurar un funcionamiento robusto.

#### Entradas Simuladas ⚙️

- **ADDR:** Dirección de memoria para las operaciones de lectura y escritura.
- **WR_DATA:** Datos que se escribirán en la memoria.
- **WR_STB:** Señal de control que indica una transacción de escritura.

#### Salidas Monitoreadas 📤

- **RD_DATA:** Datos leídos desde la memoria.

#### Procedimientos de Prueba 🧪

1. **Generación de señales de reloj y reset:**
   - Se genera una señal de reloj y una señal de reset para inicializar el módulo PHY.

2. **Prueba de escritura:**
   - Se simulan transacciones de escritura enviando diferentes valores de **WR_DATA** y **ADDR**.
   - Se verifica que los datos se almacenen correctamente en la memoria interna del PHY.

3. **Prueba de lectura:**
   - Se simulan transacciones de lectura enviando diferentes valores de **ADDR**.
   - Se verifica que los datos leídos en **RD_DATA** coincidan con los valores previamente escritos en la memoria.

4. **Pruebas con condiciones específicas:**
   - Se prueban casos límite, como escribir y leer en todas las direcciones de memoria.
   - Se verifica el funcionamiento correcto al aplicar señales de reset durante las transacciones.
   - Se prueban casos de error, como intentar leer de una dirección no válida.

#### Salidas Esperadas 📋

- **Archivo de trazas (`phy_tb.vcd`):** Contiene las formas de onda de las señales simuladas, incluyendo las entradas y salidas del módulo PHY.
- **Mensajes de confirmación:** El banco de pruebas imprimirá mensajes en la consola indicando el éxito o fallo de cada prueba realizada.

#### Uso del Banco de Pruebas 🚀

1. Compilar el código Verilog del banco de pruebas y el módulo PHY utilizando un compilador compatible (p. ej., Icarus Verilog).
2. Ejecutar la simulación del banco de pruebas.
3. Abrir el archivo de trazas (`phy_tb.vcd`) en un visor de formas de onda (p. ej., GTKWave) para inspeccionar las señales y verificar el comportamiento del módulo PHY.
4. Revisar los mensajes impresos en la consola para confirmar el éxito o fallo de las pruebas.

El banco de pruebas `phy_tb.v` permite verificar exhaustivamente el funcionamiento del módulo PHY, asegurando que cumpla con los requisitos y especificaciones establecidos.

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
| **Semana 4**               | 24 de junio - 1 de julio | - Integración del sistema completo <br> - Desarrollo del banco de pruebas `MDIO_tb.v` <br> - Verificación y simulación de las transacciones MDIO completas <br> - Finalización de la documentación en LaTeX y el afiche |

## Fuentes y Software Usado 💻


- **Estándar IEEE 802.3 (cláusula 22)** [IEEE 802.3-2018 - IEEE Standard for Ethernet](https://standards.ieee.org/ieee/802.3/7071/)
- **Icarus Verilog:** Compilador de Verilog. [Documentación Icarus Verilog, por Stephen Williams](https://steveicarus.github.io/iverilog/) [Sitio alternativo](https://bleyer.org/icarus/)
- **GTKWave:** Visor de formas de onda. [GTKWave, bajo GNU GPL versión 2](https://gtkwave.github.io/gtkwave/install/unix_linux.html)

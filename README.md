### Receptor de Transacciones MDIO 📡🔄💾

## Descripción del Proyecto 📝

Este proyecto consiste en el diseño y la implementación de un receptor de transacciones MDIO (Management Data Input/Output) conforme a las especificaciones de la cláusula 22 del estándar IEEE 802.3. Este receptor es esencial para recibir y procesar transacciones MDIO, que son transacciones seriales de 32 bits usadas en la configuración y gestión de dispositivos en redes Ethernet.

## Estructura del Proyecto 🗂️

El proyecto se organiza de la siguiente manera:

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
├── Parte 2 Proyecto Final.pdf
└── README.md
```

### Controlador y Periférico MDIO ⚙️

#### Protocolo MDIO 🔄
- Formato de transacción serial de 32 bits.
- Estructura:

| Bit(s) | Campo             | Descripción                                                                 |
|--------|-------------------|-----------------------------------------------------------------------------|
| 31-30  | ST (Start)        | Código de inicio de trama (01 para Clause 22)                               |
| 29-28  | Código de operación | 10: Lectura, 01: Escritura                                                  |
| 27-23  | PHY Address       | Dirección del dispositivo PHY                                               |
| 22-18  | Reg Address       | Dirección del registro a leer o escribir en el dispositivo PHY              |
| 17-16  | TA (Turnaround)   | Tiempo de espera para cambiar la propiedad del bus                          |
| 15-0   | Data              | Datos a escribir (en transacciones de escritura) o datos leídos (en transacciones de lectura) |

- Utiliza señales MDC (Reloj) y MDIO (Datos).
- Las transacciones se transmiten bit a bit en cada ciclo de reloj MDC.
- En Escritura, se envían los 32 bits de la trama al dispositivo PHY.
- En Lectura, se envían los primeros 16 bits, y el PHY responde con los 16 bits restantes (datos leídos).

### Controlador 🎛️
- Recibe:
  1. `MDC`: Reloj para el MDIO. Flanco activo en flanco creciente.
  2. `RESET`: Reinicio del controlador. Si RESET=1, funciona normalmente. Si RESET=0, vuelve a estado inicial y todas las salidas a 0.
  3. `MDIO_OUT`: Entrada serial. Debe provenir de un generador MDIO o modelar su comportamiento.
  4. `MDIO_OE`: Habilitación de MDIO_OUT. Debe detectar si el valor de MDIO_OUT es válido y habilitado.
- Genera:
  1. `MDIO_DONE`: Strobe (pulso de 1 ciclo de reloj). Indica que se completó una transacción MDIO.
  2. `MDIO_IN`: Salida serie. Durante operación de lectura, envía el dato almacenado en REGADDR durante los últimos 16 ciclos.
  3. `ADDR[4:0]`: Dirección del registro a leer/escribir.
  4. `WR_DATA[15:0]`: Datos a escribir en la posición de memoria indicada por ADDR cuando MDIO_DONE=1 y WR_STB=1.
  5. `RD_DATA[15:0]`: Valor leído desde la memoria, a más tardar 2 ciclos de MDC después de MDIO_DONE=1 y WR_STB=0.
  6. `WR_STB`: Indica que WR_DATA y WR_ADDR son válidos y deben escribirse a la memoria.

### Periférico 🖧
- Recibe:
  1. `ADDR[4:0]`: Dirección del registro a leer/escribir.
  2. `WR_DATA[15:0]`: Datos a escribir.
  3. `RD_DATA[15:0]`: Salida de datos le

ídos.
  4. `WR_STB`: Indica operación de escritura cuando WR_STB=1.
- Implementa memoria interna (por ejemplo, arreglo) para almacenar registros.
- Para Escritura:
  1. Recibe dirección de registro (ADDR) y datos (WR_DATA).
  2. En WR_STB=1, escribe WR_DATA en la posición de memoria indicada por ADDR.
- Para Lectura:
  1. Recibe dirección de registro (ADDR).
  2. Lee datos de la posición de memoria indicada por ADDR.
  3. Coloca los datos leídos en RD_DATA.

### Uso del Makefile para Probar los Módulos y el Protocolo MDIO 🛠️

El proyecto incluye un archivo `Makefile` que facilita la compilación y ejecución de los bancos de pruebas. Para ejecutar los bancos de pruebas, sigue estos pasos:

1. Abre una terminal en el directorio raíz del proyecto.
2. Ejecuta el comando `make` para compilar todos los módulos y bancos de pruebas.
3. Para ejecutar el banco de pruebas del controlador, ejecuta el comando `make controller`.
4. Para ejecutar el banco de pruebas del periférico, ejecuta el comando `make peripheral`.
5. Para ejecutar el banco de pruebas de MDIO, ejecuta el comando `make mdio`.

Después de ejecutar cada banco de pruebas, se generará un archivo `*.vcd` que contiene la traza de la simulación. Puedes abrir este archivo en un visor de formas de onda, como GTKWave, para visualizar los resultados.

### Fuentes y Software Usado 💻

- Estándar IEEE 802.3 (cláusula 22)
- Icarus Verilog (compilador de Verilog)
- GTKWave (visor de formas de onda)

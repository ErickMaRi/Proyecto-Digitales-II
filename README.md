# Receptor de Transacciones MDIO

## Descripción del proyecto

Este proyecto consiste en el diseño de un receptor de transacciones MDIO (Interfaz de Gestión de Dispositivos Independientes) según las especificaciones de la cláusula 22 del estándar IEEE 802.3. El receptor es responsable de recibir y procesar transacciones MDIO, las cuales son transacciones seriales de 32 bits utilizadas para la gestión y configuración de dispositivos en redes Ethernet.

## Estructura del proyecto

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

## MDIO

El protocolo MDIO (Interfaz de Gestión de Dispositivos Independientes) es un protocolo de comunicación serial utilizado en redes Ethernet para la gestión y configuración de dispositivos. Permite a una estación de gestión (como un switch o un router) leer y escribir registros de control y estado en dispositivos compatibles con MDIO, como transceptores de capa física (PHY).

Una transacción MDIO consta de 32 bits y tiene la siguiente estructura:

| Bit(s) | Campo       | Descripción                                                  |
|--------|--------------|---------------------------------------------------------------|
| 31-30  | Código de operación | 00: Lectura, 01: Escritura                                |
| 29-25  | Reservado   | Debe ser 0                                                  |
| 24-21  | PHY Address | Dirección del dispositivo PHY                               |
| 20-16  | Reg Address | Dirección del registro a leer o escribir en el dispositivo PHY |
| 15-0   | Data        | Datos a escribir (en transacciones de escritura) o sin usar (en transacciones de lectura) |

### Controlador

El controlador es el módulo principal del receptor de transacciones MDIO. Es responsable de recibir las transacciones MDIO, decodificarlas y realizar las operaciones de lectura o escritura correspondientes en el periférico MDIO.

Especificaciones:

- Recibe las señales `MDC` (reloj MDIO), `RESET`, `MDIO_OUT` (datos seriales de entrada) y `MDIO_OE` (habilitación de datos de entrada).
- Genera las señales `MDIO_DONE` (indicador de transacción completada), `MDIO_IN` (datos seriales de salida), `ADDR` (dirección de registro), `WR_DATA` (datos a escribir), `RD_DATA` (datos leídos) y `WR_STB` (indicador de operación de escritura).
- Implementa la máquina de estados para decodificar y procesar las transacciones MDIO.
- Realiza operaciones de lectura y escritura en el periférico MDIO según las transacciones recibidas.

### Periférico

El periférico MDIO es un módulo que simula el comportamiento de un dispositivo MDIO real, como un transceptor de capa física (PHY). Implementa una memoria interna donde se almacenan los registros de control y estado.

Especificaciones:

- Recibe las señales `ADDR` (dirección de registro), `WR_DATA` (datos a escribir), `RD_DATA` (datos a leer) y `WR_STB` (indicador de operación de escritura) del controlador.
- Implementa una memoria interna para almacenar los registros de control y estado.
- Realiza operaciones de lectura y escritura en los registros según las señales recibidas del controlador.

## Bancos de pruebas

El proyecto incluye tres bancos de pruebas para verificar el correcto funcionamiento de los módulos:

### Banco de pruebas del controlador

El archivo `MDIO/controller/controller_tb.v` contiene el banco de pruebas para el módulo controlador. Este banco de pruebas genera diferentes escenarios de transacciones MDIO y verifica que el controlador responda correctamente.

### Banco de pruebas del periférico

El archivo `MDIO/peripheral/peripheral_tb.v` contiene el banco de pruebas para el módulo periférico. Este banco de pruebas genera diferentes operaciones de lectura y escritura en los registros del periférico y verifica que los datos se almacenen y lean correctamente.

### Banco de pruebas de MDIO

El archivo `MDIO/MDIO_tb.v` contiene un banco de pruebas más general que verifica el correcto funcionamiento del receptor de transacciones MDIO completo, incluyendo la interacción entre el controlador y el periférico.

## Uso del makefile para probar los módulos y el protocolo MDIO

El proyecto incluye un archivo `Makefile` que facilita la compilación y ejecución de los bancos de pruebas. Para ejecutar los bancos de pruebas, sigue estos pasos:

1. Abre una terminal en el directorio raíz del proyecto.
2. Ejecuta el comando `make` para compilar todos los módulos y bancos de pruebas.
3. Para ejecutar el banco de pruebas del controlador, ejecuta el comando `make run_controller_tb`.
4. Para ejecutar el banco de pruebas del periférico, ejecuta el comando `make run_peripheral_tb`.
5. Para ejecutar el banco de pruebas de MDIO, ejecuta el comando `make run_mdio_tb`.

Después de ejecutar cada banco de pruebas, se generará un archivo `*.vcd` que contiene la traza de la simulación. Puedes abrir este archivo en un visor de formas de onda, como GTKWave, para visualizar los resultados.

## Fuentes y software usado

- Estándar IEEE 802.3 (cláusula 22)
- Icarus Verilog (compilador de Verilog)
- GTKWave (visor de formas de onda)
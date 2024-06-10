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

# Controlador y Periférico MDIO

## Protocolo MDIO
- Formato de transacción serial de 32 bits
- Estructura:
 - Bits 31-30: Código de Operación (00: Lectura, 01: Escritura)
 - Bits 29-25: Reservado (0)
 - Bits 24-21: Dirección del PHY (0-31)
 - Bits 20-16: Dirección del Registro (0-31)
 - Bits 15-0: Datos (Datos de Escritura o sin usar para Lectura)
- Utiliza señales MDC (Reloj) y MDIO (Datos)
- Las transacciones se transmiten bit a bit en cada ciclo de reloj MDC
- En Escritura, se envían los 32 bits de la trama al dispositivo PHY
- En Lectura, se envían los primeros 16 bits, y el PHY responde con los 16 bits restantes (datos leídos)

## Controlador
- Recibe: 
 - `MDC`: Reloj para el MDIO. Flanco activo en flanco creciente.
 - `RESET`: Reinicio del controlador. Si RESET=1, funciona normalmente. Si RESET=0, vuelve a estado inicial y todas las salidas a 0.
 - `MDIO_OUT`: Entrada serial. Debe provenir de un generador MDIO o modelar su comportamiento.
 - `MDIO_OE`: Habilitación de MDIO_OUT. Debe detectar si el valor de MDIO_OUT es válido y habilitado.
- Genera:
 - `MDIO_DONE`: Strobe (pulso de 1 ciclo de reloj). Indica que se completó una transacción MDIO.
 - `MDIO_IN`: Salida serie. Durante operación de lectura, envía el dato almacenado en REGADDR durante los últimos 16 ciclos.
 - `ADDR[4:0]`: Dirección del registro a leer/escribir.
 - `WR_DATA[15:0]`: Datos a escribir en la posición de memoria indicada por ADDR cuando MDIO_DONE=1 y WR_STB=1.
 - `RD_DATA[15:0]`: Valor leído desde la memoria, a más tardar 2 ciclos de MDC después de MDIO_DONE=1 y WR_STB=0.
 - `WR_STB`: Indica que WR_DATA y WR_ADDR son válidos y deben escribirse a la memoria.
- Implementa máquina de estados para decodificar transacciones MDIO
- Para Escritura:
 - Decodifica trama en MDIO_OUT
 - Extrae dirección de registro (ADDR) y datos (WR_DATA)
 - Envía WR_STB=1 al Periférico para operación de escritura
 - Al completar, genera MDIO_DONE=1 durante 1 ciclo de reloj
- Para Lectura:
 - Decodifica trama en MDIO_OUT
 - Extrae dirección de registro (ADDR)
 - Señaliza al Periférico para operación de lectura
 - Transmite datos leídos (RD_DATA) en MDIO_IN durante últimos 16 ciclos
 - Al completar, genera MDIO_DONE=1 durante 1 ciclo de reloj

## Periférico
- Recibe:
 - `ADDR[4:0]`: Dirección del registro a leer/escribir.
 - `WR_DATA[15:0]`: Datos a escribir.
 - `RD_DATA[15:0]`: Salida de datos leídos.
 - `WR_STB`: Indica operación de escritura cuando WR_STB=1.
- Implementa memoria interna (por ejemplo, arreglo) para almacenar registros
- Para Escritura:
 - Recibe dirección de registro (ADDR) y datos (WR_DATA)
 - En WR_STB=1, escribe WR_DATA en la posición de memoria indicada por ADDR
- Para Lectura:
 - Recibe dirección de registro (ADDR)
 - Lee datos de la posición de memoria indicada por ADDR
 - Coloca los datos leídos en RD_DATA

## Banco de Pruebas del Controlador
- Genera señales de entrada: MDC, RESET, MDIO_OUT, MDIO_OE
- Verifica señales de salida: MDIO_DONE, MDIO_IN, ADDR, WR_DATA, RD_DATA, WR_STB
- Pruebas:
 - Inicialización y reset
 - Transacciones de Escritura válidas e inválidas:
   - Diferentes combinaciones de dirección de registro y datos
   - Verificación de MDIO_DONE, WR_STB, WR_DATA, ADDR
 - Transacciones de Lectura válidas e inválidas:
   - Diferentes combinaciones de dirección de registro
   - Verificación de MDIO_DONE, MDIO_IN, RD_DATA, ADDR
 - Cobertura de código: ejercitar todas las líneas y condiciones

## Banco de Pruebas del Periférico
- Genera señales de entrada: ADDR, WR_DATA, WR_STB
- Verifica señales de salida: RD_DATA
- Pruebas:
 - Inicialización y reset
 - Operaciones de Escritura válidas e inválidas:
   - Diferentes combinaciones de dirección de registro y datos
   - Verificación de datos escritos en memoria
 - Operaciones de Lectura válidas e inválidas:
   - Diferentes combinaciones de dirección de registro
   - Verificación de datos leídos de memoria
 - Cobertura de código: ejercitar todas las líneas y condiciones

## Banco de Pruebas de MDIO
- Instancia del Controlador y Periférico
- Genera señales de entrada del Controlador: MDC, RESET, MDIO_OUT, MDIO_OE
- Verifica señales de salida del Controlador y Periférico
- Pruebas:
 - Inicialización y reset de Controlador y Periférico
 - Transacciones MDIO completas de Escritura y Lectura válidas e inválidas:
   - Diferentes combinaciones de dirección de PHY, dirección de registro y datos
   - Verificación de decodificación y procesamiento de tramas
   - Verificación de datos escritos y leídos en Periférico
   - Verificación de señales de control y datos (MDIO_DONE, WR_STB, MDIO_IN, WR_DATA, RD_DATA)
 - Cobertura de código para Controlador y Periférico
 - Interoperabilidad entre Controlador y Periférico
 - Pruebas de estrés y rendimiento:
   - Gran cantidad de transacciones MDIO consecutivas
   - Verificación de manejo correcto del sistema
 - Escenarios de error y condiciones de borde:
   - Tramas MDIO incorrectas
   - Interrupciones durante transacciones
   
## Uso del makefile para probar los módulos y el protocolo MDIO

El proyecto incluye un archivo `Makefile` que facilita la compilación y ejecución de los bancos de pruebas. Para ejecutar los bancos de pruebas, sigue estos pasos:

1. Abre una terminal en el directorio raíz del proyecto.
2. Ejecuta el comando `make` para compilar todos los módulos y bancos de pruebas.
3. Para ejecutar el banco de pruebas del controlador, ejecuta el comando `make controller`.
4. Para ejecutar el banco de pruebas del periférico, ejecuta el comando `make peripheral`.
5. Para ejecutar el banco de pruebas de MDIO, ejecuta el comando `make mdio`.

Después de ejecutar cada banco de pruebas, se generará un archivo `*.vcd` que contiene la traza de la simulación. Puedes abrir este archivo en un visor de formas de onda, como GTKWave, para visualizar los resultados.

## Fuentes y software usado

- Estándar IEEE 802.3 (cláusula 22)
- Icarus Verilog (compilador de Verilog)
- GTKWave (visor de formas de onda)

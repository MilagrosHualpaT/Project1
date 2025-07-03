Gestión Operativa y Financiera del Banco EurekaBank

📌 Contexto: EurekaBank ha implementado un sistema bancario que registra las operaciones financieras, cuentas, clientes, empleados y sucursales. Actualmente, se busca aprovechar estos datos para obtener inteligencia de negocio que permita:

Evaluar la eficiencia operativa.

Analizar el comportamiento del cliente.

Optimizar recursos por sucursal.

Controlar el uso de productos y servicios financieros.

🎯 Objetivos del Sistema: Controlar los movimientos financieros por tipo (depósitos, retiros, transferencias).

Medir la productividad de los empleados (cuentas creadas, movimientos registrados).

Analizar el uso de servicios por moneda, ciudad, sucursal y cliente.

Detectar eventos críticos, como saldos negativos o cuentas canceladas.

Comparar el desempeño por periodo, ciudad y tipo de producto financiero.

Evaluar el costo y rentabilidad de operaciones según la moneda y tipo de transacción.

📦 Entidades clave (basadas en la base de datos actual): Sucursal

chr_sucucodigo, vch_sucunombre, vch_sucuciudad, vch_sucudireccion, int_sucucontcuenta

Cliente

chr_cliecodigo, vch_cliepaterno, vch_cliematerno, vch_clienombre, chr_cliedni, vch_clieciudad, vch_cliedireccion, vch_clietelefono, vch_clieemail

Empleado

chr_emplcodigo, vch_emplpaterno, vch_emplmaterno, vch_emplnombre, vch_emplusuario, vch_emplclave

Cuenta

chr_cuencodigo, chr_cliecodigo (FK), chr_emplcreacuenta (FK), chr_sucucodigo (FK), chr_monecodigo (FK), dec_cuensaldo, dtt_cuenfechacreacion, vch_cuenestado

Movimiento

chr_cuencodigo (FK), int_movinumero, dtt_movifecha, chr_emplcodigo (FK), chr_tipocodigo (FK), dec_moviimporte, chr_cuenreferencia

Moneda

chr_monecodigo, vch_monedescripcion

TipoMovimiento

chr_tipocodigo, vch_tipodescripcion, vch_tipoaccion, vch_tipoestado

Parametro / InteresMensual / CostoMovimiento

Para reglas sobre cargos y condiciones operativas.

📘 Reglas de negocio relevantes: Las cuentas están asociadas a un cliente, un empleado, una sucursal y una moneda.

Los movimientos están clasificados por tipo: depósito, retiro, transferencia, etc.

Si una cuenta tiene más de 15 movimientos, se cobra un cargo.

Cada moneda tiene una tasa de interés mensual asociada.

Cada moneda también tiene un costo por operación.

Cada empleado puede estar activo en una sola sucursal a la vez.

🛠️ Posibles consultas: ¿Cuál fue el saldo total de cada cliente durante los últimos 30 días?

🧮 Sumar el saldo de todas las cuentas activas por cliente filtrando por fecha.

¿Qué tipo de movimiento fue más frecuente en cada sucursal el mes pasado?

📊 Agrupar movimientos por sucursal y tipo, contar frecuencia y filtrar por mes.

¿Qué empleados registraron más movimientos durante el último trimestre?

👩‍💼 Contar registros en la tabla Movimiento por chr_emplcodigo.

¿Cuántas cuentas fueron canceladas en el último semestre y en qué ciudades?

❌ Consultar Cuenta con estado 'CANCELADO' y unir con sucursales para ver ciudades.

¿Cuáles son los clientes con más de 20 operaciones en un mes?

📈 Agrupar movimientos por cliente y contar operaciones mensuales.

¿Cuál fue el monto total depositado en soles por ciudad durante el último año?

💰 Unir Movimiento, Cuenta, Sucursal y Moneda, filtrar por tipo 'DEPÓSITO' y moneda '01'.

¿Cuál es el saldo promedio por cliente en el último trimestre?

📐 Calcular el promedio del campo dec_cuensaldo agrupado por cliente.

¿Qué sucursales tienen el mayor uso de moneda extranjera (dólares)?

💵 Sumar montos de movimientos donde la moneda sea '02' y agrupar por sucursal.

¿Qué porcentaje de cuentas abiertas este año están en estado cancelado?

📉 Comparar cuentas activas vs canceladas con fecha de creación dentro del año actual.

![Uploading DIAGRAMA FISICO_Deysi Milagros Hualpa Ticona.png…]()


¿Cuáles son los tipos de movimientos que generan más cargos por moneda?

⚠️ Identificar tipos de movimiento SALIDA y unir con CostoMovimiento para estimar impacto económico.

Diagrama E/R: DIAGRAMA E-R_Deysi Milagros Hualpa Ticona Diagrama Lógico: DIAGRAMA LOGICO_Deysi Milagros Hualpa Ticona Diagrama Físico: DIAGRAMA FISICO_Deysi Milagros Hualpa Ticona

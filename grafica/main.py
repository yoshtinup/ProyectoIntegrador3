import pandas as pd
import numpy as np
from statsmodels.tsa.holtwinters import ExponentialSmoothing # type: ignore
import matplotlib.pyplot as plt
import json

# Cargar el archivo
file_path = 'expanded_horario_compra_boletos.csv'
data_csv = pd.read_csv(file_path)

# Limpiar columna Fecha y filtrar "Pagado"
data_csv['Fecha'] = pd.to_datetime(data_csv['Fecha'], errors='coerce', dayfirst=True)
data_pagado = data_csv[data_csv['Estado de Pago'] == 'Pagado']

# Agrupar ventas diarias
ventas_diarias = data_pagado.groupby('Fecha')['Cantidad'].sum().reset_index()
ventas_diarias = ventas_diarias.sort_values('Fecha').set_index('Fecha').asfreq('D')

# Rellenar valores nulos mediante interpolación
ventas_diarias['Cantidad'].interpolate(method='time', inplace=True)

# Suavizar datos históricos con un promedio móvil de 7 días
ventas_diarias['Cantidad_Suavizada'] = ventas_diarias['Cantidad'].rolling(window=7, min_periods=1).mean()

# Modelo para predicción a corto plazo
modelo_corto = ExponentialSmoothing(
    ventas_diarias['Cantidad_Suavizada'],
    trend='additive',
    seasonal='multiplicative',
    seasonal_periods=7,
    initialization_method="estimated"
).fit()

# Predicción para los próximos 15 días (corto plazo)
prediccion_corta = modelo_corto.forecast(steps=15)

# Modelo para predicción a largo plazo
modelo_largo = ExponentialSmoothing(
    ventas_diarias['Cantidad_Suavizada'],
    trend='additive',
    seasonal='multiplicative',
    seasonal_periods=30,
    initialization_method="estimated"
).fit()

# Predicción para los próximos 30 días (largo plazo)
prediccion_larga = modelo_largo.forecast(steps=30)

# Combinar las predicciones en una sola serie
predicciones_combinadas = pd.concat([
    pd.Series(prediccion_corta, 
              index=pd.date_range(start=ventas_diarias.index[-1] + pd.Timedelta(days=1), periods=15, freq='D')),
    pd.Series(prediccion_larga, 
              index=pd.date_range(start=ventas_diarias.index[-1] + pd.Timedelta(days=16), periods=30, freq='D'))
])

# Graficar los resultados
plt.figure(figsize=(14, 8))

# Datos históricos
plt.plot(ventas_diarias.index, ventas_diarias['Cantidad_Suavizada'], label='Datos Históricos Suavizados', color='blue')

# Predicciones combinadas
plt.plot(predicciones_combinadas.index, predicciones_combinadas, label='Predicciones (15 días + 30 días)', color='orange')

# Configuración gráfica
plt.title('Predicción de Ventas Diarias de Boletos QR')
plt.xlabel('Fecha')
plt.ylabel('Cantidad de Boletos Vendidos')
plt.legend()
plt.xticks(rotation=45)
plt.grid(True)
plt.tight_layout()
plt.show()

ventas_diarias['Cantidad_Suavizada'].fillna(0, inplace=True)
predicciones_combinadas.fillna(0, inplace=True)

# Preparar los datos para exportación
data_json = {
    "historical": {
        "dates": ventas_diarias.index.strftime('%Y-%m-%d').tolist(),
        "values": ventas_diarias['Cantidad_Suavizada'].tolist()
    },
    "forecast": {
        "dates": predicciones_combinadas.index.strftime('%Y-%m-%d').tolist(),
        "values": predicciones_combinadas.tolist()
    }
}

# Guardar en un archivo JSON
with open('../assets/prediccion_ventas_diarias.json', 'w') as file:
    json.dump(data_json, file)

print("Datos exportados a prediccion_ventas_diarias.json")
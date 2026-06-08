"""
EXTRACTOR DE VACANTES - VERSIÓN DEFINITIVA (MUESTRA GRANDE + NICHOS)
"""
import pandas as pd
from jobspy import scrape_jobs
import time
from datetime import datetime

# ========== CONFIGURACIÓN ==========
PAISES_BUSQUEDA = [
    # Latinoamérica
    'Mexico', 'Colombia', 'Argentina', 'Chile', 'Peru', 
    'Uruguay', 'Costa Rica', 'Brazil',
    # Europa y Norteamérica
    'Spain', 'Canada', 'USA'
]

TERMINOS_BUSQUEDA = [
    # Generales
    "analista de datos junior",
    "data analyst junior",
    "analista de datos entry level",
    "junior data analyst",
    "data analyst intern",  # Pasantías (buena puerta de entrada)
    "intern data analyst",
    "practicante analista de datos",
    # Nichos específicos (TU VENTAJA COMPETITIVA)
    "sports data analyst",
    "food production data analyst",
    "analista de datos alimentos",
    "food industry data analyst",
    "supply chain data analyst junior",  # Relacionado con operaciones
    "logistics data analyst junior"
]

# ========== EXTRACCIÓN ==========
todas_vacantes = []
total_esperado = len(PAISES_BUSQUEDA) * len(TERMINOS_BUSQUEDA) * 150

print("=" * 70)
print("🚀 EXTRACCIÓN MASIVA DE VACANTES - DATA ANALYST JUNIOR")
print("=" * 70)
print(f"📌 {len(PAISES_BUSQUEDA)} países")
print(f"📌 {len(TERMINOS_BUSQUEDA)} términos de búsqueda")
print(f"📌 ~150 vacantes por término/portal")
print(f"📌 Total aproximado a extraer: {total_esperado:,}")
print("=" * 70)

contador_total = 0
errores = []

for pais in PAISES_BUSQUEDA:
    print(f"\n📍 PAÍS: {pais.upper()}")
    
    for termino in TERMINOS_BUSQUEDA:
        print(f"   🔎 Buscando: '{termino}'")
        
        try:
            jobs = scrape_jobs(
                site_name=["linkedin", "indeed"],  
                search_term=termino,
                location="",
                results_wanted=150,
                country_indeed=pais,
                is_remote=True,
                hours_old=720  # 30 días
            )
            
            if len(jobs) > 0:
                # Agregar metadatos
                jobs['pais_origen'] = pais
                jobs['termino_busqueda'] = termino
                jobs['fecha_extraccion'] = datetime.now().strftime('%Y-%m-%d')
                jobs['fuente_principal'] = pais  # Para compatibilidad
                
                todas_vacantes.append(jobs)
                contador_total += len(jobs)
                print(f"      ✅ +{len(jobs)} vacantes (Acumulado: {contador_total})")
            else:
                print(f"      ⚠️ 0 vacantes encontradas")
            
            # Pausa entre búsquedas
            time.sleep(2)
            
        except Exception as error:
            mensaje_error = f"{pais} - {termino}: {str(error)[:100]}"
            errores.append(mensaje_error)
            print(f"      ❌ Error: {error}")
    
    # Pausa entre países
    print(f"   ⏸️  Pausa de 5 segundos...")
    time.sleep(5)

# ========== PROCESAMIENTO FINAL ==========
print("\n" + "=" * 70)
print("🔄 PROCESANDO Y LIMPIANDO RESULTADOS...")
print("=" * 70)

if todas_vacantes:
    df_final = pd.concat(todas_vacantes, ignore_index=True)
    antes = len(df_final)
    
    # Eliminar duplicados (misma empresa + título + país)
    columnas_deduplicar = ['title', 'company', 'country']
    columnas_existentes = [col for col in columnas_deduplicar if col in df_final.columns]
    
    if columnas_existentes:
        df_final = df_final.drop_duplicates(subset=columnas_existentes, keep='first')
        print(f"   🧹 Eliminados {antes - len(df_final)} duplicados")
    
    # ========== MOSTRAR RESULTADOS ==========
    print("\n" + "=" * 70)
    print("📊 RESUMEN DE EXTRACCIÓN")
    print("=" * 70)
    print(f"✅ TOTAL DE VACANTES ÚNICAS: {len(df_final)}")
    
    print("\n📈 Vacantes por país:")
    print(df_final['pais_origen'].value_counts())
    
    print("\n📈 Top 10 términos de búsqueda con más resultados:")
    if 'termino_busqueda' in df_final.columns:
        print(df_final['termino_busqueda'].value_counts().head(10))
    
    print("\n📈 Muestra de títulos encontrados (nichos específicos):")
    titulos_nicho = df_final[df_final['title'].str.contains(
        'sports|food|production|supply|logistic|alimentos', 
        case=False, na=False
    )]['title'].head(10)
    for titulo in titulos_nicho:
        print(f"   • {titulo[:80]}")
    
    # ========== GUARDAR ARCHIVOS ==========
    # Archivo principal
    df_final.to_csv('vacantes_analista_junior_completo.csv', index=False)
    print("\n💾 Archivo guardado: vacantes_analista_junior_completo.csv")
    
    # Resumen por país (útil para análisis rápido)
    resumen_paises = df_final['pais_origen'].value_counts().reset_index()
    resumen_paises.columns = ['pais', 'cantidad_vacantes']
    resumen_paises.to_csv('resumen_vacantes_por_pais.csv', index=False)
    
    # ========== REPORTE DE ERRORES ==========
    if errores:
        print(f"\n⚠️ Se registraron {len(errores)} errores durante la extracción:")
        for error in errores[:5]:  # Mostrar solo primeros 5
            print(f"   • {error}")
    
    print("\n" + "=" * 70)
    print("🎉 EXTRACCIÓN COMPLETADA CON ÉXITO!")
    print("=" * 70)
    
else:
    print("\n❌ NO SE EXTRAJO NINGUNA VACANTE")
    print("Posibles causas: problemas de conexión, bloqueo de LinkedIn, o configuración incorrecta")

print("\n📌 Estadísticas finales:")
print(f"   • Países analizados: {len(PAISES_BUSQUEDA)}")
print(f"   • Términos de búsqueda: {len(TERMINOS_BUSQUEDA)}")
print(f"   • Vacantes únicas obtenidas: {len(df_final) if todas_vacantes else 0}")


"""
IMPORTADOR DE CSV A SQL SERVER
Ejecutar DESPUÉS de que termine el script de extracción
"""
import pandas as pd
import pyodbc

# Configuración de conexión a SQL Server
conn_str = (
    "Driver={ODBC Driver 17 for SQL Server};"
    "Server=localhost\\SQLEXPRESS;"  # Cambia si tu instancia es diferente
    "Database=JobMarketAnalysis;"
    "Trusted_Connection=yes;"
)

# Leer el CSV generado por el script
df = pd.read_csv('vacantes_analista_junior_completo.csv')

# Seleccionar solo las columnas que necesitamos
df_clean = df[['title', 'company', 'location', 'pais_origen', 
               'termino_busqueda', 'is_remote', 'date_posted', 
               'description', 'site']].copy()

# Renombrar columnas para que coincidan con la tabla
df_clean.columns = ['Titulo', 'Empresa', 'Ubicacion', 'PaisOrigen',
                    'TerminoBusqueda', 'EsRemota', 'FechaPublicacion',
                    'Descripcion', 'Fuente']

# Conectar a SQL Server y exportar
conn = pyodbc.connect(conn_str)
cursor = conn.cursor()

# Limpiar tabla existente (opcional)
cursor.execute("TRUNCATE TABLE JobPostings")

# Insertar filas (esto puede tomar 1-2 minutos)
for index, row in df_clean.iterrows():
    cursor.execute("""
        INSERT INTO JobPostings (Titulo, Empresa, Ubicacion, PaisOrigen, 
                                 TerminoBusqueda, EsRemota, FechaPublicacion, 
                                 Descripcion, Fuente)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, row.Titulo, row.Empresa, row.Ubicacion, row.PaisOrigen,
        row.TerminoBusqueda, row.EsRemota, row.FechaPublicacion,
        row.Descripcion, row.Fuente)

conn.commit()
conn.close()

print(f"✅ {len(df_clean)} vacantes importadas a SQL Server")

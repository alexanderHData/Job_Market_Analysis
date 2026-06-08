USE JobMarketAnalysis;
GO

-- Vista rápida de los datos


Select COUNT(*) AS totalVacantes,
       COUNT(DISTINCT pais_origen) AS totalPaises,
       MIN(date_posted) AS fecha_mas_antigua,
       MAX(date_posted) AS fecha_mas_reciente
FROM vacantes_import

-- Ver cuántas vacantes tienen URL disponible
SELECT 
    COUNT(*) as Total,
    SUM(CASE WHEN job_url IS NOT NULL THEN 1 ELSE 0 END) as ConJobUrl,
    SUM(CASE WHEN job_url_direct IS NOT NULL THEN 1 ELSE 0 END) as ConJobUrlDirect
FROM vacantes_import;

--Conseguir Vacantes recientes (a partir del 2024) y contemplar las vacantes remotas por pais.
SELECT 
    pais_origen,
    COUNT(*) as VacantesRemotas
FROM vacantes_import
WHERE 
    -- Español
    LOWER(description) LIKE '%remoto%'
    OR LOWER(description) LIKE '%teletrabajo%'
    OR LOWER(description) LIKE '%desde casa%'
    OR LOWER(description) LIKE '%home office%'
    -- Inglés
    OR LOWER(description) LIKE '%remote%'
    OR LOWER(description) LIKE '%work from home%'
    OR LOWER(description) LIKE '%wfh%'
    OR LOWER(description) LIKE '%anywhere%'
    OR LOWER(description) LIKE '%virtual%'
    OR LOWER(description) LIKE '%hybrid%'
    OR LOWER(description) LIKE '%hibrido%'
    OR LOWER(description) LIKE '%flexible%'
    -- En el título
    OR LOWER(title) LIKE '%remoto%'
    OR LOWER(title) LIKE '%remote%'
    OR LOWER(title) LIKE '%home%'
GROUP BY pais_origen
ORDER BY VacantesRemotas DESC;
--Investigaremos sobre las Skills mas demandadas
WITH SkillsAnalysis AS (
    SELECT 
        CASE 
            WHEN description LIKE '%SQL%' OR description LIKE '%sql%' THEN 'SQL'
            WHEN description LIKE '%Python%' OR description LIKE '%python%' THEN 'Python'
            WHEN description LIKE '%Power BI%' OR description LIKE '%power bi%' THEN 'Power BI'
            WHEN description LIKE '%Tableau%' OR description LIKE '%tableau%' THEN 'Tableau'
            WHEN description LIKE '%Excel%' OR description LIKE '%excel%' THEN 'Excel'
            WHEN description LIKE '%Pandas%' OR description LIKE '%pandas%' THEN 'Pandas'
            WHEN description LIKE '%ETL%' OR description LIKE '%etl%' THEN 'ETL'
            WHEN description LIKE '%DAX%' OR description LIKE '%dax%' THEN 'DAX'
        END as Skill
    FROM vacantes_import
    WHERE description IS NOT NULL
)
SELECT 
    Skill,
    COUNT(*) as Menciones
FROM SkillsAnalysis
WHERE Skill IS NOT NULL
GROUP BY Skill
ORDER BY Menciones DESC;

--Vacantes en el nicho de experiencia

SELECT 
   
    pais_origen,
    COUNT(*) as VacantesNicho
FROM vacantes_import
WHERE 
    is_remote = 'TRUE' AND
    (description LIKE '%food%' OR description LIKE '%aliment%')
    OR (description LIKE '%supply%' OR description LIKE '%logistic%')
    OR (title LIKE '%food%' OR title LIKE '%supply%')
  
GROUP BY pais_origen
ORDER BY VacantesNicho DESC;

--Vacantes que piden inglés

SELECT 
    pais_origen,
    COUNT(*) as VacantesConIngles
FROM vacantes_import
WHERE 
    description LIKE '%english%' 
    OR description LIKE '%inglés%'
    OR description LIKE '%bilingual%'
    OR title LIKE '%english%'
GROUP BY pais_origen
ORDER BY VacantesConIngles DESC;

 --Top empresas

SELECT TOP 20
    company,
    pais_origen,
    COUNT(*) as Vacantes
FROM vacantes_import
WHERE company IS NOT NULL AND company != ''
GROUP BY company, pais_origen
ORDER BY Vacantes DESC;

SELECT is_remote 
FROM vacantes_import


-- Vacantes por mes (últimos 12 meses)
SELECT 
    FORMAT(date_posted, 'yyyy-MM') as Mes,
    COUNT(*) as TotalVacantes
FROM vacantes_import
WHERE date_posted >= DATEADD(MONTH, -12, GETDATE())
GROUP BY FORMAT(date_posted, 'yyyy-MM')
ORDER BY Mes desc;

-- 2.1 Top skills por país (México, Colombia, Argentina, USA)
SELECT 
    pais_origen,
    SUM(CASE WHEN LOWER(description) LIKE '%sql%' THEN 1 ELSE 0 END) as SQL,
    SUM(CASE WHEN LOWER(description) LIKE '%python%' THEN 1 ELSE 0 END) as Python,
    SUM(CASE WHEN LOWER(description) LIKE '%power bi%' THEN 1 ELSE 0 END) as PowerBI,
    SUM(CASE WHEN LOWER(description) LIKE '%excel%' THEN 1 ELSE 0 END) as Excel,
    SUM(CASE WHEN LOWER(description) LIKE '%tableau%' THEN 1 ELSE 0 END) as Tableau,
    COUNT(*) as TotalVacantes
FROM vacantes_import
WHERE pais_origen IN ('Mexico', 'Colombia', 'Argentina', 'USA', 'Spain')
GROUP BY pais_origen
ORDER BY TotalVacantes DESC;

USE JobMarketAnalysis;
GO

-- 1.1 Porcentaje de vacantes que mencionan IA
SELECT 
    COUNT(*) as TotalVacantes,
    SUM(CASE 
        WHEN LOWER(description) LIKE '%ai%' 
          OR LOWER(description) LIKE '%artificial intelligence%'
          OR LOWER(description) LIKE '%machine learning%'
          OR LOWER(description) LIKE '%genai%'
          OR LOWER(description) LIKE '%llm%'
        THEN 1 ELSE 0 END) as VacantesConIA,
    ROUND(100.0 * SUM(CASE 
        WHEN LOWER(description) LIKE '%ai%' 
          OR LOWER(description) LIKE '%artificial intelligence%'
          OR LOWER(description) LIKE '%machine learning%'
          OR LOWER(description) LIKE '%genai%'
          OR LOWER(description) LIKE '%llm%'
        THEN 1 ELSE 0 END) / COUNT(*), 2) as PorcentajeIA
FROM vacantes_import;

-- 2.1 Desglose por tipo de habilidad IA
SELECT 
    'Machine Learning / AI General' as HabilidadIA,
    COUNT(*) as Menciones
FROM vacantes_import
WHERE LOWER(description) LIKE '%machine learning%' 
   OR LOWER(description) LIKE '%artificial intelligence%'
   OR LOWER(description) LIKE '%ai %'
   OR LOWER(description) LIKE '% %ai%'

UNION ALL

SELECT 
    'Generative AI (GenAI)',
    COUNT(*)
FROM vacantes_import
WHERE LOWER(description) LIKE '%generative ai%' 
   OR LOWER(description) LIKE '%genai%'
   OR LOWER(description) LIKE '%gen ai%'

UNION ALL

SELECT 
    'LLM / Large Language Models',
    COUNT(*)
FROM vacantes_import
WHERE LOWER(description) LIKE '%llm%' 
   OR LOWER(description) LIKE '%large language model%'

UNION ALL

SELECT 
    'Prompt Engineering',
    COUNT(*)
FROM vacantes_import
WHERE LOWER(description) LIKE '%prompt%' 
   OR LOWER(description) LIKE '%prompt engineering%'

UNION ALL

SELECT 
    'RAG (Retrieval-Augmented Generation)',
    COUNT(*)
FROM vacantes_import
WHERE LOWER(description) LIKE '%rag%' 
   OR LOWER(description) LIKE '%retrieval%'

UNION ALL

SELECT 
    'AI Agents / Agentic AI',
    COUNT(*)
FROM vacantes_import
WHERE LOWER(description) LIKE '%agent%' 
   AND LOWER(description) LIKE '%ai%'

UNION ALL

SELECT 
    'MLOps / LLMOps',
    COUNT(*)
FROM vacantes_import
WHERE LOWER(description) LIKE '%mlops%' 
   OR LOWER(description) LIKE '%llmops%'
   OR LOWER(description) LIKE '%model deployment%'

ORDER BY Menciones DESC;

-- 4.1 Países con mayor demanda de habilidades IA
SELECT 
    pais_origen,
    COUNT(*) as TotalVacantes,
    SUM(CASE 
        WHEN LOWER(description) LIKE '%ai%' 
          OR LOWER(description) LIKE '%machine learning%' 
          OR LOWER(description) LIKE '%genai%'
        THEN 1 ELSE 0 END) as VacantesConIA,
    ROUND(100.0 * SUM(CASE 
        WHEN LOWER(description) LIKE '%ai%' 
          OR LOWER(description) LIKE '%machine learning%' 
          OR LOWER(description) LIKE '%genai%'
        THEN 1 ELSE 0 END) / COUNT(*), 2) as PorcentajeIA
FROM vacantes_import
WHERE pais_origen IN ('Mexico', 'Colombia', 'Argentina', 'USA', 'Spain', 'Canada')
GROUP BY pais_origen
ORDER BY PorcentajeIA DESC;
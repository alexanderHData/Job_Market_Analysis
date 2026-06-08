TRUNCATE TABLE JobPostings;
GO

ALTER TABLE JobPostings ADD job_url NVARCHAR(1000);
ALTER TABLE JobPostings ADD job_url_direct NVARCHAR(1000);
ALTER TABLE JobPostings ADD job_id NVARCHAR(100);
ALTER TABLE JobPostings ADD date_posted DATE;
ALTER TABLE JobPostings ADD company_industry NVARCHAR(500);
ALTER TABLE JobPostings ADD skills NVARCHAR(MAX);
GO

USE JobMarketAnalysis;
GO

-- Eliminar la tabla completamente
DROP TABLE IF EXISTS vacantes_analista_junior_completo;
GO

-- Crear la tabla NUEVA con las columnas correctas
CREATE TABLE vacantes_analista_junior_completo (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    job_id NVARCHAR(100) NULL,
    site NVARCHAR(100) NULL,
    job_url NVARCHAR(MAX) NULL,           -- MAX para URLs largas
    job_url_direct NVARCHAR(MAX) NULL,    -- MAX para URLs largas
    title NVARCHAR(500) NULL,
    company NVARCHAR(500) NULL,
    location NVARCHAR(500) NULL,
    date_posted DATE NULL,
    job_type NVARCHAR(100) NULL,
    is_remote BIT NULL,
    description NVARCHAR(MAX) NULL,
    company_industry NVARCHAR(500) NULL,
    company_url NVARCHAR(2000) NULL,
    company_logo NVARCHAR(2000) NULL,
    company_url_direct NVARCHAR(2000) NULL,
    company_addresses NVARCHAR(MAX) NULL,
    company_num_employees NVARCHAR(200) NULL,
    company_revenue NVARCHAR(200) NULL,
    company_description NVARCHAR(MAX) NULL,
    skills NVARCHAR(MAX) NULL,
    pais_origen NVARCHAR(100) NULL
);
GO


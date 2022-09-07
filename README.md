*v. 0.0.1* (Pre-lanzamiento)

\[![DOI]()

# kfre-ckd-reba-peru

<!-- badges: start -->

<!-- badges: end -->

La meta de `kfre-ckd-reba-peru` es registrar la gestión de datos y flujo de análisis estadístico utilizado para el estudio titulado: **"Predicción de Falla Renal: Validación Externa Multicéntrica del Modelo KFRE en Pacientes con ERC en Estadíos 3-4"**

### Declaración de intercambio de datos

Los datos anónimizados que respaldan los hallazgos de este estudio están disponibles a solicitud razonable siguiendo los requisitos institucionales. El código limpio y de análisis está disponible en este repositorio de GitHub.

### Carpetas y archivos:

-   `Code/`: Carpeta con código reproducible para generar resultados (tablas y figura).

    -   `0_Importing_Cleaning.R`: Archivo R script con código para importación y limpieza de datos.

    -   `R/`: Carpeta con funciones útiles para análisis del estudio.

        -   `fit_modcal.R`: Función para estimar IC95% bootstrap de ICI y E50.

        -   `roystonD.R`: Estima estadístico D de Royston.

        -   `stdca.R`: Crea curvas de beneficio neto.

-   `Figures/`: Carpeta con figuras de resultados.

    -   `Plot_CIF.png`: Figura 3 en inglés.

    -   `Plot_CIF_Spanish.png`: Figura 3 presentada en manuscrito.

    -   `Plot_Calibration.png`: Figura 4 en inglés.

    -   `Plot_Calibration_Spanish.png`: Figura 4 presentada en manuscrito.

    -   `plot_decision_curve.png`: Figura de análisis de curva de decisión.

-   `Tables/`: Carpeta con tablas de resultados.

    -   `Table1.docx`: Tabla 1.

    -   `Table2.docx`: Tabla 2.

    -   `TableS1.docx`: Tabla S1.

    -   `TableS2.docx`: Tabla S2.

    -   `TableS3.docx`: Tabla S3.

    -   `TableS4.docx`: Tabla S4.

-   `renv/`: Carpeta con paquetes usados para análisis.

-   `Peru_EsSalud_Lima_Falla_Renal.qmd`: Archivo quarto con código y texto detallado del análisis estadístico realizado

-   `Peru_EsSalud_Lima_Falla_Renal.html`: Archivo html con reporte detallado de análisis estadístico.

-   `renv.lock`: Archivo renv.lock con lista de paquetes y versiones usadas para garantizar reproducibilidad del código.

***Nota:*** Las tablas y su numeración fueron readaptadas para el manuscrito final.

### Acerca de la versión

Esta es una versión preliminar del repositorio final que estará disponible en el futuro. El manuscrito final todavía está terminando de refinar su redacción antes de su envío a alguna revista científica.

### Como citar

> **Citar**: Soto-Becerra P. kfre-ckd-reba-peru \[Internet\]. Zenodo; 2022 \[cited 2022 Set 22\]. Available from:

# 🚀 Instrucciones para Crear el Repositorio en GitHub

## Paso 1: Crear el Repositorio en GitHub

1. Ve a https://github.com/new
2. **Repository name:** `rlm-presentation`
3. **Description:** `Recursive Language Models: From Theory to Practice - Technical Presentation`
4. **Visibility:** ✅ Public
5. ❌ NO marques "Add a README file" (ya lo tenemos)
6. Click **"Create repository"**

## Paso 2: Preparar los Archivos Localmente

```bash
# Crea un directorio nuevo
mkdir rlm-presentation
cd rlm-presentation

# Inicializa git
git init

# Crea la estructura de directorios
mkdir -p .github/workflows
mkdir -p assets
```

## Paso 3: Copiar los Archivos

Copia estos archivos al directorio `rlm-presentation/`:

```
rlm-presentation/
├── rlm-presentation.md          # La presentación principal
├── README.md                    # El README que generé
├── package.json                 # Scripts de build
├── .gitignore                   # Archivos a ignorar
└── .github/
    └── workflows/
        └── build.yml            # GitHub Actions (renombrar)
```

**IMPORTANTE:** Renombra el archivo:
```bash
# El archivo se llama .github-workflows-build.yml
# Necesitas moverlo a la ubicación correcta
mv .github-workflows-build.yml .github/workflows/build.yml
```

## Paso 4: Personalizar los Archivos

### En `README.md`:
Reemplaza `[your-username]` con tu username de GitHub en todas las URLs.

Ejemplo:
```markdown
# Antes:
https://github.com/[your-username]/rlm-presentation

# Después:
https://github.com/antoniomartinez/rlm-presentation
```

### En `package.json`:
Actualiza el campo `author` y las URLs del repository.

## Paso 5: Commit y Push

```bash
# Añadir todos los archivos
git add .

# Primer commit
git commit -m "Initial commit: RLM presentation with auto-build"

# Conectar con GitHub (reemplaza YOUR-USERNAME)
git remote add origin https://github.com/YOUR-USERNAME/rlm-presentation.git

# Renombrar branch a main (si es necesario)
git branch -M main

# Push
git push -u origin main
```

## Paso 6: Habilitar GitHub Pages

1. Ve a tu repositorio en GitHub
2. Click en **Settings**
3. En el menú lateral, click en **Pages**
4. En **Source**, selecciona:
   - **Source:** Deploy from a branch
   - **Branch:** `gh-pages` (se creará automáticamente)
5. Click **Save**

**Nota:** GitHub Actions creará automáticamente el branch `gh-pages` en el primer push.

## Paso 7: Verificar el Build

1. Ve a la pestaña **Actions** en tu repositorio
2. Deberías ver el workflow "Build and Deploy Presentation" corriendo
3. Espera a que termine (icono verde ✅)
4. Tu presentación estará disponible en:
   ```
   https://YOUR-USERNAME.github.io/rlm-presentation/
   ```

## Paso 8: (Opcional) Añadir Assets

Si tienes imágenes o diagramas:

```bash
# Copia tus imágenes al directorio assets/
cp algorithm1.png assets/
cp algorithm2.png assets/
cp benchmark-graph.png assets/

# Commit
git add assets/
git commit -m "Add presentation assets"
git push
```

Luego actualiza `rlm-presentation.md` para referenciarlas:
```markdown
![Algorithm 1](./assets/algorithm1.png)
```

## 🎉 ¡Listo!

Tu presentación ahora está:
- ✅ En GitHub: `https://github.com/YOUR-USERNAME/rlm-presentation`
- ✅ Publicada online: `https://YOUR-USERNAME.github.io/rlm-presentation/`
- ✅ Con auto-build en cada push
- ✅ PDF descargable automáticamente generado

## 🔄 Workflow de Desarrollo

```bash
# Edita la presentación
nano rlm-presentation.md

# Preview local (opcional)
marp -p rlm-presentation.md

# Commit y push
git add rlm-presentation.md
git commit -m "Update presentation: add new benchmarks"
git push

# GitHub Actions automáticamente:
# 1. Genera el HTML
# 2. Genera el PDF
# 3. Publica en GitHub Pages
```

## 🐛 Troubleshooting

### El workflow falla
- Verifica que el archivo esté en `.github/workflows/build.yml` (no `.github-workflows-build.yml`)
- Verifica que GitHub Pages esté habilitado en Settings

### GitHub Pages no muestra la presentación
- Espera 2-3 minutos después del primer push
- Verifica en Settings > Pages que esté configurado correctamente
- La URL es: `https://YOUR-USERNAME.github.io/rlm-presentation/` (con trailing slash)

### El PDF no se genera
- Esto es normal si tienes imágenes locales sin el flag `--allow-local-files`
- Verifica que las rutas de las imágenes sean relativas (`./assets/` no `/assets/`)

## 📝 Comandos Útiles

```bash
# Ver el estado del repo
git status

# Ver el historial
git log --oneline

# Actualizar solo un archivo
git add rlm-presentation.md
git commit -m "Update slide 15"
git push

# Ver workflows en terminal
gh run list  # Requiere GitHub CLI

# Descargar artefactos localmente
gh run download  # Descarga HTML y PDF generados
```

## 🌟 Próximos Pasos

1. **Compartir:** Comparte la URL pública de tu presentación
2. **Mejorar:** Añade las imágenes y gráficos de los benchmarks
3. **Actualizar:** Completa las slides TODO (vanilla vs post-trained)
4. **Extender:** Añade slides adicionales según tu audiencia

---

**¿Necesitas ayuda?** Abre un issue en el repositorio o consulta la [documentación de Marp](https://marp.app/).

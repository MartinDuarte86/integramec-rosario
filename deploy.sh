#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Deploy — IntegraMec Rosario SRL · GitHub Pages
#  Autor: Martín Duarte
#  Uso  : bash deploy.sh
# ─────────────────────────────────────────────────────────────
set -euo pipefail

GITHUB_USER="MartinDuarte86"
REPO_NAME="integramec-rosario"
REMOTE_URL="https://github.com/${GITHUB_USER}/${REPO_NAME}.git"
PAGES_URL="https://${GITHUB_USER}.github.io/${REPO_NAME}/"

print_step() { echo ""; echo "  [$1/7] $2"; }
print_ok()   { echo "        ✓ $1"; }

echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║   IntegraMec Rosario — Deploy a GitHub Pages    ║"
echo "  ╚══════════════════════════════════════════════════╝"

# ── Paso 1 — Git init ────────────────────────────────────────
print_step 1 "Verificando repositorio git..."
if [ ! -d ".git" ]; then
  git init
  print_ok "Repositorio inicializado."
else
  print_ok "Repositorio ya existe."
fi

# ── Paso 2 — GitHub CLI auth ─────────────────────────────────
print_step 2 "Verificando autenticación de GitHub CLI..."
if ! gh auth status 2>/dev/null; then
  echo ""
  echo "  ERROR: No estás autenticado en GitHub CLI."
  echo "         Ejecutá: gh auth login"
  exit 1
fi
print_ok "Autenticación de gh válida."

# ── Paso 3 — Remote ──────────────────────────────────────────
print_step 3 "Configurando remote origin → ${REMOTE_URL}"
if git remote get-url origin &>/dev/null; then
  git remote set-url origin "$REMOTE_URL"
  print_ok "Remote actualizado."
else
  git remote add origin "$REMOTE_URL"
  print_ok "Remote agregado."
fi

# ── Paso 4 — Staging ─────────────────────────────────────────
print_step 4 "Agregando archivos al staging..."
git add index.html propuesta-1.html propuesta-2.html propuesta-3.html
[ -d "doc" ] && git add doc/ && print_ok "Carpeta doc/ incluida."
[ -d "img" ] && git add img/ && print_ok "Carpeta img/ incluida."
print_ok "Staging completo."

# ── Paso 5 — Commit ──────────────────────────────────────────
print_step 5 "Creando commit..."
if git diff --cached --quiet; then
  print_ok "Sin cambios nuevos para commitear."
else
  git commit -m "feat: deploy multi-page hub with 3 design alternatives"
  print_ok "Commit creado."
fi

# ── Paso 6 — Branch rename + push ────────────────────────────
print_step 6 "Renombrando rama a 'main' y haciendo push..."
git branch -M main
git push -u origin main --force
print_ok "Push exitoso → origin/main"

# ── Paso 7 — Activar GitHub Pages vía API ────────────────────
print_step 7 "Activando GitHub Pages (branch: main, path: /)..."
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  "/repos/${GITHUB_USER}/${REPO_NAME}/pages" \
  -f source='{"branch":"main","path":"/"}' \
  --silent 2>/dev/null \
|| \
gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  "/repos/${GITHUB_USER}/${REPO_NAME}/pages" \
  -f source='{"branch":"main","path":"/"}' \
  --silent 2>/dev/null \
|| true
print_ok "GitHub Pages configurado."

echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║   DEPLOY COMPLETADO                             ║"
echo "  ║                                                 ║"
echo "  ║   URL de GitHub Pages:                         ║"
echo "  ║   ${PAGES_URL}"
echo "  ║                                                 ║"
echo "  ║   Puede tardar 1-3 minutos en activarse.       ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""

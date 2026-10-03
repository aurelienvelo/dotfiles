#!/bin/sh
# Compat : les configs déployées AVANT le déplacement du hook pointent encore
# vers ce chemin (hooks.read-source-state.pre). Comme ce hook s'exécute avant
# la lecture de la source, chezmoi ne peut pas se réparer seul : on délègue
# au hook réel pour ne bloquer aucune machine pas encore ré-appliquée.
# Supprimable quand tous les appareils ont fait un `chezmoi apply`.
set -eu
exec "$(dirname "$0")/../.chezmoihooks/install-password-manager.sh" "$@"

#!/bin/bash

# Définir le commit et les URLs
COMMIT="dc96b837cf6bb4af9cd736aa3af08cf8279f7685"
BASE_URL="https://update.code.visualstudio.com/commit:$COMMIT"
CLI_URL="$BASE_URL/cli-alpine-x64/stable"
SERVER_URL="$BASE_URL/server-linux-x64/stable"

# Répertoires et fichiers de destination
VSCODE_DIR="$HOME/.vscode-server"
CLI_DIR="$VSCODE_DIR/cli/servers/Stable-$COMMIT"
CLI_TAR="vscode-cli.tar.gz"
SERVER_TAR="vscode-server.tar.gz"

# Téléchargement des archives
wget -O $CLI_TAR $CLI_URL
wget -O $SERVER_TAR $SERVER_URL

# Création des répertoires nécessaires
mkdir -p $CLI_DIR

# Extraction des archives
cd $VSCODE_DIR
tar -xzf ~/$CLI_TAR
mv code "code-$COMMIT"

# Aller dans le répertoire du serveur
cd $CLI_DIR
tar -xzf ~/$SERVER_TAR
mv vscode-server-linux-x64 server

# Nettoyer les fichiers tar téléchargés
rm ~/$CLI_TAR ~/$SERVER_TAR

#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Ошибка: Нужно 2 аргумента"
    echo "Использование: ./builder.sh <github-репо> <dockerhub-репо>"
    exit 1
fi

GITHUB_REPO=$1
DOCKER_REPO=$2
TEMP_DIR="temp_$$"

echo "📦 Клонирование $GITHUB_REPO..."

# Используем системный Git
/usr/bin/git clone "https://github.com/$GITHUB_REPO.git" "$TEMP_DIR"

if [ $? -ne 0 ]; then
    echo "❌ Ошибка клонирования"
    exit 1
fi

cd "$TEMP_DIR"

if [ ! -f "Dockerfile" ]; then
    echo "❌ Dockerfile не найден"
    cd .. && rm -rf "$TEMP_DIR"
    exit 1
fi

echo "🐳 Сборка образа..."
docker build -t "$DOCKER_REPO:latest" .

if [ $? -ne 0 ]; then
    echo "❌ Ошибка сборки"
    cd .. && rm -rf "$TEMP_DIR"
    exit 1
fi

echo "🚀 Публикация на Docker Hub..."
docker push "$DOCKER_REPO:latest"

cd ..
rm -rf "$TEMP_DIR"

echo "✅ Готово! Образ: $DOCKER_REPO:latest"

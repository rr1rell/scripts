#!/bin/bash

# Проверка аргументов
if [ $# -ne 2 ]; then
    echo "Ошибка: Необходимо указать 2 аргумента"
    echo "Использование: builder <github-репо> <dockerhub-репо>"
    exit 1
fi

GITHUB_REPO=$1
DOCKER_REPO=$2
TEMP_DIR="temp_$$"

# Вход в Docker Hub (используем переменные окружения)
echo "🔐 Вход в Docker Hub..."
echo "$DOCKER_PWD" | docker login -u "$DOCKER_USER" --password-stdin

if [ $? -ne 0 ]; then
    echo "❌ Ошибка: Не удалось войти в Docker Hub"
    exit 1
fi

echo "📦 Клонирование $GITHUB_REPO..."

# Клонирование репозитория
git clone "https://github.com/$GITHUB_REPO.git" "$TEMP_DIR"

if [ $? -ne 0 ]; then
    echo "❌ Ошибка: Не удалось клонировать репозиторий"
    exit 1
fi

cd "$TEMP_DIR"

# Проверка наличия Dockerfile
if [ ! -f "Dockerfile" ]; then
    echo "❌ Ошибка: Dockerfile не найден"
    cd .. && rm -rf "$TEMP_DIR"
    exit 1
fi

echo "🐳 Сборка образа $DOCKER_REPO:latest..."
docker build -t "$DOCKER_REPO:latest" .

if [ $? -ne 0 ]; then
    echo "❌ Ошибка: Не удалось собрать образ"
    cd .. && rm -rf "$TEMP_DIR"
    exit 1
fi

echo "🚀 Публикация на Docker Hub..."
docker push "$DOCKER_REPO:latest"

cd ..
rm -rf "$TEMP_DIR"

echo "✅ Готово! Образ: $DOCKER_REPO:latest"

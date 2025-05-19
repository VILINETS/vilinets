 #!/bin/bash

# 🌱 Semilla para generar el MÓDULO_BOT de VILINETS

MODULO="modulo_bot"
BASE_DIR="modulos_generados/$MODULO"
mkdir -p "$BASE_DIR"

echo "📦 Generando estructura para $MODULO..."

# Crear archivo principal
cat > "$BASE_DIR/bot.py" <<EOF
import time

def main():
    while True:
        print("🤖 BOT operativo y esperando instrucciones...")
        time.sleep(10)

if __name__ == "__main__":
    main()
EOF

# Dockerfile
cat > "$BASE_DIR/Dockerfile" <<EOF
FROM python:3.10-slim
WORKDIR /app
COPY bot.py .
CMD ["python", "bot.py"]
EOF

# Manifiesto K3s
cat > "$BASE_DIR/deployment.yaml" <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $MODULO
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $MODULO
  template:
    metadata:
      labels:
        app: $MODULO
    spec:
      containers:
      - name: $MODULO
        image: $MODULO:latest
        imagePullPolicy: Never
EOF

# Construcción e implementación
cd "$BASE_DIR"
docker build -t $MODULO:latest .
kubectl apply -f deployment.yaml

echo "✅ Semilla $MODULO ejecutada correctamente."

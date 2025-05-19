 #!/bin/bash

# 🌱 Semilla para generar el MÓDULO_RAM (FRAM-IA)

MODULO="modulo_ram"
BASE_DIR="modulos_generados/$MODULO"
mkdir -p "$BASE_DIR"

echo "📦 Generando estructura para $MODULO..."

# Simulador de buffer RAM-IA
cat > "$BASE_DIR/ram.py" <<EOF
import time

buffer = []

def simular_ram():
    global buffer
    print("⚡ RAM-IA activa. Simulando buffer lógico...")
    while True:
        buffer.append("📥 Entrada temporal")
        if len(buffer) > 10:
            buffer.pop(0)
        print("🧠 RAM:", buffer)
        time.sleep(5)

if __name__ == "__main__":
    simular_ram()
EOF

# Dockerfile
cat > "$BASE_DIR/Dockerfile" <<EOF
FROM python:3.10-slim
WORKDIR /app
COPY ram.py .
CMD ["python", "ram.py"]
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

cd "$BASE_DIR"
docker build -t $MODULO:latest .
kubectl apply -f deployment.yaml

echo "✅ Semilla $MODULO ejecutada correctamente."

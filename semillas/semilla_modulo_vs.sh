 #!/bin/bash

# 🌱 Semilla para generar el MÓDULO_VS (Vector Store)

MODULO="modulo_vs"
BASE_DIR="modulos_generados/$MODULO"
mkdir -p "$BASE_DIR"

echo "📦 Generando estructura para $MODULO..."

# Código base FAISS
cat > "$BASE_DIR/vs.py" <<EOF
import faiss
import numpy as np

dim = 128
index = faiss.IndexFlatL2(dim)

print("🧠 Módulo Vector Store FAISS activo.")
print("Índice creado con dimensión:", dim)
EOF

# Dockerfile
cat > "$BASE_DIR/Dockerfile" <<EOF
FROM python:3.10-slim
WORKDIR /app
COPY vs.py .
RUN pip install faiss-cpu
CMD ["python", "vs.py"]
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

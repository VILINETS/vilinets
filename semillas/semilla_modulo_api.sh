#!/bin/bash

# 🌱 Semilla para generar el MÓDULO_API de VILINETS

MODULO="modulo_api"
BASE_DIR="modulos_generados/$MODULO"
mkdir -p "$BASE_DIR"

echo "📦 Generando estructura para $MODULO..."

# Crear archivo principal del módulo
cat > "$BASE_DIR/app.py" <<EOF
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/status', methods=['GET'])
def status():
    return jsonify({"status": "MÓDULO_API activo"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
EOF

# Crear Dockerfile
cat > "$BASE_DIR/Dockerfile" <<EOF
FROM python:3.10-slim
WORKDIR /app
COPY app.py .
RUN pip install flask==2.2.5
EXPOSE 8000
CMD ["python", "app.py"]
EOF

# Crear manifiesto K3s básico (Deployment + Service)
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
        ports:
        - containerPort: 8000
---
apiVersion: v1
kind: Service
metadata:
  name: $MODULO-service
spec:
  selector:
    app: $MODULO
  ports:
    - protocol: TCP
      port: 8000
      targetPort: 8000
  type: NodePort
EOF

# Construir imagen e implementar
cd "$BASE_DIR"
docker build -t $MODULO:latest .
kubectl apply -f deployment.yaml

echo "✅ Semilla $MODULO ejecutada correctamente."
 

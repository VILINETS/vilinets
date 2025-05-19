 #!/bin/bash

# 🌱 Semilla para generar el MÓDULO_DB

MODULO="modulo_db"
BASE_DIR="modulos_generados/$MODULO"
mkdir -p "$BASE_DIR"

echo "📦 Generando estructura para $MODULO..."

# Crear script de inicio para base de datos SQLite
cat > "$BASE_DIR/db.py" <<EOF
import sqlite3

conn = sqlite3.connect('vilinets.db')
cursor = conn.cursor()
cursor.execute("CREATE TABLE IF NOT EXISTS logs (id INTEGER PRIMARY KEY AUTOINCREMENT, mensaje TEXT)")
conn.commit()
conn.close()

print("🗃️ Base de datos 'vilinets.db' creada.")
EOF

# Dockerfile
cat > "$BASE_DIR/Dockerfile" <<EOF
FROM python:3.10-slim
WORKDIR /app
COPY db.py .
CMD ["python", "db.py"]
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

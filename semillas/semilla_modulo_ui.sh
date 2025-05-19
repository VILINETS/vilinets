 #!/bin/bash

# 🌱 Semilla para generar el MÓDULO_UI de VILINETS

MODULO="modulo_ui"
BASE_DIR="modulos_generados/$MODULO"
mkdir -p "$BASE_DIR"

echo "📦 Generando estructura para $MODULO..."

# Crear archivo principal de interfaz con Tkinter básico
cat > "$BASE_DIR/ui.py" <<EOF
import tkinter as tk

def lanzar_interfaz():
    root = tk.Tk()
    root.title("Interfaz VILINETS")
    root.geometry("400x200")

    etiqueta = tk.Label(root, text="Bienvenido al sistema VILINETS", font=("Arial", 14))
    etiqueta.pack(pady=20)

    root.mainloop()

if __name__ == "__main__":
    lanzar_interfaz()
EOF

# Dockerfile
cat > "$BASE_DIR/Dockerfile" <<EOF
FROM python:3.10
RUN apt update && apt install -y python3-tk
WORKDIR /app
COPY ui.py .
CMD ["python", "ui.py"]
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

echo "✅ Semilla $MODULO creada. Interfaz gráfica inicial lista."

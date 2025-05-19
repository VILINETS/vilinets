 #!/bin/bash

# === CIGOTO VILINETS ===
# Nodo maestro o worker con control distribuido

# === 1. CARGAR CONFIGURACIÓN ===
source configuracion/versions.conf
source configuracion/use_flags.env

# === 2. DETECTAR ROL DEL NODO ===
ROL=""
MAESTRO_IP=""
for arg in "$@"; do
  case $arg in
    --rol=*) ROL="${arg#*=}" ;;
    --maestro_ip=*) MAESTRO_IP="${arg#*=}" ;;
  esac
done

if [[ "$ROL" == "" ]]; then
  echo "[ERROR] Debes especificar --rol=maestro o --rol=worker"
  exit 1
fi

# === 3. INSTALAR DEPENDENCIAS BASE ===
echo "Instalando dependencias base del sistema..."
sudo apt update
sudo apt install -y curl wget gnupg lsb-release ca-certificates apt-transport-https software-properties-common python${PYTHON_VERSION} python3-pip openssh-client
echo "Dependencias del sistema instaladas."

# === 4. INSTALAR DOCKER ===
echo "Instalando Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
echo "Docker instalado."

# === 5. INSTALAR K3S SEGÚN ROL ===
if [[ "$ROL" == "maestro" ]]; then
  echo "Instalando K3s como nodo maestro..."
  curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=$K3S_CHANNEL sh -
  mkdir -p ~/.kube
  sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
  sudo chown $USER:$USER ~/.kube/config
  echo "Nodo maestro instalado. kubeconfig listo."

elif [[ "$ROL" == "worker" ]]; then
  if [[ "$MAESTRO_IP" == "" ]]; then
    echo "[ERROR] Debes especificar --maestro_ip=IP_DEL_MAESTRO en modo worker"
    exit 1
  fi
  echo "Instalando K3s como nodo worker..."
  TOKEN=$(ssh root@$MAESTRO_IP "sudo cat /var/lib/rancher/k3s/server/node-token")
  curl -sfL https://get.k3s.io | K3S_URL=https://$MAESTRO_IP:6443 K3S_TOKEN=$TOKEN INSTALL_K3S_CHANNEL=$K3S_CHANNEL sh -
  mkdir -p ~/.kube
  scp root@$MAESTRO_IP:/etc/rancher/k3s/k3s.yaml ~/.kube/config
  sed -i "s/127.0.0.1/$MAESTRO_IP/g" ~/.kube/config
  echo "Nodo worker instalado. Control habilitado desde este nodo."
fi

# === 6. INSTALAR LIBRERÍAS PYTHON ===
echo "Instalando librerías de Python necesarias..."
pip install --upgrade pip
pip install flask==${FLASK_VERSION} fastapi==${FASTAPI_VERSION} transformers==${TRANSFORMERS_VERSION} torch==${TORCH_VERSION} pandas==${PANDAS_VERSION} websockets==${WEBSOCKETS_VERSION} sqlalchemy==${SQLALCHEMY_VERSION} ${FAISS_BACKEND}
echo "Librerías Python instaladas."

# === 7. EJECUTAR SEMILLAS ===
echo "Ejecutando semillas activas..."
for semilla in semillas/*.sh; do
    if [[ -x "$semilla" ]]; then
        echo "Ejecutando $semilla ..."
        bash "$semilla"
    fi
done

echo "Instalación y despliegue completados. VILINETS está activo."
exit 0

### `README.md`

```md
# Proyecto Conecta Cartagena - Backend con Directus en Docker, AWS EC2, Ansible y Terraform

Este proyecto utiliza **Directus** como CMS para gestionar los datos de la aplicación **Conecta Cartagena**. Se ejecuta en un contenedor Docker y se despliega en una instancia EC2 de AWS. El despliegue y la infraestructura se gestionan mediante **Ansible** y **Terraform**.

## Arquitectura

La arquitectura del proyecto está diseñada de la siguiente manera:

1. **AWS CloudFront** distribuye las peticiones web.
2. **Lambda Functions** gestionan el registro de usuarios y los análisis de IA.
3. **EC2 Instance** ejecuta **Directus** en un contenedor Docker.
4. **RDS Postgres** se utiliza como base de datos para Directus.
5. **Terraform** gestiona la infraestructura en AWS.
6. **Ansible** automatiza la configuración y el despliegue de Directus en la instancia EC2.

![Arquitectura](./directus/backend/extensions/uploads/tu-diagrama.png)

## Requisitos previos

Asegúrate de cumplir con los siguientes requisitos antes de iniciar el proyecto:

- **Docker** instalado en tu máquina local.
- **Ansible** y **Terraform** instalados:
  - Terraform versión >= 0.12.x
  - Ansible versión >= 2.9.x
- **AWS CLI** configurado con las credenciales correctas.
- **Cuenta de AWS** con permisos para crear instancias de EC2, RDS y otros recursos necesarios.

## Instrucciones de Configuración

### 1. Clonar el repositorio

Clona el repositorio para obtener el código fuente del proyecto:

```bash
git clone https://github.com/tu-usuario/ConectaCartagena-backend.git
cd ConectaCartagena-backend
```

### 2. Configuración de Terraform

1. Ve al directorio `terraform/`:

```bash
cd terraform/
```

2. Modifica los archivos `main.tf`, `providers.tf` y otros necesarios para añadir tus configuraciones de AWS (por ejemplo, VPC, subnets, AMIs, etc.).

3. Inicializa Terraform y aplica el plan de infraestructura:

```bash
terraform init
terraform apply
```

Esto creará una instancia de EC2, un grupo de seguridad y configurará el entorno de red en AWS.

### 3. Configuración de Ansible

1. Ve al directorio `terraform/` y abre el archivo de inventario dinámico `dynamic_inventory.ini` para asegurarte de que la IP de la instancia EC2 está bien configurada.

2. Instala Docker y Directus en la instancia EC2 utilizando el playbook de Ansible:

```bash
ansible-playbook -i dynamic_inventory.ini install-docker-ansible.yml
```

Este playbook instalará Docker y configurará Directus en la instancia EC2.

### 4. Despliegue de Docker

1. Navega al directorio `directus/backend` y ejecuta Docker Compose:

```bash
cd directus/backend
docker-compose up -d
```

Esto levantará el contenedor de **Directus**.

### 5. Configuración de Directus

Directus estará disponible en la dirección IP pública de la instancia EC2 creada por Terraform. Puedes acceder a la interfaz web de Directus en la siguiente URL:

```bash
http://<ec2_public_ip>:8055
```

Inicia sesión con las credenciales de administrador que configures en el proceso de instalación.

## Gestión del Proyecto

### Variables de Entorno

Asegúrate de que el archivo `.env` en el directorio `directus/backend/extensionsDev` está configurado correctamente. Algunas variables importantes:

```bash
BASE_URL=http://localhost:8055
DB_CLIENT=pg
DB_HOST=your-rds-endpoint.amazonaws.com
DB_PORT=5432
DB_USER=directus
DB_PASSWORD=yourpassword
DB_DATABASE=directus
```

### Subir extensiones a Directus

1. Coloca tus extensiones personalizadas en el directorio `directus/backend/extensions/`.
2. Reinicia el contenedor Docker para aplicar los cambios:

```bash
docker-compose restart
```

### Conectar con RDS

El proyecto utiliza **Amazon RDS** para la base de datos PostgreSQL. Asegúrate de que las credenciales de la base de datos están configuradas correctamente en Directus y en el archivo `.env`.

## Desplegando Actualizaciones

Para desplegar actualizaciones del código backend o del contenedor de Directus, simplemente haz un pull del repositorio y vuelve a ejecutar Docker Compose:

```bash
git pull origin main
docker-compose up -d --build
```

## Solución de Problemas

### 1. Error de conexión con la base de datos RDS
- Verifica que la instancia de RDS está activa y accesible desde la instancia EC2.
- Asegúrate de que los grupos de seguridad permiten conexiones a PostgreSQL (puerto 5432).

### 2. Docker no inicia los contenedores
- Asegúrate de que Docker está instalado correctamente en la instancia EC2.
- Verifica los logs del contenedor usando:

```bash
docker logs <nombre_del_contenedor>
```

### 3. Problemas de permisos en Ansible
- Asegúrate de que la clave SSH que estás utilizando tiene acceso a la instancia EC2.

## Recursos Adicionales

- [Documentación de Directus](https://docs.directus.io/)
- [Documentación de Terraform](https://www.terraform.io/docs/index.html)
- [Documentación de Ansible](https://docs.ansible.com/)

## Licencia

Este proyecto está bajo la licencia MIT.
```

### Explicación de las secciones:

1. **Arquitectura**: Describe la arquitectura general del proyecto utilizando **AWS**, **Directus**, **Lambda** y **Postgres**. Se incluye una imagen de la arquitectura como referencia.
   
2. **Requisitos previos**: Lista de dependencias necesarias como Docker, Ansible, Terraform, AWS CLI y Java.

3. **Instrucciones de configuración**: Proporciona instrucciones paso a paso para:
   - Clonar el proyecto.
   - Configurar Terraform para crear la infraestructura de AWS.
   - Configurar Ansible para desplegar Docker y Directus en EC2.
   - Levantar el contenedor de Directus con Docker.

4. **Gestión del proyecto**: Describe cómo gestionar las variables de entorno y cómo actualizar las extensiones de Directus.

5. **Solución de problemas**: Instrucciones para resolver problemas comunes como errores de conexión con la base de datos o Docker.

Este archivo `README.md` proporcionará toda la información necesaria para los desarrolladores o administradores de sistemas que quieran configurar y mantener el proyecto en producción utilizando **AWS**, **Ansible** y **Terraform**.
# practiquescloud

Repositori de pràctiques de cloud computing. Cada exercici viu en una carpeta pròpia i
inclou la documentació, els diagrames de topologia i, quan escau, el codi Terraform.

## Exercicis

| Pràctica | Tema | Enllaç |
|---|---|---|
| pt1-4-ex1 | Primeres instàncies EC2 amb Terraform (2 × `t3.micro`, Amazon Linux 2023) | [`pt1-4-ex1/`](pt1-4-ex1/README.md) |
| pt1-4-ex2 | VPC `10.0.0.0/16` amb 3 subxarxes i 6 × `t3.micro`: disseny, desplegament per consola i amb Terraform | [`pt1-4-ex2/`](pt1-4-ex2/README.md) |
| pt2-2 | Infraestructura bàsica a AWS amb Terraform: VPC `VPC-03` (`10.0.0.0/16`), 2 subxarxes públiques, IGW, taula de rutes, SG i 2 × `t3.micro` | [`pt2-2/`](pt2-2/README.md) |

## Estructura

```
practiquescloud/
├── pt1-4-ex1/
│   ├── assets/
│   │   └── topologia.png
│   ├── README.md
│   └── main.tf
├── pt1-4-ex2/
│   ├── assets/
│   │   ├── VPC.png
│   │   ├── subredesvpc.png
│   │   ├── Instancias.png
│   │   └── topologia.png
│   ├── README.md
│   └── main.tf
└── pt2-2/
    ├── assets/
    │   ├── ec2_instances.png
    │   ├── route_tables.png
    │   ├── security_group_entrada.png
    │   ├── security_group_salida.png
    │   ├── subnets.png
    │   └── vpc.png
    ├── README.md
    ├── providers.tf
    ├── main.tf
    ├── security.tf
    └── ec2.tf
```

## Requisits

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- Credencials d'AWS actives (perfil `default` a `~/.aws/credentials`)

Cada exercici s'executa de manera independent:

```bash
cd pt1-4-ex1   # o pt1-4-ex2
terraform init
terraform plan
terraform apply
terraform destroy   # sempre al final
```

## Llicència

[MIT](LICENSE)

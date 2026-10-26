# practiquescloud

Repositori de pràctiques de cloud computing. Cada exercici viu en una carpeta pròpia i
inclou el codi Terraform, la documentació i el diagrama de topologia.

## Exercicis

| Pràctica | Tema | Enllaç |
|---|---|---|
| pt1-4-ex1 | Primeres instàncies EC2 amb Terraform (2 × `t3.micro`, Amazon Linux 2023) | [`pt1-4-ex1/`](pt1-4-ex1/README.md) |

## Estructura

```
practiquescloud/
└── pt1-4-ex1/
    ├── assets/
    │   ├── topologia.png
    │   └── topologia.drawio
    ├── README.md
    └── main.tf
```

## Requisits

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- Credencials d'AWS actives (perfil `default` a `~/.aws/credentials`)

Cada exercici s'executa de manera independent:

```bash
cd pt1-4-ex1
terraform init
terraform plan
terraform apply
terraform destroy   # sempre al final
```

## Llicència

[MIT](LICENSE)

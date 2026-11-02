# Exercici 2 — Disseny de xarxa i desplegament per consola

Aquesta pràctica té dues parts. A la **Part A** es dissenya una xarxa personalitzada
(VPC) amb tres subxarxes dins d'una mateixa zona de disponibilitat. A la **Part B** es
desplega tota la infraestructura **manualment des de la consola d'AWS** (GUI), sense
Terraform.

| Paràmetre | Valor |
|---|---|
| Regió | `us-east-1` |
| Zona de disponibilitat | `us-east-1a` (AZ-1a) |
| VPC | `10.0.0.0/16` |
| Instàncies | 6 × `t3.micro` (Amazon Linux 2023) |
| Distribució | 2 instàncies per subxarxa |

---

## Part A — Disseny de xarxa

### A.1 VPC

| Recurs | Nom | CIDR |
|---|---|---|
| VPC | `pt1-4-ex2-vpc` | `10.0.0.0/16` |

La VPC `/16` proporciona 65.536 adreces (`10.0.0.0` – `10.0.255.255`), espai de sobres
per encabir-hi les tres subxarxes sense solapaments.

### A.2 Subxarxes

Totes tres es creen a la **mateixa zona de disponibilitat, `us-east-1a`**:

| Subxarxa | Nom | CIDR | Rang d'adreces | Adreces útils | Instàncies |
|---|---|---|---|---|---|
| A | `Subnet A` | `10.0.32.0/25` | `10.0.32.0` – `10.0.32.127` | 123 | 2 |
| B | `Subnet B` | `10.0.30.0/23` | `10.0.30.0` – `10.0.31.255` | 507 | 2 |
| C | `Subnet C` | `10.0.33.0/28` | `10.0.33.0` – `10.0.33.15` | 11 | 2 |

> AWS reserva 5 adreces a cada subxarxa (la de xarxa, la del router, dues de DNS i la de
> broadcast). Per això una `/28` (16 adreces) deixa 11 adreces útils, més que suficients
> per a les 2 instàncies previstes.

### A.3 Topologia

```
VPC 10.0.0.0/16
│
└── us-east-1a (AZ-1a)
    ├── Subnet A  10.0.32.0/25   → 2 × EC2 t3.micro
    ├── Subnet B  10.0.30.0/23   → 2 × EC2 t3.micro
    └── Subnet C  10.0.33.0/28   → 2 × EC2 t3.micro
                                   ─────────────────
                                   6 instàncies en total
```

Les tres subxarxes no se solapen entre elles ni surten del rang de la VPC.

---

## Part B — Desplegament per consola d'AWS (GUI)

### B.0 Requisits previs

1. Sessió d'**AWS Academy Learner Lab** iniciada (les credencials són temporals).
2. Regió de treball: **N. Virginia (`us-east-1`)**.
3. **Key pair `vockey`** disponible a la regió (el crea AWS Academy per defecte).
4. Permisos per crear VPC, subxarxes i instàncies EC2.

### B.1 Crear la VPC

1. A la consola, ves a **VPC → Your VPCs → Create VPC**.
2. Selecciona **VPC only** (no «VPC and more»), per crear les subxarxes manualment.
3. Name tag: `pt1-4-ex2-vpc`.
4. IPv4 CIDR block: `10.0.0.0/16`.
5. Deixa la resta de valors per defecte i prem **Create VPC**.

![VPC creada a la consola d'AWS](assets/VPC.png)

### B.2 Crear les tres subxarxes

Per a cada subxarxa: **VPC → Subnets → Create subnet**.

| Nom | VPC | Zona de disponibilitat | IPv4 CIDR |
|---|---|---|---|
| `Subnet A` | `pt1-4-ex2-vpc` | `us-east-1a` | `10.0.32.0/25` |
| `Subnet B` | `pt1-4-ex2-vpc` | `us-east-1a` | `10.0.30.0/23` |
| `Subnet C` | `pt1-4-ex2-vpc` | `us-east-1a` | `10.0.33.0/28` |

1. Tria la VPC `pt1-4-ex2-vpc`.
2. Subnet name: el nom de la taula.
3. Availability Zone: **`us-east-1a`** (la mateixa per a les tres).
4. IPv4 CIDR block: el CIDR corresponent.
5. Prem **Create subnet** i repeteix el procés per a les altres dues.

![Subxarxes creades dins la VPC](assets/subredesvpc.png)

### B.3 Llançar les 6 instàncies EC2

Per a cada subxarxa es llancen **2 instàncies**, fins a un total de 6:

1. Ves a **EC2 → Instances → Launch instances**.
2. **Name**: `Subnet A Ins1` (i després `Subnet A Ins2`, `Subnet B Ins1`, `Subnet B Ins2`, `Subnet C Ins1` i `Subnet C Ins2`).
3. **AMI**: Amazon Linux 2023 (x86_64).
4. **Instance type**: `t3.micro`.
5. **Key pair**: `vockey`.
6. **Network settings → Edit**:
   - VPC: `pt1-4-ex2-vpc`.
   - Subnet: la subxarxa corresponent (`Subnet A`, `Subnet B` o `Subnet C`).
   - Security group: deixa el grup per defecte de la VPC.
7. **Number of instances**: `2` (per crear les dues de la subxarxa alhora).
8. Prem **Launch instance**.

Repeteix el procés per a les subxarxes B i C. Si fas servir **Number of instances = 2**,
les dues instàncies comparteixen el mateix Name tag: canvia'ls el nom després des del
llistat d'instàncies perquè quedin com `Subnet A Ins1`/`Subnet A Ins2`,
`Subnet B Ins1`/`Subnet B Ins2` i `Subnet C Ins1`/`Subnet C Ins2`.

| Subxarxa | Instàncies | Tipus | SO |
|---|---|---|---|
| `Subnet A` | `Subnet A Ins1`, `Subnet A Ins2` | `t3.micro` | Amazon Linux 2023 |
| `Subnet B` | `Subnet B Ins1`, `Subnet B Ins2` | `t3.micro` | Amazon Linux 2023 |
| `Subnet C` | `Subnet C Ins1`, `Subnet C Ins2` | `t3.micro` | Amazon Linux 2023 |

### B.4 Verificar el desplegament

1. Ves a **EC2 → Instances**.
2. Filtra per **Instance state = Running**.
3. Comprova que hi ha **6 instàncies**, totes `t3.micro`, en estat **Running** i
   repartides 2 a 2 entre les tres subxarxes.
4. Revisa la columna **Subnet ID** per confirmar la distribució.

![Llistat de les 6 instàncies EC2 en execució](assets/Instancias.png)

---

## Evidències de la pràctica

| Evidència | Captura |
|---|---|
| VPC creada | [`assets/VPC.png`](assets/VPC.png) |
| Subxarxes dins la VPC | [`assets/subredesvpc.png`](assets/subredesvpc.png) |
| 6 instàncies EC2 en execució | [`assets/Instancias.png`](assets/Instancias.png) |

---

## Neteja dels recursos

Per no consumir crèdit del laboratori, un cop acabada la pràctica:

1. **EC2 → Instances**: selecciona les 6 instàncies → **Instance state → Terminate**.
2. **VPC → Subnets**: elimina les tres subxarxes.
3. **VPC → Your VPCs**: elimina `pt1-4-ex2-vpc`.

> L'ordre importa: no es pot eliminar una VPC mentre tingui subxarxes o altres recursos
> associats.

---

## Problemes habituals

| Símptoma | Causa i solució |
|---|---|
| El CIDR de la subxarxa és rebutjat | El rang ha de cabre dins `10.0.0.0/16` i no pot solapar-se amb una altra subxarxa. |
| No apareix `us-east-1a` al desplegable | La VPC pot estar en una altra regió: comprova que ets a `us-east-1`. |
| `InvalidKeyPair.NotFound` en llançar la instància | El key pair `vockey` no existeix a la regió; crea'n un o selecciona'n un altre. |
| No puc eliminar la VPC | Encara té subxarxes o altres recursos associats; elimina'ls primer. |

---

**Autor:** Tabrih · Pràctiques Cloud

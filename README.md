# yungay-keepalive

Robot que mantiene despierto el proyecto **Carta Yungay Histórico** en Supabase
(plan gratuito), para que NO se pause por inactividad.

Cómo funciona: el plan gratuito de Supabase pausa un proyecto si pasa 7 días sin
recibir ninguna petición. Este repo usa GitHub Actions para mandarle, cada ~3 días,
una petición mínima a una función de la base de datos. Eso reinicia el contador de
inactividad y el proyecto nunca se pausa solo.

---

## Lo que TÚ tienes que hacer (3 cosas)

### 1) Correr el SQL en Supabase (una sola vez)

- Abre el archivo `supabase-setup.sql` de este repo.
- Ve a tu proyecto en Supabase → **SQL Editor** → **New query**.
- Pega TODO el contenido del archivo y dale **Run**.

Esto crea una tablita `keep_alive` y una función `ping_keep_alive()` que el robot va
a llamar. Ya queda blindado con RLS (nadie puede tocar la tabla por fuera de esa función).

### 2) Crear los dos secretos en GitHub

En este repo: **Settings → Secrets and variables → Actions → New repository secret**.
Crea estos dos (los nombres tienen que ser EXACTOS):

| Nombre del secreto   | Valor                                            |
|----------------------|--------------------------------------------------|
| `SUPABASE_URL`       | `https://xcxnurikpsygschnylxa.supabase.co`       |
| `SUPABASE_ANON_KEY`  | tu **publishable key** (`sb_publishable_...`)     |

> La publishable key la sacas de Supabase → **Settings → API Keys**.
> Pégala completa, sin espacios al inicio o al final.

### 3) Probar que funciona

- Ve a la pestaña **Actions** de este repo.
- Si te pide habilitar los workflows, dale **I understand my workflows, go ahead and enable them**.
- Elige el workflow **keep-supabase-alive** → botón **Run workflow**.
- Si sale en **verde**, está andando. Para confirmar, en Supabase corre en el SQL Editor:
  `select * from keep_alive;` y revisa que la fecha `last_ping` sea la de recién.

---

## Notas

- El workflow solo corre desde la rama por defecto (**main**). No lo muevas a otra rama.
- GitHub apaga los cron de un repo que pasa 60 días sin actividad; por eso el robot, en
  cada corrida, escribe `heartbeat.txt` y hace un commit. Eso mantiene vivo el propio cron.
- Esto resuelve la **pausa**, NO los backups. El plan gratuito no tiene respaldos
  automáticos. Para una carta el dato es casi estático, pero tenlo presente.

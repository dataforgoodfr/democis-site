# democis-site

Site de la Convention Citoyenne pour la Démocratie : https://conventioncitoyennepourlademocratie.fr

Site PHP sans base de données, livré comme une image `php:8.3-apache` :

- `site/` : le site, copié dans `/var/www/html`
  - `index.php`, `actualites.php`, `les-citoyens.php`, `qui-sommes-nous.php` : pages publiques
  - `get-actu.php` : contenu d'une actualité (JSON) pour la pop-in
  - `rss.php` : flux RSS des actualités
  - `admin/` : back-office des actualités et de la section « On en parle »
  - `lib/actus.php` : stockage et helpers des actualités
  - `lib/presse.php` : articles de presse « On en parle » ; `lib/presse-defaut.json`
    (logos dans `images/presse/`) sert de liste de départ tant que rien n'a été
    enregistré depuis le back-office
- `apache-democis.conf`, `php-democis.ini` : configuration Apache et PHP, copiées dans l'image

Les données du back-office ne sont pas dans l'image : en production, `/var/www/html/actus`
est un volume (`/opt/democis/actus` sur le serveur, sauvegardé chaque nuit sur S3).

## Développer en local

```bash
docker build -t democis-site . && docker run --rm -p 8080:80 -e DEMOCIS_ADMIN_PASSWORD=dev democis-site
```

Le site répond sur http://localhost:8080, le back-office sur http://localhost:8080/admin/.

## Variables d'environnement

- `SITE_URL` : URL publique, pour les liens absolus du flux RSS et des balises Open Graph
- `DEMOCIS_ADMIN_PASSWORD` : mot de passe du back-office (`/admin/`) ; vide = back-office désactivé

## Mise en production

Chaque push sur `main` construit et publie `ghcr.io/dataforgoodfr/democis-site:main-<sha>`
(GitHub Actions, `.github/workflows/docker-build.yml`, après un test de fumée sur les pages).
La production n'en change pas toute seule : le tag est épinglé dans le rôle Ansible
[`roles/services/democis`](https://github.com/dataforgoodfr/d4g-ansible/tree/main/roles/services/democis)
de `d4g-ansible`. Pour livrer, ouvrir une PR là-bas qui monte le tag, puis :

```bash
bin/d4g-ansible playbook playbooks/swarm-production.yml --tags democis
```

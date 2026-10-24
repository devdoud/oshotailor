-- Durcissement Supabase (base partagée par l'app cliente et l'app tailleur).
--
-- À RELIRE AVANT D'APPLIQUER, puis à placer comme migration dans le dépôt
-- qui porte le schéma (osho_supa/supabase/migrations). Non exécuté. Écrit
-- d'après les migrations de ce dépôt au 2026-10-24 : table public.profiles
-- (id, email, full_name, role, username, phone, avatar_url), table
-- public.fcm_tokens, trigger public.handle_new_user. Tester d'abord sur un
-- projet de test.
--
-- Déjà en place, donc non répété ici : RLS « chacun sa ligne » sur profiles
-- (20260707130000) et bucket « avatars » avec ses règles (20260707120000).

-- 1. Faille : la règle « Users can update own profile » permet à chacun de
--    modifier SA ligne, y compris la colonne role. N'importe qui peut donc
--    se déclarer tailor ou admin avec la clé publique. Seul le service_role
--    (fonctions serveur, back-office) peut changer role, email ou id.
create or replace function public.prevent_privileged_profile_changes()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if coalesce(auth.role(), '') <> 'service_role' and (
       new.role  is distinct from old.role
    or new.email is distinct from old.email
    or new.id    is distinct from old.id
  ) then
    raise exception 'Modification non autorisée du profil'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

drop trigger if exists profiles_prevent_privileged_changes on public.profiles;
create trigger profiles_prevent_privileged_changes
  before update on public.profiles
  for each row execute function public.prevent_privileged_profile_changes();

-- 2. Faille : handle_new_user copie le rôle depuis raw_user_meta_data, que
--    l'utilisateur fournit lui-même à l'inscription
--    (signUp(data: {role: 'admin'})). À la création d'un profil hors
--    service_role, le rôle est forcé à 'customer'.
--    ATTENTION : si des comptes tailleurs sont créés par une inscription
--    publique avec role='tailor', il faudra les promouvoir ensuite par une
--    fonction serveur ou le back-office (service_role).
create or replace function public.force_default_role_on_insert()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if coalesce(auth.role(), '') <> 'service_role' then
    new.role := 'customer';
  end if;
  return new;
end;
$$;

drop trigger if exists profiles_force_default_role on public.profiles;
create trigger profiles_force_default_role
  before insert on public.profiles
  for each row execute function public.force_default_role_on_insert();

-- 3. Faille : la règle fcm_tokens_service_select (using (true)) s'applique à
--    tous les rôles : n'importe quel client peut lire les jetons FCM de tout
--    le monde. Elle est inutile, car le service_role ignore la RLS ;
--    fcm_tokens_select_own suffit aux apps.
drop policy if exists "fcm_tokens_service_select" on public.fcm_tokens;

-- 4. Les statuts de commande ne changent que par les fonctions serveur
--    (update-assignment-status, qui tourne avec service_role). L'app tailleur
--    ne modifie plus public.orders directement.
--    ATTENTION : vérifiez d'abord que l'app cliente ne modifie pas elle non
--    plus public.orders (annulation, paiement…), sinon elle cessera de marcher.
alter table public.orders enable row level security;
revoke update, delete on public.orders from anon, authenticated;

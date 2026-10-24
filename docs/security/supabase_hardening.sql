-- Durcissement Supabase pour l'app tailleur Osho.
--
-- À RELIRE AVANT D'APPLIQUER. Ce script n'a pas été exécuté : il suppose
-- les tables public.users (id = auth.uid(), role, email) et public.orders
-- (status), telles que l'app les utilise. Vérifiez les noms de colonnes et
-- les politiques RLS déjà en place, puis exécutez-le dans l'éditeur SQL
-- d'un projet de test avant la production.

-- 1. Un utilisateur ne peut jamais changer son propre rôle, son e-mail ni
--    son identifiant. Seul le service_role (fonctions serveur, back-office)
--    le peut.
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

drop trigger if exists users_prevent_privileged_changes on public.users;
create trigger users_prevent_privileged_changes
  before update on public.users
  for each row execute function public.prevent_privileged_profile_changes();

-- 2. À la création d'un profil par l'app, le rôle est imposé côté serveur.
--    Adaptez la valeur par défaut si les comptes tailleurs sont créés
--    autrement (invitation, back-office avec service_role).
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

drop trigger if exists users_force_default_role on public.users;
create trigger users_force_default_role
  before insert on public.users
  for each row execute function public.force_default_role_on_insert();

-- 3. RLS : chacun ne lit et ne modifie que sa propre ligne de profil.
--    ATTENTION : si l'une des apps lit le profil d'un autre utilisateur
--    (nom du tailleur côté client, par exemple), ajoutez une politique de
--    lecture adaptée avant d'appliquer celle-ci.
alter table public.users enable row level security;

drop policy if exists "users_select_own" on public.users;
create policy "users_select_own" on public.users
  for select to authenticated using (id = auth.uid());

drop policy if exists "users_update_own" on public.users;
create policy "users_update_own" on public.users
  for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());

-- 4. Les statuts de commande ne changent que par les fonctions serveur
--    (update-assignment-status, qui tourne avec service_role). L'app ne
--    modifie plus public.orders directement : on retire ce droit aux clients.
--    ATTENTION : vérifiez d'abord que l'app cliente ne modifie pas elle non
--    plus public.orders (annulation, paiement…), sinon elle cessera de marcher.
alter table public.orders enable row level security;
revoke update, delete on public.orders from anon, authenticated;

-- 5. Photos de profil : bucket public `avatars`, un dossier par utilisateur
--    (<user id>/avatar.jpg). Lecture publique par URL ; chacun n'écrit,
--    ne remplace et ne supprime que dans son propre dossier.
--    Si l'app cliente utilise déjà un autre bucket pour les avatars, alignez
--    UserRepository.avatarBucket plutôt que d'en créer un second.
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

drop policy if exists "avatars_insert_own" on storage.objects;
create policy "avatars_insert_own" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'avatars'
              and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "avatars_update_own" on storage.objects;
create policy "avatars_update_own" on storage.objects
  for update to authenticated
  using (bucket_id = 'avatars'
         and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "avatars_select_own" on storage.objects;
create policy "avatars_select_own" on storage.objects
  for select to authenticated
  using (bucket_id = 'avatars'
         and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "avatars_delete_own" on storage.objects;
create policy "avatars_delete_own" on storage.objects
  for delete to authenticated
  using (bucket_id = 'avatars'
         and (storage.foldername(name))[1] = auth.uid()::text);
